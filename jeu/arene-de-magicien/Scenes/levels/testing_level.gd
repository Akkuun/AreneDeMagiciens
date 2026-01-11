extends Node3D

@export var debug_cameras : Array[Camera3D]
var current_camera = 0

@export var bodies : Array[RigidBody3D]

func _ready() -> void:
	for body in bodies:
		body.freeze = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_switch_camera"):
		current_camera = (current_camera + 1) % debug_cameras.size()
		var new_cam = debug_cameras[current_camera]
		new_cam.make_current()
	if event.is_action_pressed("ui_accept"):
		if !bodies.is_empty():
			bodies.pop_front().freeze = false
 
