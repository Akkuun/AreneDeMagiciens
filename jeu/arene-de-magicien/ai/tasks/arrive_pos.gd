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
@export var tolerance := 0.01

# distance à partir de laquelle l'agent commence a ralentir
@export var slowdown_radius := 2.0

# noeud a éviter (Node3D valide attendu).
@export var avoid_var: StringName

# active le marqueur visuel de debug
@export var show_debug_marker: bool = false

var _debug_marker: MeshInstance3D = null


func _generate_name() -> String:
	return "Arrive  pos: %s%s" % [
		LimboUtility.decorate_var(target_position_var),
		"" if avoid_var.is_empty() else "  avoid: " + LimboUtility.decorate_var(avoid_var)
	]


func _tick(_delta: float) -> Status:
	var target_pos: Vector3 = blackboard.get_var(target_position_var, Vector3.ZERO)
	
	# Projette target_pos sur le NavMesh pour avoir une position valide
	if agent._navigation_agent and is_instance_valid(agent._navigation_agent):
		var nav_map = agent._navigation_agent.get_navigation_map()
		if nav_map.is_valid():
			target_pos = NavigationServer3D.map_get_closest_point(nav_map, target_pos)
	
	# debug marker position d'arivée
	if show_debug_marker:
		if not _debug_marker:
			_debug_marker = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = 0.3
			sphere.height = 0.6
			_debug_marker.mesh = sphere
			
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.RED
			material.emission_enabled = true
			material.emission = Color.RED
			material.emission_energy_multiplier = 2.0
			_debug_marker.material_override = material
			
			agent.get_tree().root.add_child(_debug_marker)
		
		_debug_marker.global_position = target_pos
	
	# vérifie si on est arrivé
	var distance: float = agent.global_position.distance_to(target_pos)
	if distance < tolerance:
		agent.move(Vector3.ZERO)
		agent.velocity = Vector3.ZERO
		if _debug_marker:
			_debug_marker.queue_free()
			_debug_marker = null
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
		
		#si le NavigationAgent dit que l'on est arriver
		if agent._navigation_agent.is_navigation_finished():
			agent.move(Vector3.ZERO)
			agent.velocity = Vector3.ZERO
			if _debug_marker:
				_debug_marker.queue_free()
				_debug_marker = null
			return SUCCESS
		
		# Vérifie si la cible est atteignable car sur le level de test on est en float donc parfois on est trop loin
		if not agent._navigation_agent.is_target_reachable():
			# Essaie quand même d'obtenir next_pos, au cas où on peut se rapprocher
			var next_pos: Vector3 = agent._navigation_agent.get_next_path_position()
			dir_3d = (next_pos - agent.global_position)
			dir_3d.y = 0
			
			# si next_pos est invalide (trop proche = pas de chemin), utilise la cible directement
			if dir_3d.length() < 0.01:
				dir_3d = target_pos - agent.global_position
				dir_3d.y = 0
		else:
			# obtien la prochaine position sur le chemin calculé
			var next_pos: Vector3 = agent._navigation_agent.get_next_path_position()
			
			# direction vers le prochain waypoint
			dir_3d = (next_pos - agent.global_position)
			dir_3d.y = 0
			
			# si next_pos est quasi identique (erreur du NavigationAgent), utilise la cible
			if dir_3d.length() < 0.01:
				dir_3d = target_pos - agent.global_position
				dir_3d.y = 0
		
		# si la distance à la destination finale est plus petite que le seuil de tolerance
		if distance < tolerance:
			agent.move(Vector3.ZERO)
			agent.velocity = Vector3.ZERO
			if _debug_marker:
				_debug_marker.queue_free()
				_debug_marker = null
			return SUCCESS 
		
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
			var dot_product = dir_3d.normalized().dot(to_avoid.normalized())
			
			var detection_radius := 5.0
			var min_distance := 2.5
			
			# Si on se dirige vers l'objet à éviter ET qu'on entre dans la zone de détection
			if dot_product > 0.5 and distance_to_avoid < detection_radius:
				var side := Vector3(-dir_3d.normalized().z, 0, dir_3d.normalized().x)
				var strength: float = remap(distance_to_avoid, min_distance, detection_radius, 3.0, 0.5)
				strength = clampf(strength, 0.0, 3.0)
				var avoidance := side * signf(-side.dot(to_avoid)) * strength
				dir_3d += avoidance

	#décélération en approchant de la cible
	var speed_multiplier: float = 1.0
	if distance < slowdown_radius:
		speed_multiplier = clampf(distance / slowdown_radius, 0.2, 1.0)
	
	var desired_velocity: Vector3 = dir_3d.normalized() * speed * speed_multiplier
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING
