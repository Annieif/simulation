class_name ProceduralSceneBuilder
extends Node3D

func _ready():
	_generate_floor()
	_generate_walls()
	_generate_ceiling()
	_generate_lighting()
	_generate_pillars()
	_generate_screen_wall()
	_generate_corridor()

func _generate_floor():
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.12, 0.11, 0.10)
	floor_mat.metallic = 0.7
	floor_mat.roughness = 0.5
	
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(30, 0.15, 30)
	floor_mesh.material = floor_mat
	var floor_mi = MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	floor_mi.position = Vector3(0, -0.075, 0)
	add_child(floor_mi)
	
	var floor_col = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(30, 0.15, 30)
	floor_col.shape = floor_shape
	var floor_body = StaticBody3D.new()
	floor_body.position = Vector3(0, -0.075, 0)
	floor_body.add_child(floor_col)
	add_child(floor_body)
	
	for i in range(-14, 15, 2):
		var grid_mesh = BoxMesh.new()
		grid_mesh.size = Vector3(0.03, 0.17, 30)
		var grid_mat = StandardMaterial3D.new()
		grid_mat.albedo_color = Color(0.25, 0.20, 0.15)
		grid_mat.metallic = 0.8
		grid_mat.roughness = 0.6
		grid_mesh.material = grid_mat
		var grid_mi = MeshInstance3D.new()
		grid_mi.mesh = grid_mesh
		grid_mi.position = Vector3(i, 0, 0)
		add_child(grid_mi)
	
	for j in range(-14, 15, 2):
		var grid_mesh = BoxMesh.new()
		grid_mesh.size = Vector3(30, 0.17, 0.03)
		var grid_mat = StandardMaterial3D.new()
		grid_mat.albedo_color = Color(0.25, 0.20, 0.15)
		grid_mat.metallic = 0.8
		grid_mat.roughness = 0.6
		grid_mesh.material = grid_mat
		var grid_mi = MeshInstance3D.new()
		grid_mi.mesh = grid_mesh
		grid_mi.position = Vector3(0, 0, j)
		add_child(grid_mi)
	
	for i in range(-15, 16, 10):
		for j in range(-15, 16, 10):
			if i != 0 or j != 0:
				var stripe_mesh = BoxMesh.new()
				stripe_mesh.size = Vector3(0.8, 0.02, 0.8)
				var stripe_mat = StandardMaterial3D.new()
				stripe_mat.albedo_color = Color(0.8, 0.5, 0.1)
				stripe_mat.emission_enabled = true
				stripe_mat.emission = Color(0.8, 0.5, 0.1)
				stripe_mat.emission_energy_multiplier = 0.5
				stripe_mesh.material = stripe_mat
				var stripe_mi = MeshInstance3D.new()
				stripe_mi.mesh = stripe_mesh
				stripe_mi.position = Vector3(i, 0.02, j)
				add_child(stripe_mi)

func _generate_walls():
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.18, 0.16, 0.14)
	wall_mat.metallic = 0.5
	wall_mat.roughness = 0.6
	
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.25, 0.22, 0.18)
	frame_mat.metallic = 0.7
	frame_mat.roughness = 0.5
	
	var walls = [
		{"pos": Vector3(0, 3, -15), "size": Vector3(30, 6, 0.4), "type": "front"},
		{"pos": Vector3(0, 3, 15), "size": Vector3(30, 6, 0.4), "type": "back"},
		{"pos": Vector3(-15, 3, 0), "size": Vector3(0.4, 6, 30), "type": "left"},
		{"pos": Vector3(15, 3, 0), "size": Vector3(0.4, 6, 30), "type": "right"},
	]
	
	for w in walls:
		var mesh = BoxMesh.new()
		mesh.size = w["size"]
		mesh.material = wall_mat
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
	
	for w in walls:
		var sx = w["size"].x
		var sz = w["size"].z
		var px = w["pos"].x
		var pz = w["pos"].z
		
		var frame_size_x = sx if sx > 1 else 0.1
		var frame_size_z = sz if sz > 1 else 0.1
		
		var frame_top = BoxMesh.new()
		frame_top.size = Vector3(frame_size_x, 0.2, 0.2)
		frame_top.material = frame_mat
		var ft_mi = MeshInstance3D.new()
		ft_mi.mesh = frame_top
		ft_mi.position = Vector3(px, 5.9, pz)
		add_child(ft_mi)
		
		var frame_bottom = BoxMesh.new()
		frame_bottom.size = Vector3(frame_size_x, 0.2, 0.2)
		frame_bottom.material = frame_mat
		var fb_mi = MeshInstance3D.new()
		fb_mi.mesh = frame_bottom
		fb_mi.position = Vector3(px, 0.1, pz)
		add_child(fb_mi)
		
		if sx > sz:
			for i in range(-12, 13, 8):
				var frame_vert = BoxMesh.new()
				frame_vert.size = Vector3(0.2, 6, 0.2)
				frame_vert.material = frame_mat
				var fv_mi = MeshInstance3D.new()
				fv_mi.mesh = frame_vert
				fv_mi.position = Vector3(px + i, 3, pz)
				add_child(fv_mi)
		else:
			for j in range(-12, 13, 8):
				var frame_vert = BoxMesh.new()
				frame_vert.size = Vector3(0.2, 6, 0.2)
				frame_vert.material = frame_mat
				var fv_mi = MeshInstance3D.new()
				fv_mi.mesh = frame_vert
				fv_mi.position = Vector3(px, 3, pz + j)
				add_child(fv_mi)

func _generate_ceiling():
	var ceil_mat = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.10, 0.09, 0.08)
	ceil_mat.metallic = 0.3
	ceil_mat.roughness = 0.7
	
	var ceil_mesh = BoxMesh.new()
	ceil_mesh.size = Vector3(30, 0.15, 30)
	ceil_mesh.material = ceil_mat
	var ceil_mi = MeshInstance3D.new()
	ceil_mi.mesh = ceil_mesh
	ceil_mi.position = Vector3(0, 6, 0)
	add_child(ceil_mi)
	
	var beam_mat = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.15, 0.13, 0.10)
	beam_mat.metallic = 0.5
	beam_mat.roughness = 0.6
	
	for i in range(-12, 13, 8):
		var beam_mesh = BoxMesh.new()
		beam_mesh.size = Vector3(0.6, 0.4, 30)
		beam_mesh.material = beam_mat
		var beam_mi = MeshInstance3D.new()
		beam_mi.mesh = beam_mesh
		beam_mi.position = Vector3(i, 5.7, 0)
		add_child(beam_mi)
	
	for i in range(-12, 13, 8):
		var light_mesh = BoxMesh.new()
		light_mesh.size = Vector3(0.1, 0.05, 6)
		var light_mat = StandardMaterial3D.new()
		light_mat.albedo_color = Color(0.6, 0.65, 0.7)
		light_mat.emission_enabled = true
		light_mat.emission = Color(0.6, 0.65, 0.7)
		light_mat.emission_energy_multiplier = 0.8
		light_mesh.material = light_mat
		var light_mi = MeshInstance3D.new()
		light_mi.mesh = light_mesh
		light_mi.position = Vector3(i, 5.95, 0)
		add_child(light_mi)

func _generate_lighting():
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.02, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.32, 0.35)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.08, 0.06, 0.04)
	env.fog_density = 0.015
	
	var cam_env = WorldEnvironment.new()
	cam_env.environment = env
	add_child(cam_env)
	
	var main_light = DirectionalLight3D.new()
	main_light.light_energy = 0.3
	main_light.position = Vector3(0, 10, 5)
	main_light.rotation = Vector3(deg_to_rad(60), deg_to_rad(10), 0)
	add_child(main_light)
	
	var light_positions = [
		Vector3(-10, 5, -10), Vector3(10, 5, -10),
		Vector3(-10, 5, 10), Vector3(10, 5, 10),
		Vector3(0, 5, 0)
	]
	
	for pos in light_positions:
		var light = OmniLight3D.new()
		light.position = pos
		light.light_color = Color(0.6, 0.55, 0.5)
		light.light_energy = 1.2
		light.omni_range = 20
		light.omni_attenuation = 1.2
		light.shadow_enabled = true
		add_child(light)

func _generate_pillars():
	var pillar_mat = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.22, 0.20, 0.17)
	pillar_mat.metallic = 0.6
	pillar_mat.roughness = 0.5
	
	var positions = [
		Vector3(-12, 3, -12), Vector3(12, 3, -12),
		Vector3(-12, 3, 12), Vector3(12, 3, 12)
	]
	
	for pos in positions:
		var mesh = BoxMesh.new()
		mesh.size = Vector3(1, 6, 1)
		mesh.material = pillar_mat
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = pos
		add_child(mi)
		
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1, 6, 1)
		col.shape = shape
		var body = StaticBody3D.new()
		body.position = pos
		body.add_child(col)
		add_child(body)
		
		var cap_mesh = BoxMesh.new()
		cap_mesh.size = Vector3(1.1, 0.15, 1.1)
		var cap_mat = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.3, 0.27, 0.22)
		cap_mat.metallic = 0.7
		cap_mat.roughness = 0.5
		cap_mesh.material = cap_mat
		
		var cap_top = MeshInstance3D.new()
		cap_top.mesh = cap_mesh
		cap_top.position = pos + Vector3(0, 2.9, 0)
		add_child(cap_top)
		
		var cap_bottom = MeshInstance3D.new()
		cap_bottom.mesh = cap_mesh
		cap_bottom.position = pos + Vector3(0, -2.9, 0)
		add_child(cap_bottom)

func _generate_screen_wall():
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.3, 0.27, 0.22)
	frame_mat.metallic = 0.8
	frame_mat.roughness = 0.5
	
	var screen_frame_outer = BoxMesh.new()
	screen_frame_outer.size = Vector3(14, 8, 0.3)
	screen_frame_outer.material = frame_mat
	var sfo_mi = MeshInstance3D.new()
	sfo_mi.mesh = screen_frame_outer
	sfo_mi.position = Vector3(0, 4, -14.85)
	add_child(sfo_mi)
	
	var screen_frame_inner = BoxMesh.new()
	screen_frame_inner.size = Vector3(10, 5, 0.35)
	screen_frame_inner.material = frame_mat
	var sfi_mi = MeshInstance3D.new()
	sfi_mi.mesh = screen_frame_inner
	sfi_mi.position = Vector3(0, 3, -14.65)
	add_child(sfi_mi)
	
	var glass_mesh = BoxMesh.new()
	glass_mesh.size = Vector3(9, 4.5, 0.08)
	var glass_mat = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.1, 0.15, 0.2)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.albedo_color.a = 0.35
	glass_mat.metallic = 0.2
	glass_mat.roughness = 0.15
	glass_mat.uv1_scale = Vector3(1, 1, 1)
	glass_mesh.material = glass_mat
	var glass_mi = MeshInstance3D.new()
	glass_mi.mesh = glass_mesh
	glass_mi.position = Vector3(0, 3, -14.5)
	add_child(glass_mi)
	
	for i in range(-6, 7, 6):
		for j in range(0, 6, 3):
			var panel_mesh = BoxMesh.new()
			panel_mesh.size = Vector3(1.5, 0.8, 0.2)
			var panel_mat = StandardMaterial3D.new()
			panel_mat.albedo_color = Color(0.18, 0.16, 0.14)
			panel_mat.metallic = 0.6
			panel_mat.roughness = 0.5
			panel_mesh.material = panel_mat
			var panel_mi = MeshInstance3D.new()
			panel_mi.mesh = panel_mesh
			panel_mi.position = Vector3(8 + i, 1 + j, -14.7)
			add_child(panel_mi)
			
			var light_strip = BoxMesh.new()
			light_strip.size = Vector3(1.3, 0.03, 0.05)
			var light_mat = StandardMaterial3D.new()
			light_mat.albedo_color = Color(0.8, 0.6, 0.2)
			light_mat.emission_enabled = true
			light_mat.emission = Color(0.8, 0.6, 0.2)
			light_mat.emission_energy_multiplier = 1.0
			light_strip.material = light_mat
			var ls_mi = MeshInstance3D.new()
			ls_mi.mesh = light_strip
			ls_mi.position = Vector3(8 + i, 1.4 + j, -14.5)
			add_child(ls_mi)

func _generate_corridor():
	var corridor_mat = StandardMaterial3D.new()
	corridor_mat.albedo_color = Color(0.15, 0.14, 0.12)
	corridor_mat.metallic = 0.5
	corridor_mat.roughness = 0.6
	
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.25, 0.22, 0.18)
	frame_mat.metallic = 0.7
	frame_mat.roughness = 0.5
	
	var corr_floor_mesh = BoxMesh.new()
	corr_floor_mesh.size = Vector3(25, 0.15, 5)
	corr_floor_mesh.material = corridor_mat
	var corr_floor_mi = MeshInstance3D.new()
	corr_floor_mi.mesh = corr_floor_mesh
	corr_floor_mi.position = Vector3(27.5, -0.075, 0)
	add_child(corr_floor_mi)
	
	var corr_floor_col = CollisionShape3D.new()
	var corr_floor_shape = BoxShape3D.new()
	corr_floor_shape.size = Vector3(25, 0.15, 5)
	corr_floor_col.shape = corr_floor_shape
	var corr_floor_body = StaticBody3D.new()
	corr_floor_body.position = Vector3(27.5, -0.075, 0)
	corr_floor_body.add_child(corr_floor_col)
	add_child(corr_floor_body)
	
	var corr_ceil_mesh = BoxMesh.new()
	corr_ceil_mesh.size = Vector3(25, 0.15, 5)
	corr_ceil_mesh.material = corridor_mat
	var corr_ceil_mi = MeshInstance3D.new()
	corr_ceil_mi.mesh = corr_ceil_mesh
	corr_ceil_mi.position = Vector3(27.5, 6, 0)
	add_child(corr_ceil_mi)
	
	var corr_walls = [
		{"pos": Vector3(27.5, 3, -2.5), "size": Vector3(25, 6, 0.4)},
		{"pos": Vector3(27.5, 3, 2.5), "size": Vector3(25, 6, 0.4)},
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
	
	for i in range(5):
		var window_frame = BoxMesh.new()
		window_frame.size = Vector3(4, 3.5, 0.2)
		window_frame.material = frame_mat
		var wf_mi = MeshInstance3D.new()
		wf_mi.mesh = window_frame
		wf_mi.position = Vector3(18 + i * 5, 3, -2.3)
		add_child(wf_mi)
		
		var window_glass = BoxMesh.new()
		window_glass.size = Vector3(3.4, 2.9, 0.05)
		var glass_mat = StandardMaterial3D.new()
		glass_mat.albedo_color = Color(0.25, 0.35, 0.5)
		glass_mat.emission_enabled = true
		glass_mat.emission = Color(0.15, 0.25, 0.4)
		glass_mat.emission_energy_multiplier = 0.8
		glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass_mat.albedo_color.a = 0.5
		glass_mat.metallic = 0.1
		glass_mat.roughness = 0.2
		window_glass.material = glass_mat
		var wg_mi = MeshInstance3D.new()
		wg_mi.mesh = window_glass
		wg_mi.position = Vector3(18 + i * 5, 3, -2.15)
		add_child(wg_mi)
	
	for i in range(5):
		var door_frame = BoxMesh.new()
		door_frame.size = Vector3(1.8, 4, 0.2)
		door_frame.material = frame_mat
		var df_mi = MeshInstance3D.new()
		df_mi.mesh = door_frame
		df_mi.position = Vector3(20 + i * 5, 2, 2.3)
		add_child(df_mi)
		
		var door_panel = BoxMesh.new()
		door_panel.size = Vector3(1.4, 3.4, 0.1)
		var door_mat = StandardMaterial3D.new()
		door_mat.albedo_color = Color(0.18, 0.16, 0.14)
		door_mat.metallic = 0.5
		door_mat.roughness = 0.6
		door_panel.material = door_mat
		var dp_mi = MeshInstance3D.new()
		dp_mi.mesh = door_panel
		dp_mi.position = Vector3(20 + i * 5, 2, 2.2)
		add_child(dp_mi)
		
		var door_light = BoxMesh.new()
		door_light.size = Vector3(0.1, 0.3, 0.05)
		var dl_mat = StandardMaterial3D.new()
		dl_mat.albedo_color = Color(0.8, 0.6, 0.2)
		dl_mat.emission_enabled = true
		dl_mat.emission = Color(0.8, 0.6, 0.2)
		dl_mat.emission_energy_multiplier = 1.5
		door_light.material = dl_mat
		var dl_mi = MeshInstance3D.new()
		dl_mi.mesh = door_light
		dl_mi.position = Vector3(20 + i * 5, 4.2, 2.2)
		add_child(dl_mi)
	
	for i in range(6):
		var ceil_light = BoxMesh.new()
		ceil_light.size = Vector3(0.1, 0.08, 2)
		var cl_mat = StandardMaterial3D.new()
		cl_mat.albedo_color = Color(0.7, 0.75, 0.8)
		cl_mat.emission_enabled = true
		cl_mat.emission = Color(0.7, 0.75, 0.8)
		cl_mat.emission_energy_multiplier = 1.0
		ceil_light.material = cl_mat
		var cl_mi = MeshInstance3D.new()
		cl_mi.mesh = ceil_light
		cl_mi.position = Vector3(17 + i * 4.5, 5.92, 0)
		add_child(cl_mi)
	
	for i in range(5):
		var floor_stripe = BoxMesh.new()
		floor_stripe.size = Vector3(0.05, 0.02, 4)
		var fs_mat = StandardMaterial3D.new()
		fs_mat.albedo_color = Color(0.8, 0.5, 0.1)
		fs_mat.emission_enabled = true
		fs_mat.emission = Color(0.8, 0.5, 0.1)
		fs_mat.emission_energy_multiplier = 0.5
		floor_stripe.material = fs_mat
		var fs_mi = MeshInstance3D.new()
		fs_mi.mesh = floor_stripe
		fs_mi.position = Vector3(19 + i * 5, 0.02, 0)
		add_child(fs_mi)
