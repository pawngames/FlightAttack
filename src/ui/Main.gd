extends Control


func _ready():
	change_scene("res://src/ui/StartMenu.tscn", false, false)
	pass

func change_scene(scene_str:String, show_loading:bool, music_change:bool):
	if music_change:
		$TopLayer/Player.play()
	if show_loading:
		show_loading()
		yield(get_tree().create_timer(1.0), "timeout")
	show_scene(scene_str)

func show_scene(scene_str:String):
	var new_scene = load(scene_str).instance()
	for scene in $Scenes.get_children():
		scene.queue_free()
		$Scenes.remove_child(scene)
	$Scenes.add_child(new_scene)
	pass

func show_loading():
	show_scene("res://src/ui/screens/Loading.tscn")
	pass
