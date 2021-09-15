extends Spatial

var turret_scene = load("res://src/Enemies/Turret.tscn").duplicate(true)
var laser_scene = load("res://src/Enemies/LaserGrid.tscn").duplicate(true)
var wall_scene = load("res://src/level/elements/WallPath.tscn").duplicate(true)
var coin_scene = load("res://src/level/elements/items/Coin.tscn").duplicate(true)
var enemy_scene = load("res://src/Enemies/Enemy.tscn").duplicate(true)
var chaser_scene = load("res://src/Enemies/Chasers/Chaser.tscn").duplicate(true)
var gate_scene = load("res://src/level/elements/Gate.tscn").duplicate(true)
var pillar_scene = load("res://src/level/elements/Pillar.tscn").duplicate(true)

enum Spawns {
	WALL,
	LASERS,
	TURRETS,
	SHIPS,
	CHASER,
	PILLAR,
	GATE,
}

enum Patterns{
	Line,
	Arrow,
	Arrow_inv,
	Single
}

export var points_ahead:int = 2
export var points_distance:float = 160.0
export var curve_sharp = 500.0

onready var ship = $Path/PathFollow/Ship
onready var ship_pf = $Path/PathFollow

var offset_spawn = 250

var debug:bool = false

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var z_pos:int = 0
var i:int = 2
var noise_x:OpenSimplexNoise = _create_noise()
var noise_y:OpenSimplexNoise = _create_noise()
export var noise_levelgen:OpenSimplexNoise
var tiles_h:int = 10
var width_chunk_base = 30
var chunk_pos:int = tiles_h
var chunk:Array = []

var score:int = 0
var level:int = 1

var player_down:bool = false

func _ready():
	if debug:
		$Timer.one_shot = true
	rng.randomize()
	noise_levelgen.period = 0.1
	for i in range(points_ahead):
		_add_point()
	pass

func _add_point():
	var pos:Vector2 = _get_point_in_pos(i)*curve_sharp
	
	var new_point:Vector3 = Vector3(pos.x, pos.y, i*points_distance)
	var new_point_in:Vector3 = Vector3(0.0, 0.0, -points_distance/2.0)
	var new_point_out:Vector3 = Vector3(0.0, 0.0, points_distance/2.0)
	$Path.curve.add_point(new_point, new_point_in, new_point_out)
	i += 1

func _get_point_in_pos(i:int)->Vector2:
	var pos_y:float = noise_y.get_noise_1d(i)
	var pos_x:float = noise_x.get_noise_1d(i)
	return Vector2(pos_x, pos_y)

func _create_noise()->OpenSimplexNoise:
	var noise:OpenSimplexNoise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	return noise

func _process(delta):
	if not player_down:
		if ship.global_transform.origin.z > z_pos:
			_add_point()
			z_pos = $Path.curve.get_point_position(i - points_ahead - 1).z
		var new_level = (z_pos/1000) + 1
		$Label.text = str(z_pos)
		if new_level != level:
			print("new_level: " + str(new_level))
			level = new_level
			#$Path/PathFollow.speed += 0.1
	pass

func _on_Timer_timeout():
	if !$Path/PathFollow/Ship.enabled == true:
		return
	if level > 10 or debug:
		$Timer.stop()
		_spawn_boss(1)
	else:
		_spawn_coins()
		_generate_fixed()
	pass

func _generate_fixed():
	if chunk_pos == tiles_h:
		chunk_pos = 0
		rng.randomize()
		noise_levelgen.seed = rng.randi()
		($CanvasLayer/TextureRect.texture as NoiseTexture).noise = noise_levelgen
		for y in range(0, tiles_h):
			chunk.append(-1)

		var spawns_sz:int = Spawns.size()
		
		var min_val = 2.0
		var max_val = 0.0
		for y in range(0, tiles_h):
			var noise_val = (noise_levelgen.get_noise_1d(y) + 1.0)
			if noise_val < min_val:
				min_val = noise_val
			if noise_val > max_val:
				max_val = noise_val
		
		
		var step:float = 2.0/(spawns_sz + 1)
		print(">>>" + str(step))
		print(">>>" + str(spawns_sz))
		for y in range(0, tiles_h):
			var noise_val = (noise_levelgen.get_noise_1d(y) + 1.0)
			noise_val = 2*(noise_val - min_val)/(max_val - min_val)
			for value in Spawns.values():
				if noise_val >= value*step:
					chunk[y] = value
		
		var actual_chunk:String = ""
		for y in range(0, tiles_h):
			actual_chunk = actual_chunk + _str_spawn(chunk[y]) + "|"
			#chunk[y] = Spawns.CHASER
		print(actual_chunk)
	else:
		match(chunk[chunk_pos]):
			Spawns.GATE:
				_spawn_gate()
			Spawns.LASERS:
				_spawn_lasers()
			Spawns.PILLAR:
				_spawn_pillars()
			Spawns.SHIPS:
				_spawn_enemies()
			Spawns.CHASER:
				_spawn_chasers()
			Spawns.TURRETS:
				_spawn_turret()
			Spawns.WALL:
				_spawn_walls()
		chunk_pos += 1
	pass

func _str_spawn(spawn_id:int)->String:
	match(spawn_id):
		Spawns.GATE:
			return "GATE"
		Spawns.LASERS:
			return "LASERS"
		Spawns.PILLAR:
			return "PILLAR"
		Spawns.SHIPS:
			return "SHIPS"
		Spawns.CHASER:
			return "CHASER"
		Spawns.TURRETS:
			return "TURRETS"
		Spawns.WALL:
			return "WALL"
	return "EMPTY"

func _choose(array:Array):
	array.shuffle()
	return array.front()

func _spawn_boss(level:int):
	var enemy_scene = load("res://src/Enemies/Bosses/Boss_01.tscn").duplicate(true)
	var enemy:PathFollow = enemy_scene.instance()
	$Path.add_child(enemy)
	enemy.visible = true
	enemy.player_pf = $Path/PathFollow
	pass

func _spawn_enemies():
	var number:int = randi()%level + 1
	var range_x = 3
	var range_y = 3
	var width_x:float = range_x*25.0
	var width_y:float = range_y*15.0*range_y/range_x
	for x in range(-1, range_x-1):
		for y in range(-1, range_y-1):
			if randf() > (level/10.0):
				continue
			var enemy:PathFollow = enemy_scene.instance()
			$Path.add_child(enemy)
			enemy.visible = false
			enemy.offset = $Path/PathFollow.offset + offset_spawn
			enemy.h_offset = x*width_x/range_x
			enemy.start_v_offset = y*width_y/range_y
			enemy.start(randf()*1.5)
			enemy.start(0.0)
			enemy.connect("enemy_down", self, "_add_count")
	print("new Enemy")
	pass

func _spawn_chasers():
	var number:int = 8
	var angle_step:float = 2.0*PI/float(number)
	for x in range(0, number):
		var enemy:PathFollow = chaser_scene.instance()
		$Path.add_child(enemy)
		enemy.offset = $Path/PathFollow.offset + offset_spawn/2
		enemy.get_node("Chaser").start(x*angle_step)
		enemy.get_node("Chaser").connect("enemy_down", self, "_add_count")
	print("new Enemy")
	pass

func _spawn_chasers2():
	var number:int = 5
	var range_x = 3
	var range_y = 3
	var width_x:float = range_x*25.0
	var width_y:float = range_y*15.0*range_y/range_x
	for x in range(-1, range_x-1):
		for y in range(-1, range_y-1):
			var enemy:PathFollow = chaser_scene.instance()
			$Path.add_child(enemy)
			enemy.offset = $Path/PathFollow.offset + offset_spawn
			enemy.h_offset = x*width_x/range_x
			enemy.v_offset = y*width_y/range_y
			enemy.get_node("Chaser").connect("enemy_down", self, "_add_count")
			print("new Enemy")
	pass

func _spawn_gate():
	var width = 45.0
	var gate:Spatial = gate_scene.instance()
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	$SideMeshes.add_child(gate)
	gate.global_transform.origin = spawn_point
	#gate.transform.origin.x = 0
	print(gate.global_transform.origin)
	print("new Gate")
	pass

func _spawn_pillars():
	print("new Pillars")
	var pattern = _choose([
		Patterns.Arrow,
		Patterns.Arrow_inv,
		Patterns.Line,
		Patterns.Single,
	])
	match(pattern):
		Patterns.Arrow:
			_instantiate_pillar(-1, 1)
			_instantiate_pillar(0, 0)
			_instantiate_pillar(1, 1)
		Patterns.Arrow_inv:
			_instantiate_pillar(-1, 0)
			_instantiate_pillar(0, 1)
			_instantiate_pillar(1, 0)
		Patterns.Line:
			_instantiate_pillar(-1, 0)
			_instantiate_pillar(0, 0)
			_instantiate_pillar(1, 0)
		Patterns.Single:
			_instantiate_pillar(rng.randi_range(-1, 1), 0)
	pass

func _instantiate_pillar(x:int, y:int):
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	var pillar:Spatial = pillar_scene.instance()
	$Path.add_child(pillar)
	pillar.global_transform.origin = spawn_point
	pillar.transform.origin.x = x*width_chunk_base
	pillar.global_transform.origin.z -= y*width_chunk_base
	print(pillar.global_transform.origin)

func _spawn_walls():
	var wall:PathFollow = wall_scene.instance()
	wall.offset = $Path/PathFollow.offset + offset_spawn
	$Path.add_child(wall)
	wall.get_node("Wall").connect("enemy_down", self, "_add_count")
	print("new Wall")
	pass

func _spawn_lasers():
	var instance:PathFollow = laser_scene.instance()
	instance.offset = $Path/PathFollow.offset + offset_spawn
	$Path.add_child(instance)
	print("new Lasers")
	pass

func _spawn_turret():
	print("new Turrets")
	var pattern = _choose([
		Patterns.Arrow,
		Patterns.Arrow_inv,
		Patterns.Line,
		Patterns.Single,
	])
	match(pattern):
		Patterns.Arrow:
			_instantiate_turret(-1, 1)
			_instantiate_turret(0, 0)
			_instantiate_turret(1, 1)
		Patterns.Arrow_inv:
			_instantiate_turret(-1, 0)
			_instantiate_turret(0, 1)
			_instantiate_turret(1, 0)
		Patterns.Line:
			_instantiate_turret(-1, 0)
			_instantiate_turret(0, 0)
			_instantiate_turret(1, 0)
		Patterns.Single:
			_instantiate_turret(rng.randi_range(-1, 1), 0)
	pass

func _instantiate_turret(x:int, y:int):
	var turret:Spatial = turret_scene.instance()
	var spawn_point = $Path/SpawnPoint/RefMesh.global_transform.origin
	turret.global_transform.origin = spawn_point
	turret.transform.origin.x = x*width_chunk_base
	turret.transform.origin.z -= y*width_chunk_base
	$SideMeshes.add_child(turret)
	turret.connect("enemy_down", self, "_add_count")

func _spawn_coins():
	var number:int = randi()%10 + 1
	var x:int = rng.randi_range(-1, 1)
	var y:int = rng.randi_range(-1, 1)
	var width:float = 33.0
	for i in range(number):
		var coin:PathFollow = coin_scene.instance()
		$Path.add_child(coin)
		coin.offset = $Path/PathFollow.offset + 250 + 30*i
		coin.h_offset = x*width/3
		coin.v_offset = y*width/3.5
	pass


func _add_count(param):
	score += 1
	$Path/PathFollow/Ship.set_enemy_count(score)
	pass

func _on_Ship_player_down():
	print("player_down")
	$CanvasLayer/PauseMenu.visible = true
	$Timer.stop()
	player_down = true
	pass # Replace with function body.

func _on_PauseMenu_unpause():
	print("unpaused level")
	get_tree().paused = false
	$CanvasLayer/PauseMenu.visible = false
	pass

func _on_PauseMenu_pause():
	print("paused level")
	get_tree().paused = true
	$CanvasLayer/PauseMenu/VBoxContainer/RestarBtn.grab_focus()
	$CanvasLayer/PauseMenu.visible = true
	pass

func _on_PauseMenu_exit_level():
	print("exit level")
	get_tree().paused = false
	$"../../".change_scene("res://src/ui/StartMenu.tscn", false, true)
	pass

func _on_PauseMenu_restart_level():
	print("restart level")
	get_tree().paused = false
	$"../../".change_scene("res://src/level/Level_Procedural.tscn", false, true)
	pass
