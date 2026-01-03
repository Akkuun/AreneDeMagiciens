extends Node3D

@export var radius : float = 5.0
@export var min_distance_between_effects: float = 1.0
@export var fire_effect : PackedScene

var spawned_positions: Array[Vector3] = []

func radius_ray_cast_uniform(center: Vector3, ray_quantity: int, ray_range: float) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	
	var golden_ratio = (1.0 + sqrt(5.0)) / 2.0
	var angle_increment = PI * 2.0 * golden_ratio
	
	for i in range(ray_quantity):
		var t = float(i) / float(ray_quantity)
		var inclination = acos(1.0 - 2.0 * t)
		var azimuth = angle_increment * float(i)
		
		var ray_dir = Vector3(
			sin(inclination) * cos(azimuth),
			sin(inclination) * sin(azimuth),
			cos(inclination)
		)
		
		var query := PhysicsRayQueryParameters3D.create(center, center + ray_dir * ray_range, 1)
		var space_state = get_world_3d().direct_space_state
		var cast_res = space_state.intersect_ray(query)
		
		DebugDraw3D.draw_line(center, center + ray_dir * ray_range)
		
		if cast_res:
			res.append(cast_res)
	
	return res

func is_far_enough(new_position: Vector3) -> bool:
	for existing_pos in spawned_positions:
		if existing_pos.distance_to(new_position) < min_distance_between_effects:
			return false
	return true

func spawn_effect_at(world_position: Vector3) -> void:
	var decal_instance = fire_effect.instantiate() as Node3D
	decal_instance.rotate_y(randf() * 2.0 * PI)
	
	decal_instance.position = to_local(world_position)
	
	add_child(decal_instance)
	
	spawned_positions.append(world_position)

func _ready() -> void:
	var colliding_objects = radius_ray_cast_uniform(global_position, 48, radius)
	for collision in colliding_objects:
		if is_far_enough(collision.position):
			spawn_effect_at(collision.position)

func _on_duration_timeout() -> void:
	queue_free()
