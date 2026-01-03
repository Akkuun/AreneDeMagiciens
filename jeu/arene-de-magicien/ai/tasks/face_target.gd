@tool
extends BTAction
# Oriente l'agent instantanément vers une cible


@export var target_var: StringName = &"detected_player"
@export var instant: bool = false  # rotation instantanée ou progressive


func _generate_name() -> String:
	return "FaceTarget  target: %s" % [
		LimboUtility.decorate_var(target_var)
	]


func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	var direction = (target.global_position - agent.global_position)
	direction.y = 0
	
	if direction.length() < 0.01:
		return SUCCESS
	
	if instant:
		# rotation instantanée
		if agent.has_node("CharacterArmature"):
			var target_rotation = atan2(direction.x, direction.z)
			agent.get_node("CharacterArmature").rotation.y = target_rotation
			return SUCCESS
	else:
		# rotation progressive frame par frame
		if agent.has_node("CharacterArmature"):
			var target_rotation = atan2(direction.x, direction.z)
			var current_rotation = agent.get_node("CharacterArmature").rotation.y
			var rotation_speed = 2.5  # vitesse de rotation
			var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * _delta)
			agent.get_node("CharacterArmature").rotation.y = new_rotation
			var angle_diff = abs(angle_difference(new_rotation, target_rotation))
			if angle_diff < 0.05:
				return SUCCESS
			else:
				return RUNNING
	
	return SUCCESS
