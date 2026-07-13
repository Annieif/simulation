extends Node3D

func _ready():
	var builder = ProceduralSceneBuilder.new()
	add_child(builder)
	
	var player_scene = preload("res://Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(0, 1.6, 8)
	add_child(player)
