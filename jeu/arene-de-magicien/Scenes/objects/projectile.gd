extends Node3D
# Projectile basique qui se déplace vers une cible


@export var speed: float = 15.0
@export var damage: float = 10.0

var direction: Vector3 = Vector3.FORWARD
var _max_distance: float = 20.0
var _traveled_distance: float = 0.0


func _ready() -> void:
	print("Projectile created at: ", global_position)
	if has_node("Area3D"):
		var area = get_node("Area3D")
		print("  Area3D monitoring: ", area.monitoring)
		print("  Area3D monitorable: ", area.monitorable)
		print("  Area3D collision_layer: ", area.collision_layer)
		print("  Area3D collision_mask: ", area.collision_mask)


func _physics_process(delta: float) -> void:
	# Si ce projectile a un parent qui gère le mouvement, ne bouge pas
	if get_parent() and get_parent().has_method("_handle_projectile_movement"):
		return
	
	var movement = direction * speed * delta
	global_position += movement
	_traveled_distance += movement.length()
	
	# détruit le projectile s'il a parcouru la distance maximale
	if _traveled_distance >= _max_distance:
		queue_free()


#initialise le projectile avec une direction et une distance maximale
func launch(target_position: Vector3, start_position: Vector3, max_distance: float = 20.0) -> void:
	global_position = start_position
	
	var target_horizontal = target_position
	target_horizontal.y = start_position.y
	
	direction = (target_horizontal - start_position).normalized()
	_max_distance = max_distance
	_traveled_distance = 0.0
	
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)


# a appelé quand le projectile touche quelque chose
func _on_area_entered(area: Area3D) -> void:
	print("Projectile hit area: ", area.name)
	var target = area.get_parent()
	
	while target and not target.has_method("take_damage"):
		target = target.get_parent()
		if target == null or target is Node3D and target.is_in_group("player"):
			break
	
	if target and target.has_method("take_damage"):
		print("Calling take_damage on: ", target.name)
		target.take_damage(damage)
	
	queue_free()

# a appelé quand le projectile entre en collision avec un corps
func _on_body_entered(body: Node3D) -> void:
	print("Projectile hit body: ", body.name)
	if body is StaticBody3D or body is CharacterBody3D:
		if body.has_method("_damaged"):
			print("Calling _damaged on: ", body.name)
			body._damaged(damage, direction * 5.0)
		queue_free()
