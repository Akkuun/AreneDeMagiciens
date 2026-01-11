extends CharacterBody3D
# Script de base pour les agents 3D.
# Fournit les fonctionnalités communes, ex : déplacement, rotation, santé, attaque, etc.

signal death

@export_group("Movement")
@export var move_speed: float = 5.0 #vitesse de déplacement de l'agent
@export var walk_speed: float = 2.0 #vitesse de marche
@export var run_speed: float = 5.0 #vitesse de course
@export var rotation_speed: float = 10.0 #vitesse de rotation de l'agent
@export var gravity_strength: float = 20

@export_group("Navigation")
@export var use_navigation: bool = true #utilise le système de navigation de Godot pour éviter les obstacles
@export var navigation_radius: float = 0.5  # rayon de l'agent
@export var navigation_height: float = 2.0  # hauteur de l'agent

var _is_dead: bool = false
var _navigation_agent: NavigationAgent3D = null

@onready var root: Node3D = $CharacterArmature
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var knock_backed: bool = false
var next_frame_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	# crée et configure le NavigationAgent3D si nécessaire
	if use_navigation:
		_setup_navigation_agent()


func _physics_process(_delta: float) -> void:
	var target_vel := Vector3(next_frame_velocity.x, 0, next_frame_velocity.z)
	var lerp_weight = 10.0 * _delta
	velocity = velocity.lerp(target_vel, lerp_weight)
	if !is_on_floor():
		velocity.y -= gravity_strength * _delta
	
	move_and_slide()
	
	next_frame_velocity = Vector3.ZERO






# déplace l'agent avec la vélocité spécifiée
func move(p_velocity: Vector3) -> void:
	next_frame_velocity = p_velocity


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
		knock_backed = true
		velocity = knockback


# callback quand l'agent prend des dégâts
func _damaged(_amount: int, knockback: Vector3) -> void:
	apply_knockback(knockback)
	if animation_player:
		pass
	
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)

	await get_tree().create_timer(0.3).timeout
	
	if btplayer and not _is_dead:
		btplayer.restart()

func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	
	root.process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	if animation_player:
		animation_player.play(&"Death")
	
	# désactive le BehaviorTree
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	
	# supprime l'agent après un délai
	get_tree().create_timer(10.0).timeout.connect(func ():
		queue_free())

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
	
	# Utilise les paramètres exportés ou tente de les déduire du CollisionShape
	var collision_shape = _get_collision_shape()
	if collision_shape:
		_navigation_agent.radius = _calculate_agent_radius(collision_shape)
		_navigation_agent.height = _calculate_agent_height(collision_shape)
	else:
		_navigation_agent.radius = navigation_radius
		_navigation_agent.height = navigation_height
	
	_navigation_agent.avoidance_enabled = true
	
	# IMPORTANT : Attend le prochain frame physics pour que le NavigationAgent soit prêt
	await get_tree().physics_frame


# Récupère le CollisionShape3D de l'agent
func _get_collision_shape() -> CollisionShape3D:
	for child in get_children():
		if child is CollisionShape3D:
			return child
	return null


# Calcule le rayon basé sur la forme de collision
func _calculate_agent_radius(collision_shape: CollisionShape3D) -> float:
	var shape = collision_shape.shape
	if shape is CapsuleShape3D:
		return shape.radius
	elif shape is CylinderShape3D:
		return shape.radius
	elif shape is BoxShape3D:
		return max(shape.size.x, shape.size.z) / 2.0
	elif shape is SphereShape3D:
		return shape.radius
	return navigation_radius


# Calcule la hauteur basée sur la forme de collision
func _calculate_agent_height(collision_shape: CollisionShape3D) -> float:
	var shape = collision_shape.shape
	if shape is CapsuleShape3D:
		return shape.height
	elif shape is CylinderShape3D:
		return shape.height
	elif shape is BoxShape3D:
		return shape.size.y
	elif shape is SphereShape3D:
		return shape.radius * 2.0
	return navigation_height


# déplace l'agent le long d'un chemin de navigation
func navigate_along_path() -> Vector3i:
	if _navigation_agent and not _navigation_agent.is_navigation_finished():
		return _navigation_agent.get_next_path_position()
	return global_position


func _on_status_manager_status_applied(status: int) -> void:
	if status == Global.StatusEnum.FIRE:
		$Burning.visible = true


func _on_status_manager_status_removed(status: int) -> void:
	if status == Global.StatusEnum.FIRE:
		$Burning.visible = false
