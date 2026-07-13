extends Node3D

func _ready():
	# 加载混元生成的 PLY 场景
	var splat = SplatRenderer.new()
	splat.load_ply("res://a.ply", 1.0)
	add_child(splat)
	
	# 加载玩家场景
	var player_scene = preload("res://Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(0, 1.6, 0)
	add_child(player)