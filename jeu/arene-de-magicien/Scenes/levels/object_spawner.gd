extends Node3D

@export var scene_to_spawn : PackedScene
@export var interactible : bool

func spawn():
	var instance = scene_to_spawn.instantiate()
	instance.position = $SpawnLocation.position
	add_child(instance)

func _ready() -> void:
	var instance = scene_to_spawn.instantiate() as XRToolsPickable
	$View/SubViewport.add_child(instance)
	instance.freeze = true
	instance.position = $View/SubViewport/Camera3D.position + Vector3.FORWARD * 0.5
	spawn()


func _on_lever_triggered() -> void:
	spawn()
