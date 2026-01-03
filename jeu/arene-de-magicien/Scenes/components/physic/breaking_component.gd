@tool
extends Node

@export var breaking_speed : float = 0.1

signal breaking(at: Vector3, speed: Vector3)

var parent : RigidBody3D

func _get_configuration_warnings() -> PackedStringArray:
	var p = get_parent()
	if not p or p is not RigidBody3D:
		return ["Need to be child of RigidBody3D"]
	return []


func _ready() -> void:
	parent = get_parent() as RigidBody3D
	parent.body_entered.connect(collision_with)
	parent.contact_monitor = true
	parent.max_contacts_reported = 8
	
	
	
	
	

func collision_with(node: Node):
	var current_speed : float = 0.0
	if node is StaticBody3D:
		current_speed = parent.linear_velocity.length()
	elif node is CSGShape3D:
		current_speed = parent.linear_velocity.length() * 2.0
	elif node is RigidBody3D:
		var relative_velocity : Vector3 = parent.linear_velocity - node.linear_velocity
		current_speed = relative_velocity.length()
	
	if current_speed >= breaking_speed:
		emit_signal("breaking", parent.global_position, parent.linear_velocity)
