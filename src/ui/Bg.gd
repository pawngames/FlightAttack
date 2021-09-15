extends MeshInstance

func _ready():
	pass

func _process(delta):
	(material_override as SpatialMaterial).uv1_offset.y += 0.06
	pass

