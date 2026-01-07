@tool
extends Node

@export var breaking_speed : float = 0.1

signal breaking(at: Vector3, speed: Vector3)

var parent : RigidBody3D
var prev_velocities: Array[Vector3]
var tracking_length: int = 5
func _get_configuration_warnings() -> PackedStringArray:
	var p = get_parent()
	if not p or p is not RigidBody3D:
		return ["Need to be child of RigidBody3D"]
	return []


func _ready() -> void:
	var p = get_parent()
	if p != null and p is RigidBody3D:
		parent = get_parent() as RigidBody3D
		parent.body_entered.connect(collision_with)
		parent.contact_monitor = true
		parent.max_contacts_reported = 8

func _physics_process(delta: float) -> void:
	if prev_velocities.size() >= tracking_length:
		prev_velocities.pop_front()
	prev_velocities.push_back(parent.linear_velocity)
	
	
	
	
	

func collision_with(node: Node):
	var current_speed : float = 0.0
	if node is StaticBody3D or node is CSGShape3D:
		var parent_average_velocity: Vector3 = Vector3.ZERO
		for vel in prev_velocities:
			parent_average_velocity += vel
		parent_average_velocity /= float (prev_velocities.size())
		current_speed = parent_average_velocity.length()
	elif node is RigidBody3D:
		var relative_velocity : Vector3 = parent.linear_velocity - node.linear_velocity
		current_speed = relative_velocity.length()
	
	print(current_speed)
	
	if current_speed >= breaking_speed:
		emit_signal("breaking", parent.global_position, parent.linear_velocity)
