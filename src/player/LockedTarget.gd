extends MeshInstance

var target:Spatial = null
var locked:bool = false

func _ready():
	pass

func _process(delta):
	if is_instance_valid(target):
		global_transform.origin = target.global_transform.origin
	else:
		queue_free()

func lock_target(target_l:Spatial):
	target = target_l
	visible = true
	$Tween.interpolate_property(
		self,
		"scale",
		Vector3(20,20,20),
		Vector3(5,5,5),
		0.5,
		$Tween.TRANS_SINE,
		$Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		self,
		"rotation_degrees",
		Vector3(0,0,0),
		Vector3(0,0,405),
		0.5,
		$Tween.TRANS_SINE,
		$Tween.EASE_IN_OUT
	)
	$Tween.start()
