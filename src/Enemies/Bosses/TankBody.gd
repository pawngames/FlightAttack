extends StaticBody

export var health_max:int = 100
var health:int = health_max
var down:bool = false

export var tween_path:NodePath
onready var tween:Tween = get_node(tween_path)

func _ready():
	pass

func hit(amount:int):
	health -= amount
	if health < health_max/2:
		$"../Smoke".emitting = true
	if health <= 0 and not down:
		down = true
		$CollisionShape.disabled = down
		var duration = 2.0
		tween.interpolate_property(
			get_parent(), 
			"scale",
			get_parent().scale,
			Vector3(.1, .1, .1),
			duration,
			tween.TRANS_SINE,
			tween.EASE_IN_OUT,
			0.0)
		var parent:MeshInstance = get_parent()
		tween.interpolate_property(
			parent, 
			"translation",
			parent.transform.origin,
			Vector3(get_parent().transform.origin.x, 
					-25.0, 
					get_parent().transform.origin.z),
			duration,
			tween.TRANS_SINE,
			tween.EASE_IN_OUT,
			0.0)
		tween.start()
		$"../Smoke".emitting = false
		yield(get_tree().create_timer(duration), "timeout")
		$"../../../".queue_free()
	pass
