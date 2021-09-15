extends Node2D

var server := UDPServer.new()
var peers = []

var x_g:float = 0.0
var y_g:float = 0.0
var z_g:float = 0.0
var x_a:float = 0.0
var y_a:float = 0.0
var z_a:float = 0.0
var temp:float = 0.0
var throttle:float = 0.0
var sStrength:int = 0

func _ready():
	print("Starting server...")
	server.listen(12000)
	pass

func _process(delta):
	server.poll()
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [pkt.get_string_from_utf8()])
		peers.append(peer)
	pass

func _on_Timer_timeout():
	for i in range(0, peers.size()):
		var val_lx:float = Input.get_joy_axis(0, JOY_ANALOG_LX);
		var val_ly:float = Input.get_joy_axis(0, JOY_ANALOG_LY);
		var val_rx:float = Input.get_joy_axis(0, JOY_ANALOG_RX);
		var val_ry:float = Input.get_joy_axis(0, JOY_ANALOG_RY);
		# Reply so it knows we received the message.
		var response:String = "%f|%f|%f|%f\n" % [val_lx, val_ly, val_rx, val_ry]
		(peers[i] as PacketPeerUDP).put_packet(response.to_utf8())
		var packet = (peers[i] as PacketPeerUDP).get_packet().get_string_from_ascii()
		var parts:PoolRealArray = packet.split_floats("|");
		if parts.size() > 3:
			x_g = parts[0]
			y_g = parts[1]
			z_g = parts[2]
			temp = parts[3]
			throttle = (100*parts[4])/255
			sStrength = parts[5]
			#var text:String = "Rot:\nx:%.2f|y:%.2f|z:%.2f\ntemp:%.1f\nthrottle:%.1f\nSignal:%d\n" % \
			#	[x_g, y_g, z_g, temp, (100*throttle)/255, sStrength]
			#$"../Label".text = text
	pass # Replace with function body.
