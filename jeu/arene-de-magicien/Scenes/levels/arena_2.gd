extends Node3D

@export var potion : RigidBody3D

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		potion.freeze = false
