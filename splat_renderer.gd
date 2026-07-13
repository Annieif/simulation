class_name SplatRenderer
extends MeshInstance3D

func load_ply(path: String, scale_multiplier: float = 1.0):
	var data = _read_ply(path)
	var mesh = _build_mesh(data, scale_multiplier)
	self.mesh = mesh
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://splat_shader.gdshader")
	mat.set_shader_parameter("global_scale", scale_multiplier)
	material_override = mat

func _read_ply(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open PLY file: " + path)
		return {}
	
	var header = ""
	while true:
		var line = file.get_line()
		header += line + "\n"
		if line.strip_edges() == "end_header":
			break
	
	var vertex_count = 0
	for line in header.split("\n"):
		line = line.strip_edges()
		if line.begins_with("element vertex"):
			vertex_count = int(line.split()[2])
	
	print("PLY vertex count: ", vertex_count)
	
	var positions = PackedVector3Array()
	var colors = PackedColorArray()
	var sizes = PackedFloat32Array()
	positions.resize(vertex_count)
	colors.resize(vertex_count)
	sizes.resize(vertex_count)
	
	for i in range(vertex_count):
		var x = file.get_float()
		var y = file.get_float()
		var z = file.get_float()
		var r_sh = file.get_float()
		var g_sh = file.get_float()
		var b_sh = file.get_float()
		var opacity = file.get_float()
		var s0 = file.get_float()
		var s1 = file.get_float()
		var s2 = file.get_float()
		var q0 = file.get_float()
		var q1 = file.get_float()
		var q2 = file.get_float()
		var q3 = file.get_float()
		
		positions[i] = Vector3(x, y, z)
		colors[i] = Color(
			clamp(r_sh + 0.5, 0.0, 1.0),
			clamp(g_sh + 0.5, 0.0, 1.0),
			clamp(b_sh + 0.5, 0.0, 1.0),
			clamp(1.0 / (1.0 + exp(-opacity)), 0.0, 1.0)
		)
		var avg_scale = exp((s0 + s1 + s2) / 3.0)
		sizes[i] = avg_scale
	
	file.close()
	
	return {
		"positions": positions,
		"colors": colors,
		"sizes": sizes,
		"count": vertex_count
	}

func _build_mesh(data: Dictionary, scale_mult: float) -> Mesh:
	var positions = data["positions"]
	var colors = data["colors"]
	var sizes = data["sizes"]
	var count = data["count"]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var corners = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	var tri_indices = [0, 1, 2, 0, 2, 3]
	
	for i in range(count):
		var center = positions[i]
		var color = colors[i]
		var size = sizes[i]
		
		for ci in 4:
			var corner = corners[ci]
			st.set_uv(corner)
			st.set_color(color)
			st.set_custom(0, PackedFloat32Array([size, 0.0, 0.0, 0.0]))
			st.add_vertex(center)
		
		for ti in 6:
			st.add_index(i * 4 + tri_indices[ti])
	
	st.index()
	st.generate_normals()
	return st.commit()