@tool
extends BTAction
# Met a jour le point de référence pour la patrouille avec la position actuelle
# Utilisé quand l'agent perd le joueur de vue pour patrouiller autour de cette nouvelle position


@export var loose_point_var: StringName = &"loose_point"


func _generate_name() -> String:
	return "UpdateLoosePoint ->%s" % [
		LimboUtility.decorate_var(loose_point_var)
	]


func _tick(_delta: float) -> Status:
	blackboard.set_var(loose_point_var, agent.global_position)
	return SUCCESS
