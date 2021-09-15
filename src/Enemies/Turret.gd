extends Spatial

signal enemy_down

export var shot_speed:float = 3.0
export var shot_scale:float = 3.0

var target:Spatial
onready var laser_res = load("res://src/Enemies/LaserEnemy.tscn")

func _ready():
	$Body/TurretBody.connect("health_out", self, "_health_out_hits")
	$Timer.wait_time = randf() + .5
	pass

func _process(delta):
	if is_instance_valid(target):
		$Body/CanonRef.look_at(target.global_transform.origin, Vector3.UP)
		$Body/Head.rotation.y = $Body/CanonRef.rotation.y
	pass

func _on_Area_area_entered(area):
	target = area
	pass

func _on_Area_area_exited(area):
	target = null
	pass

func _on_Timer_timeout():
	if target != null:
		_shoot()
	pass

func _shoot():
	var shot_scene = laser_res.duplicate(true)
	var shot = shot_scene.instance()
	shot.rotation.y = PI
	shot.speed = shot_speed
	shot.scale = Vector3(shot_scale,shot_scale,shot_scale)
	shot.set_as_toplevel(true)
	$Body/CanonRef/Canon/Nozzle.add_child(shot)
	$Timer.wait_time = randf() + .5
	pass

func _health_out_hits(param):
	target = null
	emit_signal("enemy_down", null)
	pass

func release_target():
	var target = get_node("LockedTarget")
	if is_instance_valid(target):
		target.queue_free()
	pass


func _on_TimerFree_timeout():
	queue_free()
	pass
