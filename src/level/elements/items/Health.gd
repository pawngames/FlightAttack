extends PathFollow

onready var health_mesh:MeshInstance = $HealthMesh
var collected:bool = false

func _ready():
	pass

func _process(delta):
	health_mesh.rotation_degrees.y += 1.0
	if collected:
		offset += 0.5
	offset += 0.5
	pass

func _on_Area_area_entered(area):
	collected = true
	if area.get_parent().has_method("health_collect"):
		area.get_parent().health_collect(5)
	queue_free()
	pass
