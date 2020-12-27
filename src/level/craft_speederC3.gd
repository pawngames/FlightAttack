extends MeshInstance

onready var direction:Vector3 = transform.basis.z
onready var original_pos = global_transform.origin

export var speed:float = 30

func _ready():
	pass

func _process(delta):
	global_transform.origin += direction.normalized()/speed
	pass
