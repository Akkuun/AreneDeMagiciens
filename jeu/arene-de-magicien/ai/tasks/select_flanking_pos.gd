@tool
extends BTAction
## Sélectionne une position sur le côté de la cible et la stocke dans le
## blackboard, retournant SUCCES.
## Retourne FAILURE si la cible n'est pas valide.

enum AgentSide {
	CLOSEST,   # Côté le plus proche
	FARTHEST,  # Côté le plus éloigné
	BACK,      # Derrière la cible
	FRONT,     # Devant la cible
}

@export var target_var: StringName = &"target"

# de quel côté doit-on déplacer l'agent
@export var flank_side: AgentSide = AgentSide.CLOSEST

@export var range_min: float = 3.0
@export var range_max: float = 5.0

# var du blackboard utilisé pour stocker la position sélectionné.
@export var position_var: StringName = &"pos"


func _generate_name() -> String:
	return "SelectFlankingPos  target: %s  range: [%s, %s]  side: %s  ➜%s" % [
		LimboUtility.decorate_var(target_var),
		range_min,
		range_max,
		AgentSide.keys()[flank_side],
		LimboUtility.decorate_var(position_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node3D
	if not is_instance_valid(target):
		return FAILURE

	#calcule la direction
	var to_agent: Vector3 = agent.global_position - target.global_position
	to_agent.y = 0  
	
	var flank_direction: Vector3
	match flank_side:
		AgentSide.FARTHEST:
			flank_direction = to_agent.normalized()
		AgentSide.CLOSEST:
			flank_direction = -to_agent.normalized()
		AgentSide.BACK:
			# si on sais ou elle regarde
			if target.has_method("get_facing_direction"):
				flank_direction = -target.get_facing_direction()
			else:
				# sinon juste faire un 180 de la position actuelle
				flank_direction = target.global_transform.basis.z
			flank_direction.y = 0
			flank_direction = flank_direction.normalized()
		AgentSide.FRONT:
			# si on sais ou elle regarde
			if target.has_method("get_facing_direction"):
				flank_direction = target.get_facing_direction()
			else:
				# sinon juste faire un 180 de la position actuelle
				flank_direction = -target.global_transform.basis.z
			flank_direction.y = 0
			flank_direction = flank_direction.normalized()

	#récupère la map de navigation pour vérifier que la position est navigable
	var navigation_map: RID = agent.get_world_3d().get_navigation_map()
	var flank_pos: Vector3
	
	if navigation_map.is_valid():
		# TODO : trouver une meilleure façon de choisir une position navigable
		#essaie plusieurs distances pour trouver une position navigable
		var best_pos: Vector3 = agent.global_position
		var best_distance: float = INF
		
		for attempt in range(5):
			var distance := randf_range(range_min, range_max)
			var offset := flank_direction * distance
			var candidate_pos := target.global_position + offset
			
			# trouve le point le plus proche sur le NavigationMesh
			var nav_pos := NavigationServer3D.map_get_closest_point(navigation_map, candidate_pos)
			
			#dans le doute il n'y a pas de doute, donc
			# vérifie que le point est bien sur le mesh
			var distance_to_mesh := nav_pos.distance_to(candidate_pos)
			
			if distance_to_mesh < best_distance:
				best_pos = nav_pos
				best_distance = distance_to_mesh
				
				# si le point est proche du NavigationMesh, c'est bon
				if distance_to_mesh < 0.5:
					break
		
		flank_pos = best_pos

	else:
		# pas de NavigationMesh, alros calcule simple d'une position
		print("[WARNING] SelectFlankingPos: No NavigationMesh found, using fallback calculation.")
		var offset := flank_direction * randf_range(range_min, range_max)
		flank_pos = target.global_position + offset
	
	blackboard.set_var(position_var, flank_pos)
	return SUCCESS
