extends RigidBody

var target:Spatial = null

func _ready():
	var direction = -transform.basis.z
	linear_velocity = direction*20
	pass

func _integrate_forces(state):
	var multi = 10.0
	if target != null:
		look_at(target.global_transform.origin, Vector3.UP)
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		multi = 2*distance
	else:
		multi += 15
	if not $Explosion.emitting:
		var direction = -transform.basis.z
		state.apply_central_impulse(direction*multi)

func set_target(target_l:Spatial):
	target = target_l
	linear_velocity = Vector3.FORWARD*2
	pass

func _on_Area_body_entered(body:StaticBody):
	_explode(body)
	pass # Replace with function body.

func _explode(body:StaticBody):
	$Area/CollisionShape2.disabled = true
	linear_velocity = Vector3(0,0,0)
	$MeshInstance.visible = false
	$Explosion.emitting = true
	if body != null and body.has_method("hit"):
		body.hit(5)
	yield(get_tree().create_timer($Explosion.lifetime),"timeout")
	queue_free()
	pass

func _on_Timer_timeout():
	_explode(null)
	pass
