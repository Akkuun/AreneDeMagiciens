@tool
extends BTCondition


@export var target_var: StringName = &"detected_player"
@export var min_range: float = 3.0 # distance minimale
@export var max_range: float = 11.0 # distance maximale
@export var range_var: StringName = &"attack_range" # variable blackboard pour partager max_range


func _generate_name() -> String:
	return "IsInRange target: %s [%s - %s]" % [
		LimboUtility.decorate_var(target_var),
		min_range,
		max_range
	]


func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	var distance = agent.global_position.distance_to(target.global_position)
	
	# Stocke max_range dans le blackboard pour que ShootProjectile l'utilise
	blackboard.set_var(range_var, max_range)
	
	if distance >= min_range and distance <= max_range:
		return SUCCESS
	else:
		return FAILURE
