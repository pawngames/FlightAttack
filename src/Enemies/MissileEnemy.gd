extends Spatial

enum MStates{
	WAIT,
	AIM,
	DISABLE,
	HIT
}

var current_state:int = MStates.WAIT
var target:Spatial
var next_state:bool = false
var direction = -global_transform.basis.z
var speed:float = 1.0
var offset_velocity = Vector3(0,0,0)
var elapsed:int = 0
var start:int = 0
var hit = false

func _ready():
	start = OS.get_ticks_msec()
	pass

func _process(delta):
	elapsed = OS.get_ticks_msec()
	match current_state:
		MStates.WAIT:
			if (elapsed - start) > 300:
				current_state = MStates.AIM
				next_state = false
			global_transform.origin += direction*speed + offset_velocity
		MStates.AIM:
			look_at(target.global_transform.origin, Vector3.UP)
			direction = global_transform.origin.direction_to(target.global_transform.origin)
			if (elapsed - start) > 800:
				current_state = MStates.DISABLE
				next_state = false
			global_transform.origin += direction*speed + offset_velocity
		MStates.DISABLE:
			global_transform.origin += direction*speed + offset_velocity
		MStates.HIT:
			pass
	pass

func _on_TimerFree_timeout():
	queue_free()
	pass

func _on_Area_area_entered(area):
	next_state = MStates.HIT
	$missile_wire_enemy.visible = false
	$Explosion.emitting = true
	pass # Replace with function body.
