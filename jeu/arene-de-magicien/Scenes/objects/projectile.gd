extends Node3D
# Projectile basique qui se déplace vers une cible


@export var speed: float = 15.0
@export var damage: float = 10.0

var direction: Vector3 = Vector3.FORWARD
var _max_distance: float = 20.0
var _traveled_distance: float = 0.0


func _physics_process(delta: float) -> void:
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
	var body = area.get_parent()
	if body and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

# a appelé quand le projectile entre en collision avec un corps
func _on_body_entered(body: Node3D) -> void:
	if body is StaticBody3D or body is CharacterBody3D:
		queue_free()
