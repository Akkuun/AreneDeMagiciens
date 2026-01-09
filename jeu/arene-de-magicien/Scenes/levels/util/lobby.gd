extends Node3D

signal load_level(level : PackedScene)

@export var levels : Array[LevelResource]

func _ready() -> void:
	var player = get_tree().get_nodes_in_group("player").front()
	if player:
		player.disable_move = true
		
	for lvl in levels:
		var btn := Button.new()
		btn.text = lvl.level_name
		btn.pressed.connect(func (): 
			load_level.emit(lvl.level_packed_scene))
		add_child(btn)
	
	#get_tree().create_timer(1).timeout.connect(func(): 
		#load_level.emit(levels[1].level_packed_scene))
	
func level_pressed(level_scene : PackedScene):
	load_level.emit(level_scene)
	var player = get_tree().get_nodes_in_group("player").front()
	if player:
		player.disable_move = true
