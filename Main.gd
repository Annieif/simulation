extends Node3D

func _ready():
	# 简单的环境光
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.1, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.5)
	env.ambient_light_energy = 1.0
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	# 方向光
	var light = DirectionalLight3D.new()
	light.light_energy = 0.5
	light.position = Vector3(0, 10, 5)
	light.rotation = Vector3(deg_to_rad(50), deg_to_rad(20), 0)
	add_child(light)
	
	# 地板（让玩家有东西站立）
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(100, 0.1, 100)
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.2, 0.2, 0.22)
	floor_mat.metallic = 0.5
	floor_mat.roughness = 0.5
	floor_mesh.material = floor_mat
	var floor_mi = MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	floor_mi.position = Vector3(0, -0.1, 0)
	add_child(floor_mi)
	
	var floor_col = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(100, 0.1, 100)
	floor_col.shape = floor_shape
	var floor_body = StaticBody3D.new()
	floor_body.position = Vector3(0, -0.1, 0)
	floor_body.add_child(floor_col)
	add_child(floor_body)
	
	# 测试立方体（验证渲染是否正常）
	var test_mesh = BoxMesh.new()
	test_mesh.size = Vector3(1, 1, 1)
	var test_mat = StandardMaterial3D.new()
	test_mat.albedo_color = Color(1.0, 0.0, 0.0)
	test_mesh.material = test_mat
	var test_mi = MeshInstance3D.new()
	test_mi.mesh = test_mesh
	test_mi.position = Vector3(3, 0.5, 0)
	add_child(test_mi)
	
	# 加载混元生成的 PLY 场景
	var splat = SplatRenderer.new()
	splat.load_ply("res://a.ply", 1.0)
	add_child(splat)
	
	# 加载玩家场景
	var player_scene = preload("res://Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(0, 2, 0)
	add_child(player)