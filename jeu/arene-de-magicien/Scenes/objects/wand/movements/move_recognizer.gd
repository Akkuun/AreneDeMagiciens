class_name MoveRecognizer extends Node

enum MoveType{NONE, UP, CIRCLE, THRUST_Y, THRUST_X, THRUST_DIAG}

var current_move : MoveType = MoveType.NONE

@export var target : Node3D
@export var up_sensibility : float = 0.9

@export var thrust_min_amplitude : float = 1.0
@export var thrust_y_sensibility : float = 0.5


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
	
	if alignement_up >= up_sensibility:
		current_move = MoveType.UP
	
	if movement_amplitude >= thrust_min_amplitude:
		if abs(avg_velocity_direciton.y) >= thrust_y_sensibility:
			current_move = MoveType.THRUST_Y
	
	print(abs(avg_velocity_direciton.y))
	DebugDraw3D.draw_line(target.global_position, target.global_position + target.global_basis.y * movement_amplitude)

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
