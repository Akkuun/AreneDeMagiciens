@tool
extends BTAction
# Déplace l'agent vers la position spécifiée dans le plan horizontal (XZ).
# Utilise NavigationAgent3D pour suivre un chemin calculé sur le NavigationMesh.
# Retourne SUCCESS quand proche de la position cible ;
# sinon retourne RUNNING.

@export var target_position_var := &"pos"

# Mode de vitesse : walk (marche) ou run (course)
@export_enum("run", "walk", "custom") var speed_mode: String = "run"

# Vitesse personnalisée (utilisée si speed_mode == "custom")
@export var custom_speed: float = 5.0

# distance minimale à la position cible pour retourner SUCCESS.
@export var tolerance := 0.5

# noeud a éviter (Node3D valide attendu).
@export var avoid_var: StringName


func _generate_name() -> String:
	return "Arrive  pos: %s%s" % [
		LimboUtility.decorate_var(target_position_var),
		"" if avoid_var.is_empty() else "  avoid: " + LimboUtility.decorate_var(avoid_var)
	]


func _tick(_delta: float) -> Status:
	var target_pos: Vector3 = blackboard.get_var(target_position_var, Vector3.ZERO)
	
	# vérifie si on est arrivé
	var distance: float = agent.global_position.distance_to(target_pos)
	if distance < tolerance:
		return SUCCESS

	# Détermine la vitesse selon le mode
	var speed: float
	match speed_mode:
		"walk":
			speed = agent.walk_speed if agent.get("walk_speed") != null else 2.0
		"run":
			speed = agent.run_speed if agent.get("run_speed") != null else 5.0
		"custom":
			speed = custom_speed
		_:
			speed = agent.move_speed if agent.get("move_speed") != null else 5.0
	
	# print("speed mode: %s -> %s" % [speed_mode, speed])
	
	
	var dir_3d: Vector3
	
	# utilise NavigationAgent3D si disponible
	if agent._navigation_agent and is_instance_valid(agent._navigation_agent):
		# configure la destination du NavigationAgent
		agent._navigation_agent.target_position = target_pos
		
		# obtien la prochaine position sur le chemin calculé
		var next_pos: Vector3 = agent._navigation_agent.get_next_path_position()
		
		# direction vers le prochain waypoint
		dir_3d = (next_pos - agent.global_position)
		dir_3d.y = 0 
		
	else:
		# Fallback : déplacement direct sans navigation
		print("[WARNING] ArrivePos: NavigationAgent3D non disponible, déplacement direct.")
		dir_3d = target_pos - agent.global_position
		dir_3d.y = 0
	
	# évitement optionnel du noeud spécifié par `avoid_var`
	if not avoid_var.is_empty():
		var avoid_node: Node3D = blackboard.get_var(avoid_var)
		if is_instance_valid(avoid_node):
			var to_avoid: Vector3 = avoid_node.global_position - agent.global_position
			to_avoid.y = 0
			var distance_to_avoid: float = to_avoid.length()
			
			# Si on se dirige vers l'objet à éviter
			if dir_3d.normalized().dot(to_avoid.normalized()) > 0.5:
				var safety_radius := 2.0
				
				# Si trop proche, applique une force d'évitement
				if distance_to_avoid < safety_radius:
					var side := Vector3(-dir_3d.normalized().z, 0, dir_3d.normalized().x)
					var strength: float = remap(distance_to_avoid, 0.5, safety_radius, 1.5, 0.3)
					strength = clampf(strength, 0.0, 1.5)
					var avoidance := side * signf(-side.dot(to_avoid)) * strength
					dir_3d += avoidance

	var desired_velocity: Vector3 = dir_3d.normalized() * speed
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING
