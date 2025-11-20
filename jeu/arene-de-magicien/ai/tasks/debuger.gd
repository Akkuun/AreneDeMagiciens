@tool
extends BTAction

## Tâche BehaviorTree : Affiche des informations de debug dans la console
## pour vérifier le contenu d'une variable du blackboard.

#nom de la variable du blackboard à débugger
@export var var_to_debug: StringName = &"target"

#message personnalisé à afficher avant la valeur (optionnel)
@export var debug_message: String = "Debug"

# si vrai, affiche aussi le type de la variable
@export var show_type: bool = true


# nom custom dans l'éditeur de BehaviorTree
func _generate_name() -> String:
	return "Debug: %s [%s]" % [
		debug_message,
		LimboUtility.decorate_var(var_to_debug)
	]

# exécute la tâche à chaque tick du BehaviorTree
func _tick(_delta: float) -> Status:
	# vérifie si la variable existe dans le blackboard
	if not blackboard.has_var(var_to_debug):
		print("[DEBUG] X Variable '%s' introuvable dans le blackboard!" % var_to_debug)
		return FAILURE
	# récupère la valeur de la variable
	var value = blackboard.get_var(var_to_debug)
	

	# affiche les informations de debug
	if value == null:
		print("[DEBUG] /!\\  %s: '%s' = null" % [debug_message, var_to_debug])
	else:
		if show_type:
			print("[DEBUG] ✓ %s: '%s' = %s (type: %s)" % [
				debug_message, 
				var_to_debug, 
				value, 
				type_string(typeof(value))
			])
		else:
			print("[DEBUG] ✓ %s: '%s' = %s" % [debug_message, var_to_debug, value])
	
	return SUCCESS
