extends StaticBody

export var max_damage:int = 10
var damage = max_damage

signal health_out

func _ready():
	pass

func release_target():
	var target = get_node("LockedTarget")
	if is_instance_valid(target):
		target.queue_free()
	pass

func hit(dmg:int):
	damage -= dmg
	if damage < (max_damage/2 + 1):
		var mat:SpatialMaterial = get_parent().material_override.duplicate(true)
		mat.albedo_texture = load("res://assets/2d/level/square_yellow_cracked.png")
		mat.emission_texture = load("res://assets/2d/level/square_yellow_cracked.png")
		#mat.uv1_scale = Vector3(3,2,3)
		get_parent().material_override = mat
	if damage <= 0:
		get_parent().visible = false
		collision_layer = 0
		collision_mask = 0
		$"../../CPUParticles".emitting = true
		emit_signal("health_out", null)
		yield(get_tree().create_timer($"../../CPUParticles".lifetime), "timeout")
		get_parent().queue_free()
	pass

func _on_Timer_timeout():
	get_parent().get_parent().queue_free()
	pass
