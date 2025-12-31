extends State


func get_state_name() -> String:
	return "Vacuum"

@export var wand_root_node : Node3D
@export var wand_muzzle : RayCast3D

@export var vacuum_width : float = 1.0
@export var vacuum_segment_length : float = 2.0
@export var vacuum_segment_count : int = 6

@export_flags_3d_physics var collision_mask : int 

var vacuum_end_marker := Marker3D.new()
var vacuum_start_position : Vector3
var vacuum_start_direction : Vector3

var vacuum_path := Path3D.new()
var vacuum_follow := PathFollow3D.new()
var cylinder_shape : CylinderShape3D

var vacuum_areas : Array[Area3D] = []

class BodyData:
	var count: int
	var t: float

var overlapped_bodies_refs : Dictionary[RigidBody3D, BodyData]


func _enter_tree() -> void:
	wand_root_node.get_parent_node_3d().call_deferred("add_child", vacuum_path)
	
	vacuum_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	
	vacuum_path.add_child(vacuum_follow)
	vacuum_path.curve = Curve3D.new()
	cylinder_shape = CylinderShape3D.new()
	cylinder_shape.height = vacuum_segment_length
	cylinder_shape.radius = vacuum_width
	
	vacuum_path.curve.add_point(wand_muzzle.global_position)
	vacuum_path.curve.add_point(wand_muzzle.global_position + Vector3.UP)
	#vacuum_path.curve.add_point(wand_muzzle.global_position + Vector3.UP * 2.0)
	
	add_child(vacuum_end_marker)
	
	for i in range(vacuum_segment_count):
		var segment_collision_area := Area3D.new()
		var segment_collision := CollisionShape3D.new()
		segment_collision.shape = cylinder_shape
		segment_collision_area.add_child(segment_collision)
		add_child(segment_collision_area)
		
		segment_collision_area.connect("body_entered", on_body_entered)
		segment_collision_area.connect("body_exited", on_body_left)
		segment_collision_area.collision_mask = collision_mask
		vacuum_areas.append(segment_collision_area)

func get_closest_t(position: Vector3):
	var closest : float = INF
	var closest_t = 0;
	for i in range(32):
		var t := float(i/32.0)
		vacuum_follow.progress_ratio = t
		var dist = vacuum_follow.global_position.distance_to(position)
		if dist < closest:
			closest = dist
			closest_t = t * vacuum_path.curve.get_baked_length()
	
	return closest_t

func on_body_entered(body: Node3D):
	if(!body is RigidBody3D || body == wand_root_node):
		return
	add_body_count(body as RigidBody3D)

func add_body_count(rigid_body: RigidBody3D):
	if(!overlapped_bodies_refs.has(rigid_body)):
		overlapped_bodies_refs[rigid_body] = BodyData.new()
		overlapped_bodies_refs[rigid_body].count = 1
		overlapped_bodies_refs[rigid_body].t = get_closest_t(rigid_body.global_position)
	else:
		overlapped_bodies_refs[rigid_body].count += 1

func on_body_left(body: Node3D):
	if(!body is RigidBody3D || body == wand_root_node):
		return
	
	var rigid_body = body as RigidBody3D
	if(overlapped_bodies_refs[rigid_body].count <= 1):
		overlapped_bodies_refs.erase(rigid_body)
	else:
		overlapped_bodies_refs[rigid_body].count -= 1

func state_leave() -> void:
	vacuum_path.curve.set_point_position(0, Vector3.ZERO)
	vacuum_path.curve.set_point_position(1, Vector3.ZERO)
	
	for area in vacuum_areas:
		area.set_process(false)

func state_enter(args : Dictionary) -> bool:
	if !wand_muzzle.is_colliding():
		return false
	
	vacuum_end_marker.reparent(wand_muzzle.get_collider())
	vacuum_end_marker.global_position = wand_muzzle.get_collision_point()
	vacuum_path.curve.set_point_position(1, vacuum_end_marker.global_position)
	
	overlapped_bodies_refs.clear()
	
	for area in vacuum_areas:
		area.set_process(true)
		area.reparent(wand_root_node.get_parent_node_3d())
		for b in area.get_overlapping_bodies():
			add_body_count(b)
	
	return true

func state_process(delta: float):	
	if wand_muzzle.is_colliding():
		vacuum_start_position = wand_muzzle.get_collision_point()
		vacuum_start_direction = wand_muzzle.get_collision_normal()
		vacuum_path.curve.set_point_position(0, vacuum_start_position)
		vacuum_path.curve.set_point_out(0, vacuum_start_direction)
	
	var dir_to_wand := (wand_muzzle.global_position - vacuum_end_marker.global_position).normalized()
	vacuum_path.curve.set_point_in(1, (vacuum_end_marker.global_basis.y + dir_to_wand * 0.1).normalized())
	#vacuum_path.curve.set_point_position(1, wand_muzzle.global_position)
	#vacuum_path.curve.set_point_out(1, -wand_muzzle.global_basis.y)
	vacuum_path.curve.set_point_position(1, vacuum_end_marker.global_position)
	
	DebugDraw3D.draw_line_path(vacuum_path.curve.get_baked_points())
	
	#var segment_count_diff = vacuum_colliders.size() - floor(vacuum_path.curve.get_baked_length() / vacuum_segment_length)
	# Need more segment
	#if segment_count_diff > 0:
	
	for i in range(vacuum_segment_count):
		var t = (i) / float(vacuum_segment_count)
		vacuum_follow.progress_ratio = t
		
		var segment_collision_area = vacuum_areas[i]
		
		segment_collision_area.global_transform = vacuum_follow.global_transform
		segment_collision_area.rotate_x(deg_to_rad(90))
		segment_collision_area.translate(Vector3.UP * vacuum_segment_length * 0.5)
	
	const moving_speed = 1.0
	const suction_force := 17.0
	var curve := vacuum_path.curve
	var length := curve.get_baked_length()

	# Vibe coded part
	# Goal: move rigid bodies along path 
	for body in overlapped_bodies_refs.keys():
		var data := overlapped_bodies_refs[body]
		data.t = min(data.t + moving_speed * delta, length)

		var p := curve.sample_baked(data.t)

		var p_next := curve.sample_baked(min(data.t + 0.05, length))
		var tangent := (p_next - p).normalized()

		body.apply_central_force(tangent * suction_force)

		var to_curve = (p - body.global_position)
		body.apply_central_force(to_curve * 5.0)
