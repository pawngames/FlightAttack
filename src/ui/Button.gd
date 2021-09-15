extends Button

export(bool) var start_focused = false

func _ready():
	if start_focused:
		grab_focus()
	pass

func _on_ButtonStart_mouse_entered():
	grab_focus()
	pass
