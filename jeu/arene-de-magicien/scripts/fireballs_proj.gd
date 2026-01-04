extends Node3D

@export var smoke_big : GPUParticles3D
@export var explosion_big : GPUParticles3D
@export var fire_small : GPUParticles3D

@export var timer : Timer

var owner_player: Node
var _dir: Vector3 = Vector3.ZERO


func _ready() -> void:
	# If launcher didn't call init(), infer direction from our transform
	if _dir == Vector3.ZERO:
		_dir = (-global_transform.basis.z).normalized()
		look_at(global_position + _dir, Vector3.UP)

func _on_timer_timeout():
	queue_free()
