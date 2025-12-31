extends State


@export var wand: XRToolsPickable
@export var gesture_threshold: float = 0.5
@export var circle_detection_points: int = 8
@export var circle_radius_tolerance: float = 0.3

@export var min_circle_radius: float = 0.1
@export var circle_time_window: float = 1.5


signal move_detected(move : Global.MoveTypeEnum)

var position_history: Array[Vector3] = []
var max_history_size: int = 30
var velocity_history: Array[float] = []
var max_velocity_history: int = 10

var last_tilt: float = 0.0
var tilt_acc = 0.0

@export var tilt_down_threshold: float = 0.5
@export var min_thrust_velocity: float = 2.0


func get_state_name() -> String:
	return "Tilting"

func state_enter(args: Dictionary) -> bool:
	tilt_acc = 0.0
	last_tilt = wand.global_transform.basis.y.y
	position_history.clear()
	velocity_history.clear()
	return true
func state_process(delta: float) -> void:
	_update_position_history(delta)
	
	# Détection des gestes
	_detect_thrust_forward()
	_detect_circular_motion()
	
	debug_draw_circle_history()


func _detect_thrust_forward() -> void:
	var forward = wand.global_transform.basis.y
	var tilt = forward.y
	var tilt_diff = tilt - last_tilt
	tilt_acc -= tilt_diff
	
	# Calculer la vitesse moyenne récente
	var avg_velocity = _get_average_velocity()
	
	
	# Détection d'un mouvement d'abaissement brusque ET rapide
	if tilt_acc >= tilt_down_threshold and avg_velocity >= min_thrust_velocity:
		move_detected.emit(Global.MoveTypeEnum.SEND)
		_clear_history()
		state_manager.change_state("Idle")
	
	last_tilt = tilt

func _update_position_history(delta: float) -> void:
	var wand_tip_position = wand.global_position
	
	# Calculer la vélocité si on a un historique
	if position_history.size() > 0:
		var last_pos = position_history[position_history.size() - 1]
		var velocity = last_pos.distance_to(wand_tip_position) / delta
		velocity_history.append(velocity)
		
		# Limiter la taille de l'historique de vélocité
		if velocity_history.size() > max_velocity_history:
			velocity_history.pop_front()
	
	position_history.append(wand_tip_position)
	
	# Limiter la taille de l'historique
	if position_history.size() > max_history_size:
		position_history.pop_front()

func _get_average_velocity() -> float:
	if velocity_history.is_empty():
		return 0.0
	
	var sum = 0.0
	for vel in velocity_history:
		sum += vel
	return sum / velocity_history.size()

func _detect_circular_motion() -> void:
	if position_history.size() < circle_detection_points:
		return
	
	# Analyser les derniers points pour détecter un cercle
	var circle_data = _analyze_circular_pattern()
	
	if circle_data.is_circle:
		move_detected.emit(Global.MoveTypeEnum.TORNADO)
		_clear_history()
		state_manager.change_state("Idle")

func _analyze_circular_pattern() -> Dictionary:
	var result = {
		"is_circle": false,
		"center": Vector3.ZERO,
		"radius": 0.0
	}
	
	if position_history.size() < circle_detection_points:
		return result
	
	# Calculer le centre approximatif
	var center = Vector3.ZERO
	for pos in position_history:
		center += pos
	center /= position_history.size()
	result.center = center
	
	# Calculer le rayon moyen
	var avg_radius = 0.0
	for pos in position_history:
		avg_radius += center.distance_to(pos)
	avg_radius /= position_history.size()
	result.radius = avg_radius
	
	# Vérifier que tous les points sont à une distance similaire du centre (tolérance)
	var radius_variance = 0.0
	for pos in position_history:
		var dist = center.distance_to(pos)
		radius_variance += abs(dist - avg_radius)
	radius_variance /= position_history.size()
	
	if radius_variance > circle_radius_tolerance:
		return result  # Pas un cercle assez régulier
	
	
	result.is_circle = radius_variance <= circle_radius_tolerance and avg_radius >= min_circle_radius
	
	$"../../DebugText".text = "avg rad: " + str(avg_radius)
	
	return result


func _clear_history() -> void:
	position_history.clear()
	velocity_history.clear()
	tilt_acc = 0.0
	

func debug_draw_circle_history() -> void:
	if position_history.size() < 2:
		return
	
	var trajectory : PackedVector3Array = []	
	for pos in position_history:
		trajectory.push_back(pos)
	
	DebugDraw3D.draw_line_path(trajectory)
