extends Area3D

@export var initial_direction : Vector3 = Vector3(0,0,1)
@export var initial_speed : float = 1.0

var velocity : Vector3

func _ready() -> void:
	velocity = initial_direction * initial_speed

func _physics_process(delta: float) -> void:
	position += velocity * delta
