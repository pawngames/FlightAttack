extends PathFollow

export var ship_follow_path:NodePath
onready var ship:PathFollow = get_node(ship_follow_path)
var debounce:int = 50
export var noise:OpenSimplexNoise

func _ready():
	noise.seed = randi()
	pass

func _process(delta):
	offset = ship.offset + 500
	debounce -= 1
	if debounce >= 0:
		return
	debounce = 50
	randomize()
	var side_mesh_scene = load("res://src/level/elements/SideMesh.tscn").duplicate(true)
	var side_mesh_l:MeshInstance = side_mesh_scene.instance()
	var side_mesh_r:MeshInstance = side_mesh_scene.instance()
	$"../../SideMeshes".add_child(side_mesh_l)
	$"../../SideMeshes".add_child(side_mesh_r)
	side_mesh_l.global_transform.origin = $RefMesh.global_transform.origin
	side_mesh_r.global_transform.origin = $RefMesh.global_transform.origin
	side_mesh_l.global_transform.origin.x -= 80.0
	side_mesh_r.global_transform.origin.x += 80.0
	var scale = noise.get_noise_1d(offset) + 0.5
	side_mesh_l.scale += Vector3(scale, scale/2, scale)*5
	side_mesh_r.scale += Vector3(scale, scale/2, scale)*5
	side_mesh_l.rotation.y = randf()*PI
	side_mesh_r.rotation.y = randf()*PI
	pass
