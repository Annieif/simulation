class_name SplatRenderer
extends MeshInstance3D

func load_ply(path: String, scale_mult: float = 1.0):
	var data = _read_ply(path)
	if data == null or data.is_empty() or data["count"] == 0:
		push_error("SplatRenderer: Failed to load data from " + path)
		return
	
	var count = data["count"]
	var pos = data["positions"]
	var col = data["colors"]
	
	var min_pos = Vector3(INF, INF, INF)
	var max_pos = Vector3(-INF, -INF, -INF)
	for i in range(count):
		min_pos = min_pos.min(pos[i])
		max_pos = max_pos.max(pos[i])
	var center = (min_pos + max_pos) * 0.5
	
	var mesh = _build_mesh(data)
	self.mesh = mesh
	self.position = center
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://splat_shader.gdshader")
	mat.set_shader_parameter("point_size", 20.0)
	mat.set_shader_parameter("brightness", 3.0)
	material_override = mat

func _read_ply(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	
	var magic = file.get_line()
	if not magic.begins_with("ply"):
		file.close()
		return null
	
	var vertex_count = 0
	var properties = []
	
	while true:
		var line = file.get_line()
		if line.strip_edges() == "end_header":
			break
		if line.begins_with("element vertex"):
			var parts = line.split(" ")
			if parts.size() >= 3:
				vertex_count = int(parts[2])
		elif line.begins_with("property"):
			properties.append(line.strip_edges())
	
	if vertex_count == 0:
		file.close()
		return null
	
	var positions = PackedVector3Array()
	var colors = PackedColorArray()
	positions.resize(vertex_count)
	colors.resize(vertex_count)
	
	for i in range(vertex_count):
		var x = file.get_float() * 3.0
		var y = file.get_float() * 3.0
		var z = file.get_float() * 3.0
		var r_sh = file.get_float()
		var g_sh = file.get_float()
		var b_sh = file.get_float()
		var opacity = file.get_float()
		
		var remaining_props = properties.size() - 7
		for _j in range(remaining_props):
			file.get_float()
		
		positions[i] = Vector3(x, y, z)
		
		var SH_COEFF = 0.28209479177387814
		var cr = clamp(0.5 + r_sh * SH_COEFF, 0.0, 1.0)
		var cg = clamp(0.5 + g_sh * SH_COEFF, 0.0, 1.0)
		var cb = clamp(0.5 + b_sh * SH_COEFF, 0.0, 1.0)
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