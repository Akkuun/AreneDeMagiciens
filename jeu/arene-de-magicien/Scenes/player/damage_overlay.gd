extends MeshInstance3D
# Affiche un overlay rouge quand le joueur prend des dégâts en VR

@export var fade_duration: float = 0.5
@export var max_alpha: float = 0.6

var _tween: Tween
var _material: StandardMaterial3D


func _ready() -> void:
	print("Damage overlay ready")
	
	# Crée un quad mesh devant la caméra
	mesh = QuadMesh.new()
	mesh.size = Vector2(10, 10)  # Grand pour couvrir la vue
	
	# Crée le matériau rouge semi-transparent
	_material = StandardMaterial3D.new()
	_material.albedo_color = Color(1, 0, 0, 0)  # Rouge, commence invisible
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material.no_depth_test = true  # Toujours visible devant tout
	
	set_surface_override_material(0, _material)
	
	# Positionne devant la caméra
	position = Vector3(0, 0, -0.1)


func show_damage() -> void:
	print("Showing damage overlay")
	# Annule l'animation précédente si elle existe
	if _tween:
		_tween.kill()
	
	# Crée une nouvelle animation
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_OUT)
	
	# Flash rouge qui fade out
	_tween.tween_property(_material, "albedo_color:a", max_alpha, 0.1)
	_tween.tween_property(_material, "albedo_color:a", 0.0, fade_duration)
