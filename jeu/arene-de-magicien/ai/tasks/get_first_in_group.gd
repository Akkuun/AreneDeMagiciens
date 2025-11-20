@tool
extends BTAction

## Tâche BehaviorTree : Récupère le premier noeud d'un groupe spécifié
## et le stocke dans une variable du blackboard.

# nom du groupe dans lequel chercher les noeuds
@export var group: StringName

#nom de la variable du blackboard où stocker le noeud trouvé
@export var output_var: StringName = &"target"


# généréation du nom custom dans le l'éditeur de BehaviorTree
func _generate_name() -> String:
	return "GetFirstNodeInGroup \"%s\"  ➜%s" % [
		group,
		LimboUtility.decorate_var(output_var)
		]

# Exécute la tâche à chaque tick du BehaviorTree
func _tick(_delta: float) -> Status:
	# prend tout le groupe présent dans la scène ayant le nom spécifié
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)

	# Si aucun noeud n'est trouvé, la tâche échoue
	if nodes.size() == 0:
		return FAILURE

	# Stocke le premier noeud trouvé dans la variable du blackboard
	blackboard.set_var(output_var, nodes[0])
	return SUCCESS
