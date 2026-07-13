extends Node3D

func _ready():
	# 生成程序化场景
	var builder = ProceduralSceneBuilder.new()
	add_child(builder)
	
	# 创建玩家
	var player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1.6, 8)
	
	# 碰撞体
	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = 1.8
	shape.radius = 0.4
	col.shape = shape
	player.add_child(col)
	
	# 头部
	var head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 0.7, 0)
	player.add_child(head)
	
	# 摄像机
	var camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = 75
	camera.near = 0.05
	camera.far = 200
	head.add_child(camera)
	
	# 设置脚本
	player.set_script(load("res://FirstPersonController.gd"))
	
	add_child(player)
