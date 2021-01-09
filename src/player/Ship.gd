extends Spatial

onready var guide:Position3D = $Guide
onready var ship:Spatial = $ShipRef
onready var ship_body:Spatial = $ShipRef/ShipBody
onready var charged_ui = $Camera/UIViewport/UINode/Container/Charge
onready var dash_ui = $Camera/UIViewport/UINode/Container/Dash
onready var shield_ui = $Camera/UIViewport/UINode/Container/Shield

export var lateral_speed:float = 0.15
export var follow_speed:float = 0.03

export var h_limit:float = 10.0
export var v_limit:float = 7.0

export var CHARGE_MAX:int = 100
var charged:float = 0.0

export var DASH_MAX:int = 100
var dash:bool = false
var dash_accum:int = 0

export var SHIELD_MAX:int = 10
var shield:int = SHIELD_MAX

var first_pressed:Array = [false, false]
var first_press_ts:Array  = [0,0]

var target:Array = []

func _ready():
	charged_ui.max_value = CHARGE_MAX
	shield_ui.max_value = SHIELD_MAX
	$ShipRef/ShipBody.connect("player_hit", self, "player_hit")
	pass

func player_hit(param):
	shield -= 1
	$Camera/UIViewport/UINode/Container/Shield.value = shield
	pass

func set_enemy_count(count:int):
	$Camera/UIViewport/UINode.set_enemy_count(count)
	pass

func _process(delta):
	
	if Input.is_action_pressed("ui_dash"):
		if dash_accum > 0:
			dash = true
			dash_accum -= 2
		else:
			dash = false
	else:
		dash = false
		dash_accum += 1
	dash_ui.value = dash_accum
	dash_accum = clamp(dash_accum, 0, DASH_MAX)
	
	if ship_body.hit:
		guide.transform.origin = Vector3(0,0,0)
	
	if Input.is_action_pressed("ui_up") and \
		abs(guide.transform.origin.y) < v_limit:
		guide.transform.origin.y -= lateral_speed

	if Input.is_action_pressed("ui_down") and \
		abs(guide.transform.origin.y) < v_limit:
		guide.transform.origin.y += lateral_speed
	
	if Input.is_action_pressed("ui_left") and \
		abs(guide.transform.origin.x) < h_limit:
		guide.transform.origin.x -= lateral_speed
		if Input.is_action_pressed("ui_strafe_left"):
			print("strafe")
			guide.transform.origin.x -= lateral_speed

	if Input.is_action_pressed("ui_right") and \
		abs(guide.transform.origin.x) < h_limit:
		guide.transform.origin.x += lateral_speed
		if Input.is_action_pressed("ui_strafe_right"):
			guide.transform.origin.x += lateral_speed
	
	if Input.is_action_just_pressed("ui_accept"):
		ship_body.shoot()
	
	if Input.is_action_just_released("ui_accept") and charged == CHARGE_MAX:
		if target.size() > 0:
			for target_u in target:
				ship_body.shoot_missile(target_u)
			for lt in $Targets.get_children():
				lt.queue_free()
			target = []
		else:
			ship_body.shoot_missile(null)
		print("123")
		var mat:SpatialMaterial = $ShipRef/ShipBody/Aim_far.material_override
		mat.albedo_texture = load("res://assets/3d/textures/crosshair.png")
		$ShipRef/ShipBody/Aim_far.material_override = mat
	
	
	if Input.is_action_pressed("ui_accept"):
		charged += 1
		charged = clamp(charged, 0, CHARGE_MAX)
	else:
		target = []
		charged = 0
	
	if charged == CHARGE_MAX:
		var mat:SpatialMaterial = $ShipRef/ShipBody/Aim_far.material_override
		mat.albedo_texture = load("res://assets/3d/textures/crosshair_lock.png")
		$ShipRef/ShipBody/Aim_far.material_override = mat
	
	charged_ui.value = charged
	
	var left_shouder_double_press = _check_double_press(0)
	var right_shouder_double_press = _check_double_press(1)
	
	if abs(guide.transform.origin.x) <= h_limit:
		var value = Input.get_joy_axis(0, JOY_AXIS_0)*lateral_speed
		guide.transform.origin.x += value
		if Input.is_action_pressed("ui_strafe_left") and value < 0:
			guide.transform.origin.x += value
		if Input.is_action_pressed("ui_strafe_right") and value > 0:
			guide.transform.origin.x += value
	
	if abs(guide.transform.origin.y) <= v_limit:
		guide.transform.origin.y += Input.get_joy_axis(0, JOY_AXIS_1)*lateral_speed

	guide.transform.origin.x = clamp(guide.transform.origin.x, -h_limit, h_limit)
	guide.transform.origin.y = clamp(guide.transform.origin.y, -v_limit, v_limit)
	
	ship.look_at(guide.global_transform.origin, Vector3.DOWN)
	
	ship.transform.origin.x = lerp(
		ship.transform.origin.x, 
		guide.transform.origin.x,
		follow_speed)
	ship.transform.origin.y = lerp(
		ship.transform.origin.y, 
		guide.transform.origin.y,
		follow_speed)
	
	transform.origin.x = lerp(
		transform.origin.x, 
		-guide.transform.origin.x*2,
		follow_speed*2)
	transform.origin.y = lerp(
		transform.origin.y, 
		guide.transform.origin.y*2,
		follow_speed*2)
		
	ship.transform.origin.y = clamp(ship.transform.origin.y, -v_limit/1.5, v_limit/1.5)
	ship.transform.origin.x = clamp(ship.transform.origin.x, -h_limit/1.5, h_limit/1.5)
	
	var x_offset = ((ship.transform.origin - guide.transform.origin).x)
	var target_rot = ((PI/15)*x_offset) + PI
	ship.rotation.z = target_rot
	if Input.is_action_pressed("ui_strafe_left"):
		ship.rotation.z += target_rot*.05
	if Input.is_action_pressed("ui_strafe_right"):
		ship.rotation.z -= target_rot*.05
	
	ship_body.rotation = ship_body.rotation.linear_interpolate(Vector3(0,0,0), .5)
	
	guide.transform.origin.z = 0.0
	guide.transform.origin = guide.transform.origin.linear_interpolate(
			Vector3(0,0,0), 
			.01)
	pass

func _check_double_press(side:int):
	var side_str = "ui_strafe_right"
	if side == 0:
		side_str = "ui_strafe_left"
	if Input.is_action_just_pressed(side_str):
		print(first_pressed[side])
		if not first_pressed[side]:
			first_pressed[side] = true
			first_press_ts[side] = OS.get_ticks_msec()
		else:
			var second_press_ts = OS.get_ticks_msec()
			var dif = second_press_ts - first_press_ts[side]
			if abs(dif) < 1000:
				print("double press" + str(side))
				first_pressed[side] = false
				first_press_ts[side] = 0
				var rotation_now:Vector3 = ship_body.rotation
				var rotation_to:Vector3 = Vector3(
					rotation_now.x,
					rotation_now.y,
					rotation_now.z - 8*PI
				)
				if side == 0:
					rotation_to.z = rotation_now.z + 8*PI
				
				$Tween.interpolate_property(
					ship_body,
					"rotation",
					rotation_now,
					rotation_to,
					.8,
					$Tween.TRANS_SINE,
					$Tween.EASE_IN_OUT,
					0.0
				)
				$Tween.start()
			else:
				print("clear_state")
				first_pressed[side] = false
				first_press_ts[side] = 0
	else:
		var second_press_ts = OS.get_ticks_msec()
		var dif = second_press_ts - first_press_ts[side]
		if abs(dif) > 1000:
			first_pressed[side] = false
			first_press_ts[side] = 0

func _on_AreaAim_body_entered(body):
	if Input.is_action_pressed("ui_accept") and charged == CHARGE_MAX:
		if target.find(body, 0) == -1:
			target.append(body)
			var ltarg_scene = load("res://src/player/weapons/LockedTarget.tscn").duplicate(true)
			var ltarg = ltarg_scene.instance()
			$Targets.add_child(ltarg)
			ltarg.lock_target(body)
	pass
