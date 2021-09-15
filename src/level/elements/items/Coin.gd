extends PathFollow

onready var coin_mesh:MeshInstance = $CoinMesh
onready var tween:Tween = $Tween
var duration:float = 0.5
var collected:bool = false

func _ready():
	coin_mesh.rotation.y = randf()*PI
	pass

func _process(delta):
	coin_mesh.rotation_degrees.y += 1.0
	if collected:
		offset += 0.5
	offset += 0.5
	pass

func _on_Area_area_entered(area):
	collected = true
	tween.interpolate_property(
		coin_mesh, 
		"scale",
		coin_mesh.scale,
		Vector3(.1, .1, .1),
		duration,
		tween.TRANS_SINE,
		tween.EASE_IN_OUT,
		0.0)
	tween.interpolate_property(
		coin_mesh, 
		"rotation",
		coin_mesh.rotation,
		Vector3(.1, .1, .1),
		duration,
		tween.TRANS_SINE,
		tween.EASE_IN_OUT,
		0.0)
	tween.start()
	if area.get_parent().has_method("coin_collect"):
		area.get_parent().coin_collect()
	yield(get_tree().create_timer(duration), "timeout")
	queue_free()
	pass
