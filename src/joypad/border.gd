extends Sprite

const RADIUS = 120
const SMALL_RADIUS = 40

var stick_pos
var evt_index = -1

func set_position(position):
	stick_pos = global_position
	pass

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if stick_pos.distance_to(event.position) <= RADIUS:
				evt_index = event.index
		elif evt_index != -1:
			if evt_index == event.index:
				evt_index = -1
				$"../".stick_vector = Vector2()
				$"../".stick_angle = 0
				$"../".stick_speed = 0
				$center.position = Vector2()
	elif event is InputEventScreenDrag and evt_index == event.index:
		var dist = stick_pos.distance_to(event.position)
		if dist + SMALL_RADIUS >  RADIUS:
			dist = RADIUS - SMALL_RADIUS
		
		var vect = (event.position - stick_pos).normalized()
		var ang = event.position.angle_to_point(stick_pos)
		
		$"../".stick_vector = vect
		$"../".stick_angle = ang
		$"../".stick_speed = dist
		$center.position = vect * dist
	pass
