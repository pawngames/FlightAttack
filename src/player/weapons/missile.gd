extends RigidBody

var target:Spatial = null

func _ready():
	var direction = -transform.basis.z
	linear_velocity = direction*50
	$TimerSound.start(randf()/2.0)
	pass

func _integrate_forces(state):
	var multi = 30.0
	if is_instance_valid(target):
		look_at(target.global_transform.origin, Vector3.UP)
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		multi = distance + 5.0
	else:
		multi += 60
	
	if not $Explosion.emitting:
		var direction = -transform.basis.z
		state.apply_central_impulse(direction*multi)

func set_target(target_l:Spatial):
	target = target_l
	linear_velocity = Vector3.FORWARD*3
	pass

func _on_Area_body_entered(body:StaticBody):
	_explode(body)
	pass # Replace with function body.

func _explode(body:StaticBody):
	$Area/CollisionShape2.disabled = true
	linear_velocity = Vector3(0,0,0)
	$MeshInstance.visible = false
	$Explosion.emitting = true
	if is_instance_valid(body) and body.has_method("hit"):
		body.hit(5)
		$ExplosionSound.play(0.0)
	#if is_instance_valid(body) and body.has_method("release_target"):
	#	body.release_target()
	if is_instance_valid(target):
		target.queue_free()
		target = null
	yield(get_tree().create_timer($Explosion.lifetime),"timeout")
	queue_free()
	pass

func _on_Timer_timeout():
	_explode(null)
	pass

func _on_TimerSound_timeout():
	$TimerSound/MissileSound.play(0.0)
	pass
