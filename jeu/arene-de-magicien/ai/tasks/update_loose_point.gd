@tool
extends BTAction
# Met à jour le point de référence UNIQUEMENT lors du passage Fight -> Patrol
# Le point reste fixe pendant toute la durée de la patrouille


@export var loose_point_var: StringName = &"loose_point"
@export var detected_player_var: StringName = &"detected_player"


func _generate_name() -> String:
	return "UpdateLoosePoint ->%s" % [
		LimboUtility.decorate_var(loose_point_var)
	]


func _tick(_delta: float) -> Status:
	# vérifie si on a un joueur détecté (donc on vient du mode Fight)
	var has_detected_player = blackboard.has_var(detected_player_var) and is_instance_valid(blackboard.get_var(detected_player_var))
	
	# vérifie si on a déjà un loose_point
	var has_loose_point = blackboard.has_var(loose_point_var)
	
	# Met à jour SEULEMENT si :
	# 1. On vient de perdre le joueur (detected_player existe mais on est en patrol)
	# 2. OU on n'a pas encore de loose_point (première fois)
	if has_detected_player or not has_loose_point:
		blackboard.set_var(loose_point_var, agent.global_position)
		if has_detected_player:
			blackboard.erase_var(detected_player_var)
	
	return SUCCESS
