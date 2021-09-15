extends StaticBody

signal health_out

export var explosion_path:NodePath
onready var explosion:CPUParticles = get_node(explosion_path)

export var ship_mesh_path:NodePath
onready var ship_mesh:MeshInstance = get_node(ship_mesh_path)

export var tween_path:NodePath
onready var tween:Tween = get_node(tween_path)

func _ready():
	pass

export var health = 3
var down = false

func hit(amount:int):
	health -= amount
	if health <= 0:
		$CollisionShape.disabled = down
		explosion.emitting = true
		var duration = explosion.lifetime
		emit_signal("health_out", null)
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
		yield(get_tree().create_timer(explosion.lifetime), "timeout")
		$"../../".queue_free()
	pass
