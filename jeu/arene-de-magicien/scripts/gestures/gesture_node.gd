class_name GestureNode extends Node2D

var points_normalized : Array[Vector3]
var points_normalized_int : Array[Vector3i]
var points_raw : Array[Vector3]
@export var gesture_name : StringName
@export var gesture_filename : String
@export var gesture_resource : Gesture
@export var create_new_gesture : bool

signal gesture_classified(GestureName : StringName)
signal normalization_complete()

#region $Q parameters
const SAMPLING_RES : int = 64
const MAX_INT_COORDS : int = 1024
const LUT_SIZE : int = 64
const LUT_SCALE_FACTOR : int = MAX_INT_COORDS / LUT_SIZE
var LUT = {}
#endregion

#region line2d parameters
@export var line_width : float = 5
@export var joint_mode : int = 2
@export var cap_mode : int = 2
#endregion

func _enter_tree() -> void:
	Global.gesture_node = self

var can_draw : bool = false
var stroke : Line2D

func _input(event: InputEvent) -> void:
	if can_draw:
		if event.is_action_pressed("line_press"):
			stroke = Line2D.new()
			stroke.begin_cap_mode = cap_mode
			stroke.end_cap_mode = cap_mode
			stroke.antialiased = true
			stroke.width = line_width
			add_child(stroke)
		if event.is_action_released("line_press"):
			stroke = null

func reset_gesture():
	for child in get_children():
		child.queue_free()
	points_normalized.clear()
	points_normalized_int.clear()
	points_raw.clear()
	gesture_name = ""
	gesture_resource = null

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_draw and stroke != null:
			stroke.add_point(get_global_mouse_position())

# ========== OPTIMISATIONS ASYNC ==========

# Wrapper async pour register_gesture
func register_gesture_async(points: Array[Vector2]):
	await _register_gesture_threaded(points)

func register_gesture(points: Array[Vector2]):
	vec2_array_to_vec3_array(points)
	normalize_points()
	save_gesture_to_resource()

# Version threadée de la normalisation (opération la plus coûteuse)
func _register_gesture_threaded(points: Array[Vector2]):
	vec2_array_to_vec3_array(points)
	
	# Effectuer la normalisation sur un thread séparé
	var thread = Thread.new()
	thread.start(_normalize_points_thread.bind(points_raw.duplicate()))
	
	# Attendre la fin du thread
	await get_tree().process_frame
	while thread.is_alive():
		await get_tree().process_frame
	
	var result = thread.wait_to_finish()
	
	# Récupérer les résultats
	points_normalized = result.normalized
	points_normalized_int = result.normalized_int
	LUT = result.lut
	
	save_gesture_to_resource()
	normalization_complete.emit()

# Fonction qui s'exécute dans un thread
func _normalize_points_thread(raw_points: Array[Vector3]) -> Dictionary:
	var normalized = normalization_resample(raw_points, SAMPLING_RES)
	normalized = normalization_scale(normalized)
	normalized = normalization_translate(normalized, centroid(normalized))
	
	var normalized_int : Array[Vector3i] = []
	normalized_int.resize(normalized.size())
	for i in range(normalized.size()):
		normalized_int[i] = Vector3i(
			int((normalized[i].x + 1.0) / 2.0 * (MAX_INT_COORDS - 1)),
			int((normalized[i].y + 1.0) / 2.0 * (MAX_INT_COORDS - 1)),
			normalized[i].z
		)
	
	var lut = _construct_LUT_threaded(normalized_int)
	
	return {
		"normalized": normalized,
		"normalized_int": normalized_int,
		"lut": lut
	}

# Version optimisée de construct_LUT
func _construct_LUT_threaded(points_int: Array[Vector3i]) -> Dictionary:
	var lut = {}
	
	# Pré-calculer les positions dans la grille pour éviter divisions répétées
	var grid_positions : Array[Vector2i] = []
	grid_positions.resize(points_int.size())
	for t in range(points_int.size()):
		grid_positions[t] = Vector2i(
			points_int[t].x / LUT_SCALE_FACTOR,
			points_int[t].y / LUT_SCALE_FACTOR
		)
	
	for i in range(LUT_SIZE):
		for j in range(LUT_SIZE):
			var min_dist : int = INF
			var index_min : int = -1
			
			for t in range(points_int.size()):
				var row = grid_positions[t].y
				var col = grid_positions[t].x
				# Utiliser distance carrée pour éviter sqrt
				var dist = (row - i) * (row - i) + (col - j) * (col - j)
				
				if dist < min_dist:
					min_dist = dist
					index_min = t
			
			lut[Vector2(i, j)] = index_min
	
	return lut

# Version async de classify
func classify_gesture_async(points: Array[Vector2]):
	await register_gesture_async(points)
	gesture_classified.emit(QPointCloudRecognizer.classify(gesture_resource))
	reset_gesture()

func classiffy_gesture(points: Array[Vector2]):
	register_gesture(points)
	gesture_classified.emit(QPointCloudRecognizer.classify(gesture_resource))
	reset_gesture()

func line_to_vec3_array(line : Line2D, index : int):
	for point in line.points:
		points_raw.append(Vector3(point.x, point.y, index))

func vec2_array_to_vec3_array(points: Array[Vector2]):
	# Optimisation: resize avant d'ajouter pour éviter réallocations
	var start_size = points_raw.size()
	points_raw.resize(start_size + points.size())
	for i in range(points.size()):
		points_raw[start_size + i] = Vector3(points[i].x, points[i].y, 0)

func normalize_points():
	points_normalized = normalization_resample(points_raw, SAMPLING_RES)
	points_normalized = normalization_scale(points_normalized)
	points_normalized = normalization_translate(points_normalized, centroid(points_normalized))
	
	transform_coords_to_integers()
	construct_LUT()

# Normalization functions (optimisées)

func normalization_scale(points : Array[Vector3]) -> Array[Vector3]:
	if points.is_empty():
		return []
	
	var minx = points[0].x
	var miny = points[0].y
	var maxx = points[0].x
	var maxy = points[0].y
	
	# Une seule boucle pour trouver min/max
	for point in points:
		minx = min(minx, point.x)
		miny = min(miny, point.y)
		maxx = max(maxx, point.x)
		maxy = max(maxy, point.y)
	
	var new_points : Array[Vector3] = []
	new_points.resize(points.size())
	var new_scale = max(maxx - minx, maxy - miny)
	
	if new_scale == 0:
		return points
	
	var inv_scale = 1.0 / new_scale  # Éviter divisions répétées
	
	for i in range(points.size()):
		new_points[i] = Vector3(
			(points[i].x - minx) * inv_scale,
			(points[i].y - miny) * inv_scale,
			points[i].z
		)
	
	return new_points

func normalization_translate(points : Array[Vector3], c : Vector3) -> Array[Vector3]:
	var new_points : Array[Vector3] = []
	new_points.resize(points.size())
	
	for i in range(points.size()):
		new_points[i] = Vector3(
			points[i].x - c.x,
			points[i].y - c.y,
			points[i].z
		)
	
	return new_points

func centroid(points : Array[Vector3]) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	
	var cx = 0.0
	var cy = 0.0
	
	for point in points:
		cx += point.x
		cy += point.y
	
	var inv_size = 1.0 / points.size()
	return Vector3(cx * inv_size, cy * inv_size, 0)

func normalization_resample(points : Array[Vector3], n : int) -> Array[Vector3]:
	if points.is_empty():
		return []
	
	var new_points : Array[Vector3] = []
	new_points.resize(n)
	new_points[0] = points[0]
	var num_points = 1
	
	var total_length = path_length(points)
	if total_length == 0:
		return points
	
	var interval_length = total_length / (n - 1)
	var d = 0.0
	
	for i in range(1, points.size()):
		if points[i].z == points[i-1].z:
			var small_d = euclidean_distance(points[i-1], points[i])
			
			if d + small_d >= interval_length:
				var first_point = points[i-1]
				
				while d + small_d >= interval_length and num_points < n:
					var t = clamp((interval_length - d) / small_d, 0.0, 1.0)
					
					if is_nan(t):
						t = 0.5
					
					new_points[num_points] = Vector3(
						lerp(first_point.x, points[i].x, t),
						lerp(first_point.y, points[i].y, t),
						points[i].z
					)
					num_points += 1
					
					small_d = d + small_d - interval_length
					d = 0
					first_point = new_points[num_points - 1]
				
				d = small_d
			else:
				d += small_d
	
	if num_points == n - 1:
		new_points[num_points] = points.back()
	
	return new_points

# Utiliser distance_squared_to quand possible
func euclidean_distance(a : Vector3, b : Vector3) -> float:
	return sqrt(sq_euclidean_distance(a, b))

func sq_euclidean_distance(a : Vector3, b : Vector3) -> float:
	var dx = a.x - b.x
	var dy = a.y - b.y
	return dx * dx + dy * dy

func path_length(points : Array[Vector3]) -> float:
	var length = 0.0
	
	for i in range(1, points.size()):
		if points[i].z == points[i-1].z:
			length += euclidean_distance(points[i-1], points[i])
	
	return length

func transform_coords_to_integers():
	points_normalized_int.resize(points_normalized.size())
	
	var scale_factor = (MAX_INT_COORDS - 1) * 0.5
	
	for i in range(points_normalized.size()):
		points_normalized_int[i] = Vector3i(
			int((points_normalized[i].x + 1.0) * scale_factor),
			int((points_normalized[i].y + 1.0) * scale_factor),
			points_normalized[i].z
		)

func construct_LUT():
	LUT.clear()
	
	# Pré-calculer les positions de grille
	var grid_positions : Array[Vector2i] = []
	grid_positions.resize(points_normalized_int.size())
	
	for t in range(points_normalized_int.size()):
		grid_positions[t] = Vector2i(
			points_normalized_int[t].x / LUT_SCALE_FACTOR,
			points_normalized_int[t].y / LUT_SCALE_FACTOR
		)
	
	for i in range(LUT_SIZE):
		for j in range(LUT_SIZE):
			var min_dist = INF
			var index_min = -1
			
			for t in range(points_normalized_int.size()):
				var row = grid_positions[t].y
				var col = grid_positions[t].x
				var dist = (row - i) * (row - i) + (col - j) * (col - j)
				
				if dist < min_dist:
					min_dist = dist
					index_min = t
			
			LUT[Vector2(i, j)] = index_min

func save_gesture_to_resource():
	gesture_resource = Gesture.new()
	gesture_resource.points_int = points_normalized_int
	gesture_resource.points = points_normalized
	gesture_resource.LUT = LUT
	
	if gesture_name != "" and create_new_gesture:
		gesture_resource.gesture_name = gesture_name
		save_gesture_to_disk()

func save_gesture_to_disk():
	var save_path = "res://gesture_templates/"
	ResourceSaver.save(gesture_resource, save_path + gesture_filename + ".tres")
	ResourceLoader.load(save_path + gesture_filename + ".tres")
