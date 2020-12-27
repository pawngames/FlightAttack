extends Path

export var health_max = 3

signal enemy_down

func _ready():
	$EPathFollow/ShipMesh/EnemySBody.connect("health_out", self, "_health_out_hits")
	pass

func _process(delta):
	$EPathFollow.offset += .1
	pass

func _health_out_hits(param):
	emit_signal("enemy_down", null)
	pass
