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


func _on_status_giver_body_entered(body: Node3D) -> void:
	queue_free()


func _on_status_giver_area_entered(area: Area3D) -> void:
	queue_free()
