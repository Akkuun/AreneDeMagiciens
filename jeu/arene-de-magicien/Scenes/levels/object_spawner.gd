extends Node3D

@export var scene_to_spawn : PackedScene

func spawn():
	var instance = scene_to_spawn.instantiate()
	instance.position = $SpawnLocation.position
	add_child(instance)

func _ready() -> void:
	var instance = scene_to_spawn.instantiate()
	$View/SubViewport.add_child(instance)
	spawn()


func _on_lever_triggered() -> void:
	spawn()
