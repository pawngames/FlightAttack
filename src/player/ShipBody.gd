extends Spatial

signal player_hit

var hit:bool = false
onready var start_pos:Vector3 = transform.origin

func _ready():
	pass

func _process(delta):
	if hit:
		randomize()
		var r = randf()/2
		var shake_vec:Vector3 = Vector3(r, r, r)
		transform.origin = transform.origin.linear_interpolate(shake_vec, 0.5)
	else:
		transform.origin = transform.origin.linear_interpolate(start_pos, 0.5)
	pass

func shoot():
	_shoot_side(true);
	_shoot_side(false);
	pass

func _shoot_side(left:bool):
	var shot_scene = load("res://src/player/Laser.tscn").duplicate(true)
	var shot = shot_scene.instance()
	shot.set_as_toplevel(true)
	if left:
		$weapon_rifle_L/Nozzle.add_child(shot)
	else:
		$weapon_rifle_R/Nozzle.add_child(shot)
	pass

func shoot_missile(target:Spatial):
	var shot_scene = load("res://src/player/weapons/missile.tscn").duplicate(true)
	var shot = shot_scene.instance()
	shot.set_as_toplevel(true)
	shot.set_target(target)
	$MissileNozzle.add_child(shot)
	pass

func _on_Area_body_entered(body:Spatial):
	hit = true
	Input.start_joy_vibration(0, 0.5, 0, 0.1)
	emit_signal("player_hit", null)
	#var direction = global_transform.origin.direction_to(\
	#	body.global_transform.origin).normalized()*6500
	#apply_impulse(direction, $ShipBody.transform.origin)
	pass

func _on_Area_body_exited(body):
	hit = false
	pass
