extends Spatial

export var initialPos:Vector3
export var gate_pos:int

func _ready():
	$GateRef.transform.origin = initialPos
	$Tween.interpolate_property(
		$GateRef,
		"translation",
		initialPos,
		Vector3(0,0,0),
		2.0,
		Tween.TRANS_BOUNCE,
		Tween.EASE_IN_OUT,
		0.0
	)
	$Tween.interpolate_property(
		$CPUParticles,
		"emitting",
		false,
		true,
		2.6
	)
	$Tween.interpolate_property(
		$CPUParticles2,
		"emitting",
		false,
		true,
		2.6
	)
	$GateRef/gate_inner_l.transform.origin = Vector3(gate_pos,0,0)
	$Tween.interpolate_property(
		$GateRef/gate_inner_l,
		"translation",
		Vector3(gate_pos,0,0),
		Vector3(0,0,0),
		1.0,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT,
		2.0
	)
	$GateRef/gate_inner_r.transform.origin = Vector3(-gate_pos,0,0)
	$Tween.interpolate_property(
		$GateRef/gate_inner_r,
		"translation",
		Vector3(-gate_pos,0,0),
		Vector3(0,0,0),
		1.0,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT,
		2.0
	)
	$Tween.start()
	pass

func _on_GateTarget_target_hit():
	print("hit_target_signal")
	$GateRef/gate_inner_l.transform.origin.x += .1
	$GateRef/gate_inner_r.transform.origin.x -= .1
	pass # Replace with function body.
