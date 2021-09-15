extends StaticBody

export var explosion_path:NodePath
onready var explosion:CPUParticles = get_node(explosion_path)

export var ship_mesh_path:NodePath
onready var ship_mesh:MeshInstance = get_node(ship_mesh_path)

export var tween_path:NodePath
onready var tween:Tween = get_node(tween_path)

onready var health = 1
signal health_out
var down = false

func _ready():
	pass

func release_target():
	var target = get_node("LockedTarget")
	if target != null:
		target.queue_free()
	pass

func hit(amount:int):
	health -= amount
	if health <= 0 and not down:
		down = true
		$CollisionShape.disabled = down
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
		yield(get_tree().create_timer(explosion.lifetime), "timeout")
		$"../../".queue_free()
	
