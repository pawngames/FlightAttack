extends StaticBody

signal target_hit

onready var hit_mat:SpatialMaterial = load("res://src/materials/white_body.tres")
onready var nor_mat:SpatialMaterial = load("res://src/materials/purple_body.tres")

func _ready():
	pass

func hit(amount:int):
	emit_signal("target_hit")
	var parent:MeshInstance = get_parent()
	parent.material_override = hit_mat
	$Timer.start()
	pass

func _on_Timer_timeout():
	var parent:MeshInstance = get_parent()
	parent.material_override = nor_mat
	pass # Replace with function body.
