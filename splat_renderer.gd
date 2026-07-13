class_name SplatRenderer
extends MeshInstance3D

var _voxel_size: float = 0.1

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
	var size = max_pos - min_pos
	
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
	
	var center_cube = BoxMesh.new()
	center_cube.size = Vector3(1, 1, 1)
	var center_mat = StandardMaterial3D.new()
	center_mat.albedo_color = Color(1, 1, 0)
	center_cube.material = center_mat
	var center_mi = MeshInstance3D.new()
	center_mi.mesh = center_cube
	center_mi.position = center
	add_child(center_mi)
	
	var mesh = _build_mesh(data)
	self.mesh = mesh
	self.position = center
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://splat_shader.gdshader")
	mat.set_shader_parameter("point_size", 15.0 * scale_mult)
	mat.set_shader_parameter("brightness", 2.0)
	material_override = mat
	
	_build_voxel_collisions(pos, min_pos, max_pos)

func _build_voxel_collisions(positions: PackedVector3Array, min_pos: Vector3, max_pos: Vector3):
	var voxel_count = 0
	var voxel_map = {}
	
	for pos in positions:
		var vx = int(floor((pos.x - min_pos.x) / _voxel_size))
		var vy = int(floor((pos.y - min_pos.y) / _voxel_size))
		var vz = int(floor((pos.z - min_pos.z) / _voxel_size))
		var key = Vector3(vx, vy, vz)
		if key not in voxel_map:
			voxel_map[key] = 0
		voxel_map[key] += 1
	
	var min_voxel = Vector3(INF, INF, INF)
	var max_voxel = Vector3(-INF, -INF, -INF)
	for key in voxel_map:
		min_voxel = min_voxel.min(key)
		max_voxel = max_voxel.max(key)
	
	var blocks = []
	for key in voxel_map:
		if voxel_map[key] >= 5:
			var world_x = min_pos.x + key.x * _voxel_size + _voxel_size * 0.5
			var world_y = min_pos.y + key.y * _voxel_size + _voxel_size * 0.5
			var world_z = min_pos.z + key.z * _voxel_size + _voxel_size * 0.5
			blocks.append(Vector3(world_x, world_y, world_z))
	
	var body = StaticBody3D.new()
	body.name = "SplatCollision"
	
	var merged_mesh = Mesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for block_pos in blocks:
		var half = _voxel_size * 0.5
		var corners = [
			Vector3(-half, -half, -half),
			Vector3(half, -half, -half),
			Vector3(half, half, -half),
			Vector3(-half, half, -half),
			Vector3(-half, -half, half),
			Vector3(half, -half, half),
			Vector3(half, half, half),
			Vector3(-half, half, half),
		]
		var faces = [
			[0, 1, 2, 3],
			[4, 5, 6, 7],
			[0, 1, 5, 4],
			[2, 3, 7, 6],
			[0, 3, 7, 4],
			[1, 2, 6, 5],
		]
		
		for face in faces:
			st.add_vertex(corners[face[0]] + block_pos)
			st.add_vertex(corners[face[1]] + block_pos)
			st.add_vertex(corners[face[2]] + block_pos)
			st.add_vertex(corners[face[0]] + block_pos)
			st.add_vertex(corners[face[2]] + block_pos)
			st.add_vertex(corners[face[3]] + block_pos)
	
	st.index()
	merged_mesh = st.commit()
	
	var shape = ConcavePolygonShape3D.new()
	shape.set_mesh(merged_mesh)
	
	var col_shape = CollisionShape3D.new()
	col_shape.shape = shape
	body.add_child(col_shape)
	add_child(body)

func _read_ply(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	
	var magic = file.get_line()
	if not magic.begins_with("ply"):
		file.close()
		return null
	
	var format = ""
	var vertex_count = 0
	var properties = []
	
	while true:
		var line = file.get_line()
		if line.strip_edges() == "end_header":
			break
		if line.begins_with("format"):
			format = line.strip_edges()
		elif line.begins_with("element vertex"):
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