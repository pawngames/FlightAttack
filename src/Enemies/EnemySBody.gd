extends StaticBody

onready var health = $"../../../".health_max
onready var explosion = $"../../CPUParticles"
onready var ship_mesh:MeshInstance = $"../../ShipMesh"
onready var tween = $"../../Tween"

onready var laser_res = load("res://src/Enemies/LaserEnemy.tscn")

var down = false
var shoot = false

signal health_out

func _ready():
	pass

func hit(amount:int):
	health -= amount
	if health <= 0 and not down:
		down = true
		emit_signal("health_out", null)
		var duration = explosion.lifetime
		tween.interpolate_property(
			ship_mesh, 
			"scale",
			ship_mesh.scale,
			Vector3(.1, .1, .1),
			duration,
			tween.TRANS_SINE,
			tween.EASE_IN_OUT,
			0.0)
		tween.start()
		explosion.emitting = true
		yield(get_tree().create_timer($"../../CPUParticles".lifetime), "timeout")
		$"../../../".queue_free()
	pass

func _shoot_side(left:bool):
	var shot_scene = laser_res.duplicate(true)
	var shot = shot_scene.instance()
	shot.set_as_toplevel(true)
	if left:
		$Nozzle_L.add_child(shot)
	else:
		$Nozzle_R.add_child(shot)
	pass

func _on_AreaShotRange_area_entered(area):
	print("EnemyAim")
	_shoot_side(true)
	_shoot_side(false)
	pass
