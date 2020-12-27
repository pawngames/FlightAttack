extends Control

func _ready():
	pass

func _process(delta):
	pass

func set_enemy_count(count:int):
	$Container/HBox/Label.text = str(count)
	pass
