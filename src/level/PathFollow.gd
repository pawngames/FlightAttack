extends PathFollow

var dash_val:float = 0.0

func _ready():
	pass

func _process(delta):
	if $Ship.dash:
		dash_val = lerp(dash_val, .4, .1)
	else:
		dash_val = lerp(dash_val, 0, .1)
	offset += .4 + dash_val
	pass
