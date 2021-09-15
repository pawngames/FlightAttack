extends MeshInstance

signal enemy_down

var angle:float = 0
var radius:float = 200
var delay_start:float = 3.0
var time_run:float = 7.0

func _ready():
	$ChaserBody.connect("health_out", self, "_health_out_hits")
	pass

func start(angle_s:float):
	angle = angle_s
	transform.origin.y = sin(angle*PI)*radius
	transform.origin.x = cos(angle*PI)*radius
	print(rad2deg(angle))
	$Tween.interpolate_property(
		self,
		"radius",
		radius,
		15,
		delay_start,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT,
		0.0
	)
	$Tween.interpolate_property(
		self,
		"angle",
		angle_s,
		(angle_s + 2*PI),
		time_run,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		delay_start
	)
	$Tween.interpolate_property(
		self,
		"translation",
		Vector3(0,0,0),
		Vector3(0,0,-2000),
		time_run,
		Tween.TRANS_QUINT,
		Tween.EASE_IN,
		delay_start
	)
	$Tween.interpolate_property(
		self,
		"rotation",
		Vector3(0,-PI,0),
		Vector3(0,-PI,5*PI),
		time_run,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT,
		delay_start
	)
	$Tween.start()

func _process(delta):
	get_parent().offset += 1.2
	transform.origin.y = sin(angle)*radius
	transform.origin.x = cos(angle)*radius
	pass

func _on_Timer_timeout():
	get_parent().queue_free()
	pass # Replace with function body.

func _health_out_hits(param):
	emit_signal("enemy_down", null)
	pass
