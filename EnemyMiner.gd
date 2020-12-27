extends MeshInstance

func _ready():
	pass

func _process(delta):
	if get_parent() is PathFollow:
		get_parent().offset += .1
