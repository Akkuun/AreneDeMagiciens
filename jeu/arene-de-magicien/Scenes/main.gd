extends Node

@onready var lobby_packed_scene : PackedScene = load("res://Scenes/levels/util/lobby.tscn")

var current_scene : Node
@export var loading_animation_scene : Node

var waiting_scene : Node

func _ready() -> void:
	loading_animation_scene.visible = true
	current_scene = lobby_packed_scene.instantiate()
	add_child(current_scene)
	
	loading_animation_scene.put_in_place(get_player_position())
	
	Global.level_loading.connect(load_level)
	$Player.set_menu_interaction(true)

func get_player() -> Node:
	return get_tree().get_nodes_in_group("player").front()

func get_player_position() -> Vector3:
	var player = get_player()
	if player:
		return player.global_position
	else :
		return Vector3.ZERO


var scatter_unfinished_count : int
func load_level(scene : PackedScene):
	loading_animation_scene.start(get_player_position())
	loading_animation_scene.visible = true
	waiting_scene = scene.instantiate()
	waiting_scene.ready.connect(func() : 
		var scatter_nodes = get_tree().get_nodes_in_group("scatter_node")
		for scatter in scatter_nodes:
			if scatter is ProtonScatter:
				scatter_unfinished_count += 1
				scatter.build_completed.connect(scatter_finished)
		loading_animation_scene.put_in_place(get_player_position()))

func scatter_finished():
	scatter_unfinished_count -= 1
	if scatter_unfinished_count <= 0:
		loading_animation_scene.reverse()


func _on_loading_box_filling_animation_finished() -> void:
	current_scene.queue_free()
	add_child(waiting_scene)
	current_scene = waiting_scene


func _on_loading_box_emptying_animation_finished() -> void:
	loading_animation_scene.visible = false
	$Player.disable_move = false
	$Player.set_menu_interaction(false)
