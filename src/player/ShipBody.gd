extends Spatial

var shot_scene = load("res://src/player/weapons/missile.tscn")
var laser_scene = load("res://src/player/Laser.tscn")

signal player_hit
signal coin_collected
signal health_collected(amount)

var hit:bool = false
onready var start_pos:Vector3 = transform.origin
var destroyed = false

func _ready():
	pass

func _process(delta):
	if hit and not destroyed:
		randomize()
		var r = randf()/2
		var shake_vec:Vector3 = Vector3(r, r, r)
		transform.origin = transform.origin.linear_interpolate(shake_vec, 0.5)
	else:
		transform.origin = transform.origin.linear_interpolate(start_pos, 0.5)
	pass

func shoot():
	$LaserSound.play(0.0)
	_shoot_side(true);
	_shoot_side(false);
	pass

func _shoot_side(left:bool):
	var shot = laser_scene.duplicate(true).instance()
	shot.set_as_toplevel(true)
	if left:
		$Nozzle_r.add_child(shot)
	else:
		$Nozzle_l.add_child(shot)
	pass

func shoot_missile(target:Spatial):
	var shot = shot_scene.duplicate(true).instance()
	shot.set_as_toplevel(true)
	shot.set_target(target)
	$MissileNozzle.add_child(shot)
	pass

func coin_collect():
	emit_signal("coin_collected")
	pass

func health_collect(amount:int):
	emit_signal("health_collected", amount)
	$HealthParticles.emitting = true
	pass

func _on_Area_body_entered(body:Spatial):
	hit = true
	Input.start_joy_vibration(0, 0.5, 0, 0.1)
	emit_signal("player_hit", null)
	var direction = global_transform.origin.direction_to(\
		body.global_transform.origin).normalized()*6500
	#apply_impulse(direction, $ShipBody.transform.origin)
	pass

func _on_Area_body_exited(body):
	hit = false
	pass
