extends Spatial

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var number = rng.randi_range(1, 3)
	print("Tiles:" + str(number))
	var positions:Array
	for i in range(0, number):
		positions.append(1)
	for i in range(number, 3):
		positions.append(0)
	randomize()
	positions.shuffle()
	print(positions)
	for y in range(0, 3):
		if positions[y] == 1:
			var position = Vector2(-2, y-1)
			_add_canon(position)
	pass

func _process(delta):
	get_parent().offset += .5

func _add_canon(position_xy:Vector2):
	print(position_xy)
	var wall_scene = load("res://src/Enemies/LaserCannon.tscn").duplicate(true)
	var wall:Spatial = wall_scene.instance()
	add_child(wall)
	var position:Vector3 = Vector3(
		position_xy.x * 15.0, 
		position_xy.y * 10.0, 
		0.0)
	wall.transform.origin = position

func _on_Timer_timeout():
	get_parent().queue_free()
	pass
