extends Spatial

var enemy_count:int = 0

func _ready():
	#not very optimal, just lazy
	#the sub nodes squad are just to manage
	#several enemies that will move togheter
	#and facilitate positioning in map
	for child in get_children():
		if child is Path:
			child.connect("enemy_down", self, "_add_enemy_count")
			continue
		if child is Spatial:
			for child_inner in child.get_children():
				if child_inner is Path:
					child_inner.connect("enemy_down", self, "_add_enemy_count")
	pass

func _add_enemy_count(param):
	enemy_count += 1
	$"../../Path/PathFollow/Ship".set_enemy_count(enemy_count)
	pass
