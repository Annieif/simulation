extends Node3D

func _ready():
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.1, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.5)
	env.ambient_light_energy = 1.0
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	var light = DirectionalLight3D.new()
	light.light_energy = 0.5
	light.position = Vector3(0, 10, 5)
	light.rotation = Vector3(deg_to_rad(50), deg_to_rad(20), 0)
	add_child(light)
	
	var splat = SplatRenderer.new()
	splat.load_ply("res://a.ply", 1.0)
	add_child(splat)
	
	await get_tree().idle_frame
	
	var min_pos = Vector3(INF, INF, INF)
	var max_pos = Vector3(-INF, -INF, -INF)
	var mesh = splat.mesh
	if mesh:
		var surface_count = mesh.get_surface_count()
		for s in range(surface_count):
			var positions = mesh.get_surface_arrays(s)[0]
			for p in positions:
				min_pos = min_pos.min(p + splat.position)
				max_pos = max_pos.max(p + splat.position)
	
	var center = (min_pos + max_pos) * 0.5
	var size = max_pos - min_pos
	
	# Floor collision
	var floor_body = StaticBody3D.new()
	floor_body.position = Vector3(center.x, min_pos.y, center.z)
	var floor_col = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(size.x, 0.2, size.z)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	add_child(floor_body)
	
	# Boundary walls (prevent falling off)
	var wall_thickness = 0.5
	var walls = [
		(Vector3(center.x, center.y, min_pos.z - wall_thickness * 0.5), Vector3(size.x, size.y, wall_thickness)),
		(Vector3(center.x, center.y, max_pos.z + wall_thickness * 0.5), Vector3(size.x, size.y, wall_thickness)),
		(Vector3(min_pos.x - wall_thickness * 0.5, center.y, center.z), Vector3(wall_thickness, size.y, size.z)),
		(Vector3(max_pos.x + wall_thickness * 0.5, center.y, center.z), Vector3(wall_thickness, size.y, size.z)),
	]
	
	for wall_pos, wall_size in walls:
		var wall_body = StaticBody3D.new()
		wall_body.position = wall_pos
		var wall_col = CollisionShape3D.new()
		var wall_shape = BoxShape3D.new()
		wall_shape.size = wall_size
		wall_col.shape = wall_shape
		wall_body.add_child(wall_col)
		add_child(wall_body)
	
	# Place player at center, 2 units above floor
	var player_scene = preload("res://Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(center.x, min_pos.y + 2.0, center.z)
	add_child(player)