extends MeshInstance

func _ready():
	pass

func _on_Timer_timeout():
	queue_free()
	pass
