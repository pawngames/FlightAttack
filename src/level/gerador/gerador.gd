extends Spatial

var noise:OpenSimplexNoise = OpenSimplexNoise.new()
onready var mat:SpatialMaterial = $MeshInstance.material_override
onready var noiseTex:NoiseTexture = mat.albedo_texture

var turret_scene = load("res://src/Enemies/Turret.tscn").duplicate(true)
var laser_scene = load("res://src/Enemies/LaserGrid.tscn").duplicate(true)
var wall_scene = load("res://src/level/elements/WallPath.tscn").duplicate(true)
var coin_scene = load("res://src/level/elements/items/Coin.tscn").duplicate(true)
var enemy_scene = load("res://src/Enemies/Enemy.tscn").duplicate(true)
var gate_scene = load("res://src/level/elements/Gate.tscn").duplicate(true)
var pillar_scene = load("res://src/level/elements/Pillar.tscn").duplicate(true)

var level = 1
var width = 30.0

var tiles_w:int = 1
var tiles_h:int = 64
var tiles_l:int = 1

enum Tiles{
	EMPTY,
	GATE,
	SPACE,
	TOWER,
	TURRET
}

enum Patterns{
	Line,
	Arrow,
	Arrow_inv,
	Single
}

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	var mesh_tmp = $MeshInstance.mesh
	mesh_tmp.size = Vector2(tiles_l*width*3, tiles_h*width*3)
	$MeshInstance.mesh = mesh_tmp
	noiseTex.height = tiles_h*3
	noise = noiseTex.noise
	mat.albedo_texture = noiseTex
	pass

func _process(delta):
	#$Path/SpawnPoint.offset += .5
	if Input.is_action_just_pressed("ui_select"):
		print("input")
		_generate()
	pass

func _generate():
	for child in $Path/PathFollow.get_children():
		child.queue_free()
	for child in $SideMeshes.get_children():
		child.queue_free()
	
	rng.randomize()
	noise.seed = rng.randi()
	var width_map:Array = []
	for x in range(-tiles_w, tiles_w + 1):
		var height_map:Array = []
		for y in range(-tiles_h, tiles_h + 1):
			height_map.append(Tiles.EMPTY)
		width_map.append(height_map)

	#sides
	for y in range(-tiles_h, tiles_h + 1):
		var noise_val = noise.get_noise_2d(1, y)
		if width_map[0][y] == Tiles.EMPTY:
			if noise_val > -0.5 and noise_val < -0.1:
				width_map[0][y] = Tiles.TURRET
			elif noise_val > -0.1 and noise_val < 0.25:
				width_map[0][y] = Tiles.TOWER
			elif noise_val > 0.25 and noise_val < 0.5:
				width_map[0][y] = Tiles.GATE
	var line = ""
	for y in range(-tiles_h, tiles_h + 1):
		line = line + str(width_map[0][y]) + "|"
		for x in range(-tiles_w, tiles_w + 1):
			match(width_map[x][y]):
				Tiles.GATE:
					_spawn_gate(x, y)
				Tiles.TURRET:
					_spawn_turret(x, y)
				Tiles.TOWER:
					_spawn_pillars(x, y)
	print(line)
	#$Path/PathFollow.add_child(_create_mesh(0, y))
	#$Path/PathFollow.add_child(_create_mesh(1, y))
	pass

func _choose(array:Array):
	array.shuffle()
	return array.front()

func _spawn_elements(x:int, y:int):
	var noise_val = noise.get_noise_2d(x, y)
	if noise_val > 0.0:
		if noise_val > 0.3 and noise_val < 0.5:
			_spawn_turret(x, y)
		print(noise_val)

func _create_mesh(x:int, y:int)->MeshInstance:
	var mesh_inst:MeshInstance = MeshInstance.new()
	var mesh:CubeMesh = CubeMesh.new()
	mesh_inst.mesh = mesh
	var material:SpatialMaterial = SpatialMaterial.new()
	material.albedo_color = Color.black
	mesh.material = material
	mesh_inst.transform.origin.x = x*width
	mesh_inst.transform.origin.z = y*width
	print(mesh_inst.transform.origin)
	return mesh_inst

func _spawn_gate(x:int, y:int):
	var width = 45.0
	var gate:Spatial = gate_scene.instance()
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	$SideMeshes.add_child(gate)
	gate.global_transform.origin = spawn_point
	gate.global_transform.origin.x = x*width
	gate.global_transform.origin.y = 0
	gate.global_transform.origin.z = y*width
	print(gate.global_transform.origin)
	print("new Gate")
	pass

func _spawn_pillars(x:int, y:int):
	var width:float = 33.0
	var pillar:Spatial = pillar_scene.instance()
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	$SideMeshes.add_child(pillar)
	pillar.global_transform.origin = spawn_point
	pillar.transform.origin.z = y*width
	pillar.transform.origin.x = x*width
	pillar.transform.origin.y -= width
	pass

func _spawn_enemies(x: int, y:int, z:int):
	var number:int = randi()%level + 1
	var enemy:PathFollow = enemy_scene.instance()
	$Path.add_child(enemy)
	enemy.visible = false
	enemy.offset = $Path/PathFollow.offset + z*width
	enemy.h_offset = x*width
	enemy.start_v_offset = y*width
	enemy.start(randf()*3.0)
	enemy.start(0.0)
	enemy.connect("enemy_down", self, "_add_count")
	print("new Enemy")
	pass

func _spawn_walls():
	var wall:PathFollow = wall_scene.instance()
	wall.offset = $Path/PathFollow.offset + 150
	$Path.add_child(wall)
	wall.get_node("Wall").connect("enemy_down", self, "_add_count")
	print("new Wall")
	pass

func _spawn_lasers():
	var instance:PathFollow = laser_scene.instance()
	instance.offset = $Path/PathFollow.offset + 150
	$Path.add_child(instance)
	print("new Lasers")
	pass

func _spawn_turret(x: int, y:int):
	var number:int = (randi()%level/2) + 1
	var turret:Spatial = turret_scene.instance()
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	$SideMeshes.add_child(turret)
	turret.global_transform.origin = spawn_point
	turret.transform.origin.z = y*width
	turret.transform.origin.x = x*width
	turret.transform.origin.y -= width
	print(turret.global_transform.origin)
	turret.connect("enemy_down", self, "_add_count")
	print("new Turret")
	pass

