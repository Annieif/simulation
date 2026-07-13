class_name ProceduralSceneBuilder
extends Node3D

func _ready():
	# 生成整个场景
	_generate_floor()
	_generate_walls()
	_generate_ceiling()
	_generate_lighting()
	_generate_pillars()
	_generate_screens()
	_generate_corridor()
	_generate_details()

func _generate_floor():
	# 主房间地板 - 大网格金属地板
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(40, 0.2, 40)
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.15, 0.16, 0.18)
	floor_mat.metallic = 0.8
	floor_mat.roughness = 0.4
	floor_mesh.material = floor_mat
	var floor_mi = MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	floor_mi.position = Vector3(0, -0.1, 0)
	add_child(floor_mi)
	
	# 添加地板网格线条装饰
	for i in range(-20, 21, 4):
		var line_mesh = BoxMesh.new()
		line_mesh.size = Vector3(0.05, 0.22, 40)
		var line_mat = StandardMaterial3D.new()
		line_mat.albedo_color = Color(0.08, 0.3, 0.45)
		line_mat.emission_enabled = true
		line_mat.emission = Color(0.08, 0.3, 0.45)
		line_mat.emission_energy_multiplier = 0.5
		line_mesh.material = line_mat
		var line_mi = MeshInstance3D.new()
		line_mi.mesh = line_mesh
		line_mi.position = Vector3(i, 0.01, 0)
		add_child(line_mi)
	
	for j in range(-20, 21, 4):
		var line_mesh = BoxMesh.new()
		line_mesh.size = Vector3(40, 0.22, 0.05)
		var line_mat = StandardMaterial3D.new()
		line_mat.albedo_color = Color(0.08, 0.3, 0.45)
		line_mat.emission_enabled = true
		line_mat.emission = Color(0.08, 0.3, 0.45)
		line_mat.emission_energy_multiplier = 0.5
		line_mesh.material = line_mat
		var line_mi = MeshInstance3D.new()
		line_mi.mesh = line_mesh
		line_mi.position = Vector3(0, 0.01, j)
		add_child(line_mi)

func _generate_walls():
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.22, 0.23, 0.26)
	wall_mat.metallic = 0.6
	wall_mat.roughness = 0.5
	
	# 四面墙
	var walls = [
		# 前墙 (z=-20)
		{"pos": Vector3(0, 3, -20), "size": Vector3(40, 6, 0.3)},
		# 后墙 (z=20)
		{"pos": Vector3(0, 3, 20), "size": Vector3(40, 6, 0.3)},
		# 左墙 (x=-20)
		{"pos": Vector3(-20, 3, 0), "size": Vector3(0.3, 6, 40)},
		# 右墙 (x=20)
		{"pos": Vector3(20, 3, 0), "size": Vector3(0.3, 6, 40)},
	]
	
	for w in walls:
		var mesh = BoxMesh.new()
		mesh.size = w["size"]
		mesh.material = wall_mat
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = w["pos"]
		add_child(mi)
		
		# 添加碰撞体
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = w["size"]
		col.shape = shape
		var body = StaticBody3D.new()
		body.position = w["pos"]
		body.add_child(col)
		add_child(body)
	
	# 墙壁发光装饰条
	for w in walls:
		var strip_mesh = BoxMesh.new()
		strip_mesh.size = Vector3(w["size"].x if w["size"].x > 1 else 0.1, 0.15, w["size"].z if w["size"].z > 1 else 0.1)
		var strip_mat = StandardMaterial3D.new()
		strip_mat.albedo_color = Color(0.0, 0.6, 1.0)
		strip_mat.emission_enabled = true
		strip_mat.emission = Color(0.0, 0.6, 1.0)
		strip_mat.emission_energy_multiplier = 2.0
		strip_mesh.material = strip_mat
		var strip_mi = MeshInstance3D.new()
		strip_mi.mesh = strip_mesh
		strip_mi.position = w["pos"] + Vector3(0, 2.5, 0)
		add_child(strip_mi)

func _generate_ceiling():
	# 天花板
	var ceil_mesh = BoxMesh.new()
	ceil_mesh.size = Vector3(40, 0.2, 40)
	var ceil_mat = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.12, 0.13, 0.14)
	ceil_mat.metallic = 0.3
	ceil_mat.roughness = 0.7
	ceil_mesh.material = ceil_mat
	var ceil_mi = MeshInstance3D.new()
	ceil_mi.mesh = ceil_mesh
	ceil_mi.position = Vector3(0, 6, 0)
	add_child(ceil_mi)
	
	# 天花板横梁
	var beam_mat = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.1, 0.1, 0.12)
	beam_mat.metallic = 0.5
	beam_mat.roughness = 0.6
	
	for i in range(-16, 17, 8):
		var beam_mesh = BoxMesh.new()
		beam_mesh.size = Vector3(0.4, 0.6, 40)
		beam_mesh.material = beam_mat
		var beam_mi = MeshInstance3D.new()
		beam_mi.mesh = beam_mesh
		beam_mi.position = Vector3(i, 5.7, 0)
		add_child(beam_mi)

func _generate_lighting():
	# 环境光
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.15, 0.18, 0.22)
	env.ambient_light_energy = 0.3
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.08, 0.12)
	env.fog_density = 0.02
	
	var cam_env = WorldEnvironment.new()
	cam_env.environment = env
	add_child(cam_env)
	
	# 主灯光 - 房间中央
	var main_light = DirectionalLight3D.new()
	main_light.light_energy = 0.4
	main_light.position = Vector3(0, 10, 0)
	main_light.rotation = Vector3(deg_to_rad(45), 0, 0)
	add_child(main_light)
	
	# 点光源 - 照亮各个角落
	var light_positions = [
		Vector3(-12, 5, -12), Vector3(12, 5, -12),
		Vector3(-12, 5, 12), Vector3(12, 5, 12),
		Vector3(0, 5, 0)
	]
	
	for pos in light_positions:
		var light = OmniLight3D.new()
		light.position = pos
		light.light_color = Color(0.6, 0.75, 1.0)
		light.light_energy = 1.5
		light.omni_range = 15
		light.omni_attenuation = 1.2
		light.shadow_enabled = true
		add_child(light)

func _generate_pillars():
	# 四角柱子
	var pillar_mat = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.18, 0.19, 0.22)
	pillar_mat.metallic = 0.7
	pillar_mat.roughness = 0.4
	
	var positions = [
		Vector3(-15, 3, -15), Vector3(15, 3, -15),
		Vector3(-15, 3, 15), Vector3(15, 3, 15)
	]
	
	for pos in positions:
		# 柱身
		var mesh = BoxMesh.new()
		mesh.size = Vector3(1.2, 6, 1.2)
		mesh.material = pillar_mat
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = pos
		add_child(mi)
		
		# 碰撞体
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1.2, 6, 1.2)
		col.shape = shape
		var body = StaticBody3D.new()
		body.position = pos
		body.add_child(col)
		add_child(body)
		
		# 柱子发光条
		var strip_mesh = BoxMesh.new()
		strip_mesh.size = Vector3(1.25, 0.1, 1.25)
		var strip_mat = StandardMaterial3D.new()
		strip_mat.albedo_color = Color(0.0, 0.8, 1.0)
		strip_mat.emission_enabled = true
		strip_mat.emission = Color(0.0, 0.8, 1.0)
		strip_mat.emission_energy_multiplier = 3.0
		strip_mesh.material = strip_mat
		var strip_mi = MeshInstance3D.new()
		strip_mi.mesh = strip_mesh
		strip_mi.position = pos + Vector3(0, 2, 0)
		add_child(strip_mi)

func _generate_screens():
	# 大屏幕 - 前墙
	var screen_mesh = PlaneMesh.new()
	screen_mesh.size = Vector2(8, 4)
	var screen_mat = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.05, 0.15, 0.25)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.0, 0.3, 0.6)
	screen_mat.emission_energy_multiplier = 1.5
	screen_mat.metallic = 0.2
	screen_mat.roughness = 0.3
	screen_mesh.material = screen_mat
	var screen_mi = MeshInstance3D.new()
	screen_mi.mesh = screen_mesh
	screen_mi.position = Vector3(0, 3, -19.8)
	screen_mi.rotation = Vector3(deg_to_rad(90), 0, 0)
	add_child(screen_mi)
	
	# 屏幕边框
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.1, 0.1, 0.12)
	frame_mat.metallic = 0.8
	frame_mat.roughness = 0.3
	
	# 控制台
	var console_mat = StandardMaterial3D.new()
	console_mat.albedo_color = Color(0.2, 0.2, 0.23)
	console_mat.metallic = 0.6
	console_mat.roughness = 0.5
	
	# 中央控制台
	var console_mesh = BoxMesh.new()
	console_mesh.size = Vector3(4, 1, 2)
	console_mesh.material = console_mat
	var console_mi = MeshInstance3D.new()
	console_mi.mesh = console_mesh
	console_mi.position = Vector3(0, 0.5, -8)
	add_child(console_mi)
	
	# 控制台碰撞体
	var console_col = CollisionShape3D.new()
	var console_shape = BoxShape3D.new()
	console_shape.size = Vector3(4, 1, 2)
	console_col.shape = console_shape
	var console_body = StaticBody3D.new()
	console_body.position = Vector3(0, 0.5, -8)
	console_body.add_child(console_col)
	add_child(console_body)
	
	# 控制台发光面板
	var panel_mesh = BoxMesh.new()
	panel_mesh.size = Vector3(3.5, 0.05, 1.5)
	var panel_mat = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.0, 0.5, 0.8)
	panel_mat.emission_enabled = true
	panel_mat.emission = Color(0.0, 0.5, 0.8)
	panel_mat.emission_energy_multiplier = 2.0
	panel_mesh.material = panel_mat
	var panel_mi = MeshInstance3D.new()
	panel_mi.mesh = panel_mesh
	panel_mi.position = Vector3(0, 1.05, -8)
	add_child(panel_mi)

func _generate_corridor():
	# 走廊 - 从右墙延伸出去
	var corridor_mat = StandardMaterial3D.new()
	corridor_mat.albedo_color = Color(0.18, 0.19, 0.2)
	corridor_mat.metallic = 0.5
	corridor_mat.roughness = 0.5
	
	# 走廊地板
	var corr_floor_mesh = BoxMesh.new()
	corr_floor_mesh.size = Vector3(20, 0.2, 6)
	corr_floor_mesh.material = corridor_mat
	var corr_floor_mi = MeshInstance3D.new()
	corr_floor_mi.mesh = corr_floor_mesh
	corr_floor_mi.position = Vector3(30, -0.1, 0)
	add_child(corr_floor_mi)
	
	# 走廊天花板
	var corr_ceil_mesh = BoxMesh.new()
	corr_ceil_mesh.size = Vector3(20, 0.2, 6)
	corr_ceil_mesh.material = corridor_mat
	var corr_ceil_mi = MeshInstance3D.new()
	corr_ceil_mi.mesh = corr_ceil_mesh
	corr_ceil_mi.position = Vector3(30, 6, 0)
	add_child(corr_ceil_mi)
	
	# 走廊墙壁
	var corr_walls = [
		{"pos": Vector3(30, 3, -3), "size": Vector3(20, 6, 0.3)},
		{"pos": Vector3(30, 3, 3), "size": Vector3(20, 6, 0.3)},
	]
	
	for w in corr_walls:
		var mesh = BoxMesh.new()
		mesh.size = w["size"]
		mesh.material = corridor_mat
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = w["pos"]
		add_child(mi)
		
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = w["size"]
		col.shape = shape
		var body = StaticBody3D.new()
		body.position = w["pos"]
		body.add_child(col)
		add_child(body)
	
	# 走廊窗户
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.3, 0.5, 0.7)
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.2, 0.4, 0.6)
	window_mat.emission_energy_multiplier = 0.8
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_mat.albedo_color.a = 0.5
	
	for i in range(5):
		var win_mesh = BoxMesh.new()
		win_mesh.size = Vector3(2, 3, 0.1)
		win_mesh.material = window_mat
		var win_mi = MeshInstance3D.new()
		win_mi.mesh = win_mesh
		win_mi.position = Vector3(24 + i * 3, 3, -2.8)
		add_child(win_mi)
	
	# 走廊灯光
	for i in range(4):
		var light = OmniLight3D.new()
		light.position = Vector3(24 + i * 4, 5, 0)
		light.light_color = Color(0.5, 0.7, 1.0)
		light.light_energy = 1.0
		light.omni_range = 8
		add_child(light)
	
	# 走廊发光地条
	for i in range(-2, 3):
		var strip_mesh = BoxMesh.new()
		strip_mesh.size = Vector3(0.1, 0.02, 5)
		var strip_mat = StandardMaterial3D.new()
		strip_mat.albedo_color = Color(0.0, 0.6, 1.0)
		strip_mat.emission_enabled = true
		strip_mat.emission = Color(0.0, 0.6, 1.0)
		strip_mat.emission_energy_multiplier = 2.0
		strip_mesh.material = strip_mat
		var strip_mi = MeshInstance3D.new()
		strip_mi.mesh = strip_mesh
		strip_mi.position = Vector3(25 + i * 4, 0.02, 0)
		add_child(strip_mi)

func _generate_details():
	# 管道装饰
	var pipe_mat = StandardMaterial3D.new()
	pipe_mat.albedo_color = Color(0.25, 0.2, 0.15)
	pipe_mat.metallic = 0.8
	pipe_mat.roughness = 0.4
	
	# 天花板管道
	for i in range(-12, 13, 8):
		var pipe_mesh = CylinderMesh.new()
		pipe_mesh.height = 36
		pipe_mesh.top_radius = 0.2
		pipe_mesh.bottom_radius = 0.2
		pipe_mesh.material = pipe_mat
		var pipe_mi = MeshInstance3D.new()
		pipe_mi.mesh = pipe_mesh
		pipe_mi.position = Vector3(i, 5.5, 0)
		pipe_mi.rotation = Vector3(deg_to_rad(90), 0, 0)
		add_child(pipe_mi)
	
	# 箱子/货物
	var box_mat = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.3, 0.25, 0.15)
	box_mat.metallic = 0.3
	box_mat.roughness = 0.7
	
	var box_positions = [
		Vector3(-10, 0.5, 10), Vector3(-10, 1.5, 10), Vector3(-9, 0.5, 10),
		Vector3(10, 0.5, -10), Vector3(10, 1.5, -10),
		Vector3(-8, 0.5, -12), Vector3(-7, 0.5, -12)
	]
	
	for pos in box_positions:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		box_mesh.material = box_mat
		var box_mi = MeshInstance3D.new()
		box_mi.mesh = box_mesh
		box_mi.position = pos
		add_child(box_mi)
		
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1, 1, 1)
		col.shape = shape
		var body = StaticBody3D.new()
		body.position = pos
		body.add_child(col)
		add_child(body)
	
	# 发光警示灯
	var warn_positions = [Vector3(-19, 5.5, -19), Vector3(19, 5.5, -19), Vector3(-19, 5.5, 19), Vector3(19, 5.5, 19)]
	for pos in warn_positions:
		var warn_mesh = SphereMesh.new()
		warn_mesh.radius = 0.2
		warn_mesh.height = 0.4
		var warn_mat = StandardMaterial3D.new()
		warn_mat.albedo_color = Color(1.0, 0.2, 0.0)
		warn_mat.emission_enabled = true
		warn_mat.emission = Color(1.0, 0.2, 0.0)
		warn_mat.emission_energy_multiplier = 3.0
		warn_mesh.material = warn_mat
		var warn_mi = MeshInstance3D.new()
		warn_mi.mesh = warn_mesh
		warn_mi.position = pos
		add_child(warn_mi)
		
		var warn_light = OmniLight3D.new()
		warn_light.position = pos
		warn_light.light_color = Color(1.0, 0.3, 0.0)
		warn_light.light_energy = 0.5
		warn_light.omni_range = 5
		add_child(warn_light)
