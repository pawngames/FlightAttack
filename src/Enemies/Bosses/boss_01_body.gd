extends MeshInstance

onready var target:Spatial = $"../../Camera"

onready var laser_res = load("res://src/Enemies/LaserEnemy.tscn")
onready var shot_scene = load("res://src/Enemies/MissileEnemy.tscn")

var shot_count:int = 0
var turret_dmg:bool = false
var turret_enabled:bool = false

func _ready():
	pass

func _process(delta):
	if is_instance_valid(target) and is_instance_valid($boss_01_turret_body):
		$boss_01_turret_body.look_at(target.global_transform.origin, Vector3.UP)
		$boss_01_turret_body.rotation.x = 0
		$boss_01_turret_body.rotation.z = 0
		$boss_01_turret_body/RotHelper.look_at(target.global_transform.origin, Vector3.UP)
		$boss_01_turret_body/RotHelper/boss_01_turret_canon.look_at(target.global_transform.origin, Vector3.UP)
		$boss_01_turret_body/RotHelper/boss_01_turret_canon2.look_at(target.global_transform.origin, Vector3.UP)
	pass

func _choose(array:Array):
	array.shuffle()
	return array.front()

func _on_Timer_timeout():
	if !is_instance_valid($boss_01_turret_body) and !turret_enabled and\
		!is_instance_valid($boss_01_turret_body/RotHelper/boss_01_turret_canon):
		return
	
	if shot_count > 0:
		shot_count -= 1
		_shoot_side(true)
		_shoot_side(false)
		$TimerShots.wait_time = 0.2
	else:
		if turret_dmg:
			shot_count = _choose([
				3,4,5
			])
		else:
			shot_count = _choose([
				1, 2, 3
			])
		$TimerShots.wait_time = _choose([
			3.0,
			4.0,
			5,0
		])
	pass

func _shoot_side(left:bool):
	var shot_scene = laser_res.duplicate(true)
	var shot = shot_scene.instance()
	shot.set_as_toplevel(true)
	shot.speed = 1.0
	shot.scale = Vector3(2,2,2)
	shot.offset_velocity = -Vector3.FORWARD
	if left:
		$boss_01_turret_body/RotHelper/boss_01_turret_canon/Nozzle.add_child(shot)
	else:
		$boss_01_turret_body/RotHelper/boss_01_turret_canon2/Nozzle.add_child(shot)
	pass

func shoot_missile():
	var directions:Array = [
		Vector3.UP,
		Vector3.DOWN,
		Vector3.LEFT,
		Vector3.RIGHT
	]
	for i in range(directions.size()):
		var direction = directions[i]
		var shot:Spatial = shot_scene.duplicate(true).instance()
		shot.set_as_toplevel(true)
		shot.target = target
		shot.speed = 1.0
		shot.offset_velocity = Vector3.BACK
		$MissileNozzle.add_child(shot)
		shot.direction = direction + Vector3.BACK
		yield(get_tree().create_timer(.5),"timeout")
	pass

func _on_Area_area_entered(area):
	target = area
	pass

func shot_body(cannon:MeshInstance):
	if is_instance_valid(cannon) and cannon != null:
		cannon.get_node("Acummulate").emitting = true
		yield(get_tree().create_timer(cannon.get_node("Acummulate").lifetime/3), "timeout")
		cannon.get_node("Tween").interpolate_property(
			cannon.get_node("beam"),
			"visible",
			false,
			true,
			0.1
		)
		cannon.get_node("Tween").interpolate_property(
			cannon.get_node("beam"),
			"rotation",
			Vector3(0,-PI/2,0),
			Vector3(15*PI,-PI/2,0),
			5.4,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT,
			0.0
		)
		cannon.get_node("Tween").interpolate_property(
			cannon.get_node("beam"),
			"scale",
			Vector3(0.0001,0.0001,0.0001),
			Vector3(4,4,4),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT,
			0.0
		)
		cannon.get_node("Tween").interpolate_property(
			cannon.get_node("beam"),
			"scale",
			Vector3(4,4,4),
			Vector3(0.0001,0.0001,0.0001),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			5.0
		)
		cannon.get_node("Tween").start()
	pass
