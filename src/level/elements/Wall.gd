extends Spatial

signal enemy_down

var original_position:Vector3
var final_position:Array
var walls:Array
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var number = rng.randi_range(1, 9)
	print("Tiles:" + str(number))
	var positions:Array
	for i in range(0, number):
		positions.append(1)
	for i in range(number, 10):
		positions.append(0)
	randomize()
	positions.shuffle()
	print(positions)
	for y in range(0, 3):
		for x in range(0, 3):
			var pos = x + y*3
			if positions[pos] == 1:
				var position = Vector2(x-1, y-1)
				_add_wall(position)
	pass

func _add_wall(position_xy:Vector2):
	print(position_xy)
	var wall_scene = load("res://src/level/elements/Wall.tscn").duplicate(true)
	var wall:Spatial = wall_scene.instance()
	add_child(wall)
	walls.append(wall)
	var position:Vector3 = Vector3(
		position_xy.x * 11.0, 
		position_xy.y * 11.0, 
		0.0)
	wall.final_position = position
	if position.y > 0:
		wall.transform.origin.y = position.y + 20.0
	else:
		wall.transform.origin.y = position.y - 20.0
	if position.x > 0:
		wall.transform.origin.x = position.x + 20.0
	else:
		wall.transform.origin.x = position.x - 20.0

func _process(delta):
	$"../".offset += .5
	for wall in walls:
		if is_instance_valid(wall):
			wall.transform.origin = lerp(wall.transform.origin, wall.final_position, 0.1)
	pass

func _on_Timer_timeout():
	get_parent().queue_free()
	pass # Replace with function body.
