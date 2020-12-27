extends MeshInstance

onready var direction:Vector3 = transform.basis.z

export var speed:float = 20

func _ready():
	pass

func _process(delta):
	global_transform.origin += direction.normalized()/speed
	pass
