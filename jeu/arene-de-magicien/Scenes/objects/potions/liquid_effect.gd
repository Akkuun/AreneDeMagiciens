@tool
extends Node3D

@export var animation_speed: float = 1
@export var animation_curve : Curve = Curve.new()
@export_tool_button("Simulate") var add_impulse_action = func(): add_impulse(Vector2(0.2,0.6), 0.5)
@export var base_color = Color() :
	set(value): 
		base_color_set(value)
	get:
		return _base_color
@export var top_color: Color :
	set(value):
		top_color_set(value)
	get:
		return _top_color
@export_range(0,1,0.01) var fill_rate: float:
	set(value):
		_fill_rate = value
		update_global_param("fill_rate", value)
	get:
		return _fill_rate
@export var mesh: Mesh:
	set(value):
		_mesh = value
		if is_node_ready():
			if(value != null):
				$Top.mesh = value.duplicate()
				$Bot.mesh = value.duplicate()
			else:
				$Top.mesh = null
				$Bot.mesh = null
			
			if($Top.mesh is BoxMesh):
				$Top.mesh.flip_faces = true
			elif($Top.mesh is CapsuleMesh):
				$Top.mesh.flip_faces = true
			elif($Top.mesh is SphereMesh):
				$Top.mesh.flip_faces = true
			elif($Top.mesh is TorusMesh):
				$Top.mesh.flip_faces = true
			elif($Top.mesh is CylinderMesh):
				$Top.mesh.flip_faces = true
			elif($Top.mesh is PrismMesh):
				$Top.mesh.flip_faces = true

	get:
		return _mesh

var _base_color: Color
var _top_color: Color
var _mesh: Mesh
var _fill_rate: float

var shader_instances : Array[ShaderMaterial]

var impulse_strength: float
var impulse_direction: Vector2
var t:float

var last_world_pos: Vector3 = Vector3.ZERO
var threshold: float = 0.05

func _ready() -> void:
	shader_instances = [load("res://resources/materials/liquid_contained.tres").duplicate(), load("res://resources/materials/liquid_contained.tres").duplicate()]
	$Top.material_override = shader_instances[0]
	$Bot.material_override = shader_instances[1]
	shader_instances[0].set_shader_parameter("use_top_color", true)
	shader_instances[1].set_shader_parameter("use_top_color", false)
	shader_instances[0].render_priority = 0
	shader_instances[1].render_priority = 1
	
	mesh = _mesh
	base_color = _base_color
	top_color = _top_color

func update_global_param(param_name: String, value):
	for s in shader_instances:
		s.set_shader_parameter(param_name, value)

func add_impulse(direction: Vector2, strength: float):
	impulse_strength = strength
	impulse_direction = direction
	t = 0

func _process(delta: float) -> void:
	if(t > 1.0): return
	t += delta * animation_speed
	var stabilisation = animation_curve.sample(t) * impulse_strength
	update_wobble(stabilisation * impulse_direction)

func _physics_process(delta: float) -> void:
	var current_pos := global_transform.origin
	var delta_move := current_pos - last_world_pos

	var dist := delta_move.length()
	if dist > threshold:
		var dir2d := Vector2(delta_move.x, delta_move.z).normalized()
		var strength := dist * delta
		add_impulse(dir2d, strength)

	last_world_pos = current_pos

func update_wobble(value: Vector2):
	update_global_param("wobble_x", value.x)
	update_global_param("wobble_y", value.y)

func base_color_set(new_color: Color):
	_base_color = new_color
	if(is_node_ready()):
		shader_instances[1].call_deferred("set_shader_parameter", "bot_color", new_color)

func top_color_set(new_color: Color):
	_top_color = new_color
	if(is_node_ready()):
		shader_instances[0].call_deferred("set_shader_parameter", "top_color", new_color)
