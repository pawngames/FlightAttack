extends Spatial

func _ready():
	pass

func _process(delta):
	$beam_laser_canon.rotation.z += .15
	$beam_laser_canon.scale.z = randf()/10 + .9
	pass
