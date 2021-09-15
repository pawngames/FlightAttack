extends Spatial

signal player_down
signal pause_pressed

var ltarg_scene = load("res://src/player/weapons/LockedTarget.tscn")

onready var guide:Position3D = $Guide
onready var ship:Spatial = $ShipRef
onready var ship_body:Spatial = $ShipRef/ShipBody
onready var charged_ui = $CameraAnchor/Camera/UINode/CntLeft/HBCharge/Charge
onready var dash_ui = $CameraAnchor/Camera/UINode/CntLeft/HBDash/Dash
onready var shield_ui = $CameraAnchor/Camera/UINode/CntLeft/HBShield/Shield

export var lateral_speed:float = 0.17
export var follow_speed:float = 0.05

export var h_limit:float = 6.0
export var v_limit:float = 4.0

export var CHARGE_MAX:int = 100
var charged:float = 0.0

export var DASH_MAX:int = 100
var dash:bool = false
var dash_accum:int = 0

export var SHIELD_MAX:int = 10
var shield:int = SHIELD_MAX
var coins:int = 0

var first_pressed:Array = [false, false]
var first_press_ts:Array  = [0,0]
var b_roll_enabled:bool = true

var target:Array = []

var enabled = false
var destroyed = false

var m_sway:float = 0.0

func _ready():
	charged_ui.max_value = CHARGE_MAX
	shield_ui.max_value = SHIELD_MAX
	$ShipRef/ShipBody.connect("player_hit", self, "player_hit")
	$ShipRef/ShipBody.connect("coin_collected", self, "coin_collected")
	$ShipRef/ShipBody.connect("health_collected", self, "health_collected")
	pass

func player_hit(param):
	shield -= 1
	shield_ui.value = shield
	if shield <= 0:
		enabled = false
		$ShipRef/ShipBody/Area.collision_layer = 0
		emit_signal("player_down")
	pass

func coin_collected():
	coins += 1
	set_coin_count(coins)
	pass

func health_collected(amount:int):
	shield += amount
	shield_ui.value = shield
	if shield >= SHIELD_MAX:
		shield = SHIELD_MAX
	pass

func set_enemy_count(count:int):
	$CameraAnchor/Camera/UINode.set_enemy_count(count)
	pass

func set_coin_count(count:int):
	$CameraAnchor/Camera/UINode.set_coin_count(count)
	pass

func _process(delta):
	if enabled:
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
				#for lt in $Targets.get_children():
				#	lt.queue_free()
				target = []
			else:
				ship_body.shoot_missile(null)
			var mat:SpatialMaterial = $ShipRef/AreaAim/Aim_far.material_override
			mat.albedo_texture = load("res://assets/3d/textures/crosshair.png")
			$ShipRef/AreaAim/Aim_far.material_override = mat
		
		
		if Input.is_action_pressed("ui_accept"):
			charged += 1
			charged = clamp(charged, 0, CHARGE_MAX)
		else:
			target = []
			charged = 0

		$ShipRef/AreaAim/CollisionShape3.disabled = !(charged == CHARGE_MAX)
		if charged == CHARGE_MAX:
			var mat:SpatialMaterial = $ShipRef/AreaAim/Aim_far.material_override
			mat.albedo_texture = load("res://assets/3d/textures/crosshair_lock.png")
			$ShipRef/AreaAim/Aim_far.material_override = mat
		
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
		
		#ship.look_at(guide.global_transform.origin, Vector3.DOWN)
		var direction = ship.global_transform.origin.direction_to(
			guide.global_transform.origin
		)
		ship.rotation.x = asin(direction.y)
		ship.rotation.y = asin(direction.x)
		
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
		var target_rot = ((PI/10)*x_offset) + PI
		var amount = 0.25
		if Input.is_action_pressed("ui_strafe_left"):
			target_rot = lerp(target_rot, target_rot*(1 + amount), 0.1)
		if Input.is_action_pressed("ui_strafe_right"):
			target_rot = lerp(target_rot, target_rot*(1 - amount), 0.1)
		ship.rotation.z = lerp_angle(ship.rotation.z, target_rot, 0.05)
		
		var val_back = 0.5
		if Input.get_joy_axis(0, JOY_AXIS_0) > 0 or \
		   Input.get_joy_axis(0, JOY_AXIS_1) > 0:
			val_back = 0.0
		guide.transform.origin.z = 0.0
		guide.transform.origin = guide.transform.origin.linear_interpolate(
				Vector3(ship.transform.origin.x, ship.transform.origin.y, 0.0), 
				.05)
		
		m_sway += 0.01
		ship_body.transform.origin.x = sin(m_sway*PI)*0.5
		ship_body.transform.origin.y = cos(m_sway*PI)*0.5/2.3
		
		var camera_follow:bool = true
		if camera_follow:
			$CameraAnchor.global_transform.origin = lerp(
				$CameraAnchor.global_transform.origin,
				Vector3(
					ship.global_transform.origin.x,
					ship.global_transform.origin.y,
					ship.global_transform.origin.z
					),
				.05
			)
			
			$CameraAnchor.rotation.y = lerp_angle($CameraAnchor.rotation.y, 0, .05)
			$CameraAnchor/Camera.rotation.z = lerp_angle(
					$CameraAnchor/Camera.rotation.z,
					ship.rotation.z + PI,
					0.1
				)
		$CameraAnchor/Camera.current = camera_follow
		$ShipRef/ShipBody/Camera.current = !camera_follow
	else:
		$CameraAnchor.rotation.y += PI/100.0
		if shield == 0:
			get_parent().v_offset -= .2
		if shield < 0 and not destroyed:
			destroyed = true
			$ShipRef/ShipBody.destroyed = true
			$CameraAnchor/Camera.transform.origin.y = lerp(
				$CameraAnchor/Camera.transform.origin.y,
				15.0,
				.5
			)
			$CameraAnchor/Camera.transform.origin.z = lerp(
				$CameraAnchor/Camera.transform.origin.z,
				55.0,
				.5
			)
			$CameraAnchor/Camera.look_at($CameraAnchor.global_transform.origin, Vector3.UP)
			$Explosion.emitting = true
			#está desaparecendo antes
			visible = false
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
				
				if b_roll_enabled:
					b_roll_enabled = false
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
					$Tween.connect("tween_all_completed", self, "roll_enabled")
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

func roll_enabled():
	b_roll_enabled = true
	pass

func _on_AreaAim_body_entered(body):
	if Input.is_action_pressed("ui_accept") and charged == CHARGE_MAX:
		if target.find(body.get_node("LockedTarget"), 0) == -1:
			var ltarg:MeshInstance = ltarg_scene.duplicate(true).instance()
			body.add_child(ltarg)
			ltarg.lock_target(body)
			target.append(ltarg)
	pass

func _on_Timer_timeout():
	enabled = true
	$CameraAnchor/Camera/UINode/Center/VBox/LabelMsg.visible = false
	pass # Replace with function body.
