extends Spatial

onready var direction:Vector3 = transform.basis.z

var hit:bool = false

func _ready():
	pass

func _process(delta):
	if not hit:
		global_transform.origin += direction
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_Area_body_entered(body):
	hit = true
	$MeshInstance.visible = false
	$CPUParticles.emitting = true
	if body != null and body.has_method("hit"):
		body.hit(1)
	pass
