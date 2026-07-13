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
	
	var player_scene = preload("res://Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(center.x, center.y, center.z)
	add_child(player)