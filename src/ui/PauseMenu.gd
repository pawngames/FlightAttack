extends CenterContainer

signal unpause
signal pause
signal exit_level
signal restart_level

func _ready():
	$VBoxContainer/RestarBtn.grab_focus()
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		if get_tree().paused:
			emit_signal("unpause")
			print("unpause")
		else:
			emit_signal("pause")
			print("pause")

func _on_RestarBtn_pressed():
	emit_signal("restart_level")
	pass

func _on_ExitBtn_pressed():
	emit_signal("exit_level")
	pass
