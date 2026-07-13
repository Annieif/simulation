class_name SplatRenderer
extends MeshInstance3D

func load_ply(path: String, scale_mult: float = 1.0):
	var data = _read_ply(path)
	if data.is_empty() or data["count"] == 0:
		push_error("SplatRenderer: No data loaded from " + path)
		return
	
	# Debug: print first 5 vertex positions and colors
	var count = data["count"]
	var pos = data["positions"]
	var col = data["colors"]
	print("SplatRenderer: Loaded ", count, " vertices")
	for i in range(min(5, count)):
		print("  Vertex ", i, ": pos=", pos[i], " color=", col[i])
	
	# Calculate bounds
	var min_pos = Vector3(INF, INF, INF)
	var max_pos = Vector3(-INF, -INF, -INF)
	for i in range(count):
		min_pos = min_pos.min(pos[i])
		max_pos = max_pos.max(pos[i])
	print("SplatRenderer: Bounds: min=", min_pos, " max=", max_pos)
	print("SplatRenderer: Center: ", (min_pos + max_pos) * 0.5)
	print("SplatRenderer: Size: ", max_pos - min_pos)
	
	# Add debug cubes at bounds corners
	var debug_cube = BoxMesh.new()
	debug_cube.size = Vector3(0.5, 0.5, 0.5)
	var debug_mat = StandardMaterial3D.new()
	debug_mat.albedo_color = Color(0, 1, 0)
	debug_cube.material = debug_mat
	
	var corners = [min_pos, max_pos, Vector3(min_pos.x, min_pos.y, max_pos.z), Vector3(max_pos.x, min_pos.y, min_pos.z), Vector3(min_pos.x, max_pos.y, min_pos.z), Vector3(max_pos.x, max_pos.y, min_pos.z), Vector3(min_pos.x, max_pos.y, max_pos.z)]
	for corner in corners:
		var mi = MeshInstance3D.new()
		mi.mesh = debug_cube
		mi.position = corner
		add_child(mi)
	
	var mesh = _build_mesh(data)
	self.mesh = mesh
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://splat_shader.gdshader")
	mat.set_shader_parameter("point_size", 15.0 * scale_mult)
	mat.set_shader_parameter("brightness", 2.0)
	material_override = mat

func _read_ply(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SplatRenderer: Failed to open PLY file: " + path)
		return {}
	
	# Read header
	var header = ""
	while true:
		var line = file.get_line()
		header += line + "\n"
		if line.strip_edges() == "end_header":
			break
	
	# Parse vertex count
	var vertex_count = 0
	for line in header.split("\n"):
		line = line.strip_edges()
		if line.begins_with("element vertex"):
			var parts = line.split()
			if parts.size() >= 3:
				vertex_count = int(parts[2])
	
	if vertex_count == 0:
		push_error("SplatRenderer: No vertices found in PLY header")
		return {}
	
	print("SplatRenderer: Reading ", vertex_count, " vertices from ", path)
	
	# Pre-allocate arrays
	var positions = PackedVector3Array()
	var colors = PackedColorArray()
	positions.resize(vertex_count)
	colors.resize(vertex_count)
	
	# Read binary data (15 floats per vertex)
	for i in range(vertex_count):
		var x = file.get_float()
		var y = file.get_float()
		var z = file.get_float()
		var r = file.get_float()
		var g = file.get_float()
		var b = file.get_float()
		var opacity = file.get_float()
		var s0 = file.get_float()
		var s1 = file.get_float()
		var s2 = file.get_float()
		var _q0 = file.get_float()
		var _q1 = file.get_float()
		var _q2 = file.get_float()
		var _q3 = file.get_float()
		
		positions[i] = Vector3(x, y, z)
		
		# SH DC coefficient to RGB
		# Standard formula: color = 0.5 + SH * 0.28209479177387814
		var cr = clamp(0.5 + r * 0.28209, 0.0, 1.0)
		var cg = clamp(0.5 + g * 0.28209, 0.0, 1.0)
		var cb = clamp(0.5 + b * 0.28209, 0.0, 1.0)
		# Opacity: sigmoid
		var ca = clamp(1.0 / (1.0 + exp(-opacity)), 0.0, 1.0)
		
		colors[i] = Color(cr, cg, cb, ca)
	
	file.close()
	
	return {
		"positions": positions,
		"colors": colors,
		"count": vertex_count
	}

func _build_mesh(data: Dictionary) -> Mesh:
	var positions = data["positions"]
	var colors = data["colors"]
	var count = data["count"]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_POINTS)
	
	for i in range(count):
		st.set_color(colors[i])
		st.add_vertex(positions[i])
	
	return st.commit()