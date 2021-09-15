extends Control

func _ready():
	pass

func _on_Button_pressed():
	$"../../".change_scene("res://src/level/Level_Procedural.tscn", false, true)
	pass
