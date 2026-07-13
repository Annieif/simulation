class_name SplatRenderer
extends MeshInstance3D

func load_ply(path: String, scale_mult: float = 1.0):
	_log("SplatRenderer: Starting to load PLY from: " + path)
	var data = _read_ply(path)
	if data == null or data.is_empty() or data["count"] == 0:
		push_error("SplatRenderer: Failed to load data from " + path)
		_log("SplatRenderer: Failed to load data, aborting")
		_flush_log()
		return
	
	var count = data["count"]
	var pos = data["positions"]
	var col = data["colors"]
	_log("SplatRenderer: Successfully loaded " + str(count) + " vertices")
	for i in range(min(3, count)):
		_log("  Sample vertex " + str(i) + ": pos=" + str(pos[i]) + " color=" + str(col[i]))
	
	var min_pos = Vector3(INF, INF, INF)
	var max_pos = Vector3(-INF, -INF, -INF)
	for i in range(count):
		min_pos = min_pos.min(pos[i])
		max_pos = max_pos.max(pos[i])
	var center = (min_pos + max_pos) * 0.5
	var size = max_pos - min_pos
	_log("SplatRenderer: Bounds min=" + str(min_pos) + " max=" + str(max_pos))
	_log("SplatRenderer: Center=" + str(center) + " Size=" + str(size))
	
	# Create debug bounding box wireframe
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	var box_mat = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0, 1, 0)
	box_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	box_mat.albedo_color.a = 0.3
	box_mesh.material = box_mat
	var box_mi = MeshInstance3D.new()
	box_mi.mesh = box_mesh
	box_mi.position = center
	add_child(box_mi)
	
	# Also place a small bright yellow cube at center
	var center_cube = BoxMesh.new()
	center_cube.size = Vector3(1, 1, 1)
	var center_mat = StandardMaterial3D.new()
	center_mat.albedo_color = Color(1, 1, 0)
	center_cube.material = center_mat
	var center_mi = MeshInstance3D.new()
	center_mi.mesh = center_cube
	center_mi.position = center
	add_child(center_mi)
	_log("SplatRenderer: Placed debug cubes at center=" + str(center))
	
	var mesh = _build_mesh(data)
	self.mesh = mesh
	self.position = center
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://splat_shader.gdshader")
	mat.set_shader_parameter("point_size", 15.0 * scale_mult)
	mat.set_shader_parameter("brightness", 2.0)
	material_override = mat
	_log("SplatRenderer: Setup complete")
	_flush_log()

var _log_lines: PackedStringArray = PackedStringArray()

func _log(msg: String):
	print(msg)
	_log_lines.append(msg)

func _flush_log():
	var log_file = FileAccess.open("user://splat_debug.log", FileAccess.WRITE)
	if log_file:
		for line in _log_lines:
			log_file.store_line(line)
		log_file.close()

func _read_ply(path: String):
	_log("SplatRenderer: Opening file: " + path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("SplatRenderer: Cannot open file " + path + " error=" + str(err))
		_log("SplatRenderer: File open failed, error code: " + str(err))
		_flush_log()
		return null
	
	_log("SplatRenderer: File opened successfully")
	
	# Read magic
	var magic = file.get_line()
	_log("SplatRenderer: Magic line: '" + magic + "'")
	if not magic.begins_with("ply"):
		push_error("SplatRenderer: Not a valid PLY file")
		file.close()
		_flush_log()
		return null
	
	# Parse header
	var format = ""
	var vertex_count = 0
	var properties = []
	
	while true:
		var line = file.get_line()
		_log("SplatRenderer: Header line: '" + line + "'")
		if line.strip_edges() == "end_header":
			break
		if line.begins_with("format"):
			format = line.strip_edges()
		elif line.begins_with("element vertex"):
			var parts = line.split(" ")
			if parts.size() >= 3:
				vertex_count = int(parts[2])
				_log("SplatRenderer: Vertex count from header: " + str(vertex_count))
		elif line.begins_with("property"):
			properties.append(line.strip_edges())
	
	_log("SplatRenderer: Format=" + format + " VertexCount=" + str(vertex_count) + " Properties=" + str(properties.size()))
	
	if vertex_count == 0:
		push_error("SplatRenderer: No vertices in PLY")
		file.close()
		_flush_log()
		return null
	
	# Determine bytes per vertex from properties
	var bytes_per_vertex = properties.size() * 4
	_log("SplatRenderer: Estimated bytes per vertex: " + str(bytes_per_vertex))
	
	# Pre-allocate
	var positions = PackedVector3Array()
	var colors = PackedColorArray()
	positions.resize(vertex_count)
	colors.resize(vertex_count)
	
	# Read vertex data
	for i in range(vertex_count):
		var x = file.get_float()
		var y = file.get_float()
		var z = file.get_float()
		
		var remaining_props = properties.size() - 3
		for _j in range(remaining_props):
			file.get_float()
		
		positions[i] = Vector3(x, y, z)
		colors[i] = Color(1, 1, 1, 1)
	
	file.close()
	_log("SplatRenderer: Read all " + str(vertex_count) + " vertices")
	
	var result = {
		"positions": positions,
		"colors": colors,
		"count": vertex_count
	}
	_flush_log()
	return result

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