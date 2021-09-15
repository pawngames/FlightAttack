extends Control

export(Vector2) var right_input = Vector2()
export(Vector2) var left_input = Vector2()

var pressed:bool = false
var just_pressed:bool = false
var just_released:bool = false

export var c_curve:Curve

func _on_left_stick_control_signal(speed, angle, vector):
	left_input = vector
	input_received(vector, 0)
	pass

func input_received(vector,id):
	match id:
		0:
			send_stick_event(vector.x, JOY_ANALOG_LX)
			send_stick_event(vector.y, JOY_ANALOG_LY)
	pass

func send_stick_event(value, id):
	if not visible:
		return
	
	var ev = InputEventJoypadMotion.new()
	if value >= 0:
		ev.set_axis_value(c_curve.interpolate_baked(value))
	else:
		ev.set_axis_value(-c_curve.interpolate_baked(-value))
	ev.set_axis(id)
	Input.parse_input_event(ev)
	pass

func send_btn_event(value, id):
	var ev = InputEventJoypadButton.new()
	ev.pressed = value
	ev.button_index = id
	Input.parse_input_event(ev)
	pass

func _on_BtnFire_button_down():
	if not just_pressed:
		just_pressed = true
		just_released = false
		send_btn_event(true, JOY_BUTTON_0)
	pass

func _on_BtnFire_button_up():
	if not just_released:
		just_pressed = false
		just_released = true
		send_btn_event(false, JOY_BUTTON_0)
	pass
