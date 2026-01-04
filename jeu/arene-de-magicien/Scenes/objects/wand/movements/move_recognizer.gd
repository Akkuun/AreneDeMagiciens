class_name MoveRecognizer extends Node

enum MoveType{NONE, UP, CIRCLE, THRUST_Y, THRUST_X, THRUST_DIAG}

var current_move : MoveType = MoveType.NONE

@export var target : Node3D
@export var up_sensibility : float = 0.9

@export var thrust_min_amplitude : float = 1.0
@export var thrust_y_sensibility : float = 0.5

@export var circle_detection_points : int = 30
@export var circle_radius_tolerance : float = 2.0
@export var min_circle_radius : float = 1.0


var position_history: Array[Vector3] = []
var max_history_size: int = 30
var velocity_history: Array[float] = []
var max_velocity_history: int = 10

var avg_velocity_direciton : Vector3 = Vector3.ZERO
var movement_amplitude : float = 0.0



func consume_move():
	current_move = MoveType.NONE
	
	position_history.clear()
	velocity_history.clear()
	avg_velocity_direciton = Vector3.ZERO
	movement_amplitude = 0.0

func _ready() -> void:
	consume_move()

func _physics_process(delta: float) -> void:
	var alignement_up := target.global_basis.y.dot(Vector3.UP)
	
	_update_target_history(delta)
	_compute_movement()
	var is_circle := _detect_circular_motion()
	debug_draw_circle_history()
	
	if is_circle:
		current_move = MoveType.CIRCLE
	elif movement_amplitude >= thrust_min_amplitude:
		if abs(avg_velocity_direciton.y) >= thrust_y_sensibility:
			current_move = MoveType.THRUST_Y
	elif alignement_up >= up_sensibility:
		current_move = MoveType.UP

func _update_target_history(delta: float) -> void:
	var tip_position = target.global_position
	
	if position_history.size() > 0:
		var last_pos = position_history[position_history.size() - 1]
		var velocity = last_pos.distance_to(tip_position) / delta
		velocity_history.append(velocity)
		
		if velocity_history.size() > max_velocity_history:
			velocity_history.pop_front()
	
	position_history.append(tip_position)
	
	if position_history.size() > max_history_size:
		position_history.pop_front()

func _compute_movement():
	movement_amplitude = 0.0
	avg_velocity_direciton = Vector3.ZERO
	
	for i in range(position_history.size()):
		if i > 0:
			var frame_direction = position_history[i] - position_history[i-1]
			movement_amplitude += frame_direction.length()
			avg_velocity_direciton += frame_direction
	
	avg_velocity_direciton = avg_velocity_direciton.normalized()


func _detect_circular_motion() -> bool:
	if position_history.size() < circle_detection_points:
		return false
	
	var center := Vector3.ZERO

	center = Vector3.ZERO
	for pos in position_history:
		center += pos
	center /= position_history.size()

	var radius = 0.0
	for pos in position_history:
		radius += center.distance_to(pos)
	radius /= position_history.size()

	var radius_variance = 0.0
	for pos in position_history:
		var dist = center.distance_to(pos)
		radius_variance += abs(dist - radius)
	radius_variance /= position_history.size()

	if radius_variance > circle_radius_tolerance:
		return false
	
	var total_angle = 0.0
	for i in range(1, position_history.size()):
		var v1 = (position_history[i-1] - center).normalized()
		var v2 = (position_history[i] - center).normalized()
		
		var angle = acos(clamp(v1.dot(v2), -1.0, 1.0))
		total_angle += angle
	
	var min_angle_for_circle = PI * 1.5

	var first_to_last = position_history[0].distance_to(position_history[-1])
	var diameter = radius * 2.0
	
	var is_closed_loop = first_to_last < (diameter * 0.3)
	
	return total_angle >= min_angle_for_circle and is_closed_loop

func debug_draw_circle_history() -> void:
	if position_history.size() < 2:
		return

	var trajectory : PackedVector3Array = []	
	for pos in position_history:
		trajectory.push_back(pos)

	DebugDraw3D.draw_line_path(trajectory)
