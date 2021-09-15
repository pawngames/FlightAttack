extends PathFollow

enum States{
	ENTRANCE,
	IDLE,
	NEW_DIRECTION,
	MOVE,
	ATTACK_N,
	ATTACK_S
}

export var curve_up:Curve
export var curve_down:Curve

onready var cannon_body_left = $MovRef/boss_01_body/boss_01_body_canon
onready var cannon_body_right = $MovRef/boss_01_body/boss_01_body_canon2

var turret_dmg_enabled:bool = false

var state:int = States.ENTRANCE

var position:Vector3 = Vector3(0,0,0)
var direction:Vector3 = Vector3.LEFT
var positions:Array = []

var screen_limits_x = 51.2/4.0
var screen_limits_y = screen_limits_x*9/16

var player_pf:PathFollow


func _ready():
	for y in range (0, 3):
		for x in range (0, 3):
			positions.append(Vector3(x - 1, y - 1, 0)*11.5)
	randomize()
	_select_direction()
	$AnimationPlayer.play("Entrance")
	pass

func _process(delta):
	if is_instance_valid(player_pf):
		offset = player_pf.offset + 40
	
	if state == States.ENTRANCE:
		return
	
	if !turret_dmg_enabled and \
		!is_instance_valid(cannon_body_left) and \
		!is_instance_valid(cannon_body_right):
			turret_dmg_enabled = true
			$MovRef/boss_01_body.turret_dmg = true
			$MovRef/boss_01_body/boss_01_turret_body/TurretCol.collision_layer = 3
	if !is_instance_valid($MovRef/boss_01_body/boss_01_turret_body):
		$MovRef/boss_01_body/TankBody.collision_layer = 3
		
	match state:
		States.IDLE:
			pass
		States.MOVE:
			_move()
			pass
		States.NEW_DIRECTION:
			_select_direction()
			state = _choose([
				#States.IDLE,
				States.MOVE
			])
			pass
		States.ATTACK_N:
			if !turret_dmg_enabled:
				$MovRef/boss_01_body/TimerFSM.wait_time = 7.0
				$MovRef/boss_01_body.shot_body(cannon_body_left)
				$MovRef/boss_01_body.shot_body(cannon_body_right)
			else:
				state = States.ATTACK_S
			state = States.MOVE
			pass
		States.ATTACK_S:
			$MovRef/boss_01_body.shoot_missile()
			state = States.MOVE
			pass
	pass

func _move():
	$MovRef/boss_01_body.transform.origin = lerp(
		$MovRef/boss_01_body.transform.origin,
		position,
		.01
	)

func _select_direction():
	position = _choose(positions)
	pass

func _choose(array:Array):
	array.shuffle()
	return array.front()

func _on_TimerFSM_timeout():
	if state == States.ENTRANCE:
		return
	$MovRef/boss_01_body/TimerFSM.wait_time = _choose([
		0.5, 1.0, 1.5
	])
	_new_state()
	pass

func _new_state():
	state = _choose([
			States.IDLE,
			States.NEW_DIRECTION,
			States.MOVE,
			States.ATTACK_N,
			States.ATTACK_S,
		])
	print("state: " + str(state))

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Entrance".match(anim_name):
		state = States.IDLE
		$MovRef/boss_01_body.turret_enabled = true
	pass
