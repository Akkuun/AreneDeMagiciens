@tool
extends BTAction
# Tire un projectile vers la cible


@export var target_var: StringName = &"detected_player"
@export var projectile_scene: PackedScene
@export var spawn_offset: Vector3 = Vector3(0, 0.4, 0)
@export var max_range: float = 11.0
@export var cooldown: float = 2.0

var _last_shot_time: float = -999.0


func _generate_name() -> String:
	return "ShootProjectile  target: %s" % [
		LimboUtility.decorate_var(target_var)
	]


func _tick(_delta: float) -> Status:
	#cooldown
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_shot_time < cooldown:
		return FAILURE

	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	if not projectile_scene:
		push_error("ShootProjectile: Aucune scène de projectile définie!")
		return FAILURE

	var projectile = projectile_scene.instantiate()
	agent.get_tree().root.add_child(projectile)
	

	var dir_to_target = (target.global_position - agent.global_position).normalized()
	var start_pos = agent.global_position + Vector3(0, spawn_offset.y, 0) + (dir_to_target * 1.0)
	var distance_to_target = start_pos.distance_to(target.global_position)
	var travel_distance = min(distance_to_target, max_range)
	

	if projectile.has_method("launch"):
		projectile.launch(target.global_position, start_pos, travel_distance)
	
	# met à jour le cooldown
	_last_shot_time = current_time
	
	return SUCCESS
