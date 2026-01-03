@tool
extends BTAction
# Sélectionne une position aléatoire autour du dernier point où l'agent a perdu le joueur
# Utile pour créer un comportement de patrouille dans une zone définie


@export var patrol_radius: float = 10.0
@export var min_distance: float = 3.0
@export var loose_point_var: StringName = &"loose_point"
@export var output_var: StringName = &"patrol_pos"


func _generate_name() -> String:
	return "SelectRandomPatrolPos radius: %s->%s" % [
		patrol_radius,
		LimboUtility.decorate_var(output_var)
	]


func _tick(_delta: float) -> Status:
	var loose_point: Vector3
	if not blackboard.has_var(loose_point_var):
		# 1 fois : utilise la position actuelle
		loose_point = agent.global_position
		blackboard.set_var(loose_point_var, loose_point)
	else:
		loose_point = blackboard.get_var(loose_point_var, agent.global_position)
	
	# génère une position aléatoire autour du loose point
	var random_angle = randf() * TAU
	var random_distance = randf_range(min_distance, patrol_radius)
	
	var offset = Vector3(
		cos(random_angle) * random_distance,
		0.0,
		sin(random_angle) * random_distance
	)
	
	var patrol_position = loose_point + offset
	blackboard.set_var(output_var, patrol_position)
	
	return SUCCESS
