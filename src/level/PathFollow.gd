extends PathFollow

var dash_val:float = 0.0
var speed:float = 1.2

func _ready():
	pass

func _process(delta):
	if $Ship.dash:
		dash_val = lerp(dash_val, speed, .1)
	else:
		dash_val = lerp(dash_val, 0, .1)
	if $Ship.shield >= 0:
		offset += speed + dash_val
	pass
