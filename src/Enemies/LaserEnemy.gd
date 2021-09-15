extends Spatial

onready var direction:Vector3 = transform.basis.z

var hit:bool = false
var speed:float = 1.0
var offset_velocity = Vector3(0,0,0)

func _ready():
	pass

func _process(delta):
	if not hit:
		global_transform.origin += direction*speed + offset_velocity
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_Area_area_entered(area):
	hit = true
	$MeshInstance.visible = false
	$CPUParticles.emitting = true
	pass
