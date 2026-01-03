@tool
extends BTCondition
#Vérifie si un joueur est dans le rayon de détection de l'agent
#Retourne SUCCESS si un joueur est détecté, FAILURE sinon




@export var detection_radius: float = 10.0
@export var player_group: StringName = &"player"
@export var output_var: StringName = &"detected_player"


func _generate_name() -> String:
	return "IsPlayerDetected radius: %s->%s" % [
		detection_radius,
		LimboUtility.decorate_var(output_var)
	]


func _tick(_delta: float) -> Status:
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	
	for player in players:
		if not is_instance_valid(player):
			continue
		var distance = agent.global_position.distance_to(player.global_position)
		if distance <= detection_radius:
			# joueur détecté on stocke dans le blackboard le booléen
			blackboard.set_var(output_var, player)
			return SUCCESS
    # aucun joueur détecté
	blackboard.set_var(output_var, null)
	return FAILURE
