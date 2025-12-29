extends CharacterBody3D
# Script de base pour les agents 3D.
# Fournit les fonctionnalités communes, ex : déplacement, rotation, santé, attaque, etc.

signal death

#vitesse de déplacement de l'agent
@export var move_speed: float = 5.0

#vitesse de rotation de l'agent
@export var rotation_speed: float = 10.0

# Utilise le système de navigation de Godot pour éviter les obstacles
@export var use_navigation: bool = true

var _is_dead: bool = false
var _moved_this_frame: bool = false
var _navigation_agent: NavigationAgent3D = null

@onready var root: Node3D = $root
# @onready var health: Health = $Health  # pour rajouter un nœud Health
# @onready var animation_player: AnimationPlayer = $AnimationPlayer  # si on rajoute de l'animation


func _ready() -> void:
	# health.damaged.connect(_damaged)
	# health.death.connect(die)
	
	# Crée et configure le NavigationAgent3D si nécessaire
	if use_navigation:
		_setup_navigation_agent()


func _physics_process(_delta: float) -> void:
	_post_physics_process.call_deferred()



func _post_physics_process() -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector3.ZERO, 0.5)
	_moved_this_frame = false



# déplace l'agent avec la vélocité spécifiée
func move(p_velocity: Vector3) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true


# déplace l'agent en direction d'une position cible
func move_toward_position(target_position: Vector3, speed: float = move_speed) -> void:
	var direction = (target_position - global_position).normalized()
	var desired_velocity = direction * speed
	move(desired_velocity)


# update l'orientation de l'agent dans la direction du mouvement
func update_facing() -> void:
	if velocity.length() > 0.1:
		face_direction(velocity)


# oriente l'agent vers une direction
func face_direction(direction: Vector3) -> void:
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		root.rotation.y = lerp_angle(root.rotation.y, target_rotation, rotation_speed * get_physics_process_delta_time())


#oriente l'agent vers une position
func face_target(target_position: Vector3) -> void:
	var direction = (target_position - global_position)
	direction.y = 0  # Ignore la composante verticale
	face_direction(direction)




# retourne la direction dans laquelle l'agent regarde (Vector3 forward)
func get_facing_direction() -> Vector3:
	return -root.global_transform.basis.z


func is_facing_target(target_position: Vector3, tolerance: float = 0.9) -> bool:
	var to_target = (target_position - global_position).normalized()
	to_target.y = 0
	var facing = get_facing_direction()
	facing.y = 0
	return facing.normalized().dot(to_target) > tolerance


# applique un knockback à l'agent
func apply_knockback(knockback: Vector3, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame


# callback quand l'agent prend des dégâts
func _damaged(_amount: float, knockback: Vector3) -> void:
	apply_knockback(knockback)
	# if animation_player:
	# 	animation_player.play(&"hurt")
	
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	

	# if animation_player:
	# 	await animation_player.animation_finished
	await get_tree().create_timer(0.3).timeout
	
	if btplayer and not _is_dead:
		btplayer.restart()

func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	# if animation_player:
	# 	animation_player.play(&"death")
	
	# désactive le BehaviorTree
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	
	# supprime l'agent après un délai
	if get_tree():
		await get_tree().create_timer(10.0).timeout
		queue_free()

func is_dead() -> bool:
	return _is_dead



# retourne la distance vers une cible
func get_distance_to(target_position: Vector3) -> float:
	return global_position.distance_to(target_position)


#vérifie si l'agent est à portée d'une cible
func is_in_range(target_position: Vector3, max_range: float) -> bool:
	return get_distance_to(target_position) <= max_range


#configure le NavigationAgent3D pour la navigation automatique
func _setup_navigation_agent() -> void:
	_navigation_agent = NavigationAgent3D.new()
	add_child(_navigation_agent)
	_navigation_agent.path_desired_distance = 0.5
	_navigation_agent.target_desired_distance = 0.5
	_navigation_agent.radius = 0.5
	_navigation_agent.height = 2.0
	_navigation_agent.avoidance_enabled = true


#définit la destination du NavigationAgent
func set_navigation_target(target_pos: Vector3) -> void:
	if _navigation_agent:
		_navigation_agent.target_position = target_pos


#retourne la prochaine position vers laquelle se déplacer (utilise la navigation)
func get_next_navigation_position() -> Vector3:
	if _navigation_agent:
		if not _navigation_agent.is_navigation_finished():
			var next = _navigation_agent.get_next_path_position()
			return next

	return global_position

# func get_health() -> Health:
# 	return health
