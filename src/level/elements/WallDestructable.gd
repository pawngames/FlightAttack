extends Spatial

var final_position:Vector3

func _ready():
	$WallObject/StaticBody.connect("health_out", self, "_health_out_hits")
	pass

func _health_out_hits(param):
	get_parent().emit_signal("enemy_down", null)
	if randf() < 0.4:
		var health_scene = load("res://src/level/elements/items/Health.tscn").duplicate(true)
		var health:PathFollow = health_scene.instance()
		get_parent().get_parent().get_parent().add_child(health)
		health.offset = get_parent().get_parent().offset + 10.0
		var parent_pos = transform.origin
		health.h_offset = parent_pos.x
		health.v_offset = parent_pos.y
	pass

