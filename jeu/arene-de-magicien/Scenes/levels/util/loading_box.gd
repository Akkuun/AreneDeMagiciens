extends MeshInstance3D
signal filling_animation_finished
signal emptying_animation_finished

@export var offset_y : float = 5.0
@export var animation_duration : float = 1.0
@export var start_loading_radius : float = 2.0
@export var end_loading_radius : float = 13.0

func _ready() -> void:
	var mat = get_active_material(0)
	mat.set_shader_parameter("sphere_radius", start_loading_radius)

func put_in_place(target: Vector3):
	global_position = target + Vector3.UP * offset_y
	var mat = get_active_material(0)
	mat.set_shader_parameter("sphere_center", target)

func start(player_position : Vector3):
	put_in_place(player_position)
	
	# Récupérer le material (créer une copie unique si nécessaire)
	var mat = get_active_material(0)
	if mat:
		mat = mat.duplicate()
		set_surface_override_material(0, mat)
		
		# Initialiser le radius au début
		mat.set_shader_parameter("sphere_radius", start_loading_radius)
		
		# Créer l'animation de remplissage
		var anim_tween = get_tree().create_tween()
		anim_tween.set_ease(Tween.EASE_IN_OUT)
		anim_tween.set_trans(Tween.TRANS_CUBIC)
		
		
		anim_tween.tween_method(
			func(value): mat.set_shader_parameter("sphere_radius", value),
			start_loading_radius,
			end_loading_radius,
			animation_duration
		)
		
		anim_tween.finished.connect(func(): filling_animation_finished.emit())

func reset():
	var mat = get_active_material(0)
	if mat:
		mat.set_shader_parameter("sphere_radius", start_loading_radius)

func reverse():
	var mat = get_active_material(0)
	if mat:
		mat = mat.duplicate()
		set_surface_override_material(0, mat)
		
		# Récupérer la valeur actuelle ou partir de la fin
		var current_radius = mat.get_shader_parameter("sphere_radius")
		if current_radius == null:
			current_radius = end_loading_radius
		
		var anim_tween = get_tree().create_tween()
		anim_tween.set_ease(Tween.EASE_IN_OUT)
		anim_tween.set_trans(Tween.TRANS_CUBIC)
		
		
		anim_tween.tween_method(
			func(value): mat.set_shader_parameter("sphere_radius", value),
			current_radius,
			0,
			animation_duration
		)
		
		anim_tween.finished.connect(func(): 
			emptying_animation_finished.emit()
		)

func stop():
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
