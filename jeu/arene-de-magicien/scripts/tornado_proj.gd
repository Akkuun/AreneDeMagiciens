extends RigidBody3D

@export var speed: float = 10.0  # Slower than fireball's 20.0
@export var life_time: float = 5.0
@export var explosion_radius: float = 6.0
@export var explosion_force: float = 10.0
@export var upward_force: float = 5.0
@export var max_damage: float = 35.0
@export var min_damage: float = 10.0
@export var rigid_body_force_multiplier: float = 100.0

@export var timer : Timer

var owner_player: Node
var _dir: Vector3 = Vector3.ZERO
var _age := 0.0

# optional VFX nodes if you use them:

var valid : bool = true

func init(owner: Node, dir: Vector3) -> void:
	owner_player = owner
	_dir = dir.normalized()
	linear_velocity = _dir * speed

func _ready() -> void:
	# If launcher didn't call init(), infer direction from our transform
	if _dir == Vector3.ZERO:
		_dir = (-global_transform.basis.z).normalized()
		linear_velocity = _dir * speed
	look_at(global_position + _dir, Vector3.UP)

func _physics_process(delta: float) -> void:
	if valid:
		_age += delta
		if _age >= life_time:
			explode()

func _on_body_entered(body):
	if !valid: return
	print("Tornado hit: ", body)
	explode()

func _apply_explosion_force_to_character(player):
	if player is CharacterBody3D:
		var dir = (player.global_transform.origin - global_transform.origin).normalized()
		var impulse = dir * explosion_force
		impulse.y += upward_force
		player.velocity += impulse

func _apply_explosion_force_to_rigidbody(body):
	if body is RigidBody3D:
		var dir = (body.global_transform.origin - global_transform.origin).normalized()
		var force = dir * explosion_force * rigid_body_force_multiplier
		body.apply_force(force, body.global_transform.origin)

func explode():
	valid = false
	timer.start()

func _on_timer_timeout():
	queue_free()
