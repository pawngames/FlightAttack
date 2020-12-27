extends PathFollow

func _ready():
	pass

func _process(delta):
	offset += .2
	if $Ship.dash:
		offset += .2
	pass
