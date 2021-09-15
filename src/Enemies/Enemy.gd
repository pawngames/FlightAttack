extends PathFollow

signal enemy_down

export var health_max = 3
export var curve_movement:Curve

var enabled:bool = false

var curve_index:float = 0.0;
var start_v_offset:float = 0.0

func _ready():
	$ShipMesh/EnemySBody.connect("health_out", self, "_health_out_hits")
	start_v_offset = v_offset
	start(0.0)
	pass

func _process(delta):
	if enabled:
		offset += .4
		curve_index += .001
		var curve_val = curve_movement.interpolate(curve_index)
		v_offset = curve_val*30.0 + start_v_offset
	pass

func start(delay:float):
	$Timer.start(delay)

func _health_out_hits(param):
	emit_signal("enemy_down", null)
	pass

func _on_Timer_timeout():
	enabled = true
	visible = true
	pass

func _on_TimerFree_timeout():
	queue_free()
	pass
