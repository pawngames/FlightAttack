extends Node2D

export(int) var joy_id = 0

var stick_speed = 0
var stick_angle = 0
var stick_vector = Vector2()

var stick_speed_ant = 0
var stick_angle_ant = 0
var stick_vector_ant = Vector2()

signal control_signal(speed, angle, vector)

func _ready():
	$border.set_position(global_position)
	pass

func _process(delta):
	if 	stick_angle_ant != stick_angle or \
		stick_speed_ant != stick_speed or \
		stick_vector_ant != stick_vector:
		stick_speed_ant = stick_speed
		stick_angle_ant = stick_angle
		stick_vector_ant = stick_vector
		emit_signal("control_signal", stick_speed, stick_angle, stick_vector)
	pass
