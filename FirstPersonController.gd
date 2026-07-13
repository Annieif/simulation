class_name FirstPersonController
extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
const HEAD_BOB_FREQ = 1.5
const HEAD_BOB_AMP = 0.05

var gravity = 9.8
var t_bob = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# 重力
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 移动方向
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 速度（Shift加速）
	var speed = WALK_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 5)
	
	# 头部晃动
	_headbob(delta)
	
	move_and_slide()

func _headbob(delta):
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob_time(t_bob)

func _headbob_time(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEAD_BOB_FREQ) * HEAD_BOB_AMP
	pos.x = cos(time * HEAD_BOB_FREQ / 2) * HEAD_BOB_AMP
	return pos
