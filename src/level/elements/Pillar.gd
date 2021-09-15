extends Spatial


func _ready():
	$Tween.interpolate_property(
		$pillar,
		"translation",
		Vector3(0,-8,0),
		Vector3(0,0,0),
		3.0,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT,
		3.0
	)
	$Tween.interpolate_property(
		$pillar,
		"rotation",
		Vector3(0,-2*PI,0),
		Vector3(0,0,0),
		3.0,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT,
		3.0
	)
	$Tween.start()
	pass

func _on_Tween_tween_all_completed():
	$Smoke_Purple.emitting = false
	pass

func _on_Tween_tween_started(object, key):
	$Smoke_Purple.emitting = true
	pass
