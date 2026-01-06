extends Node3D

@export var speed: float = 20.0
@export var life_time: float = 5.0
@export var explosion_radius: float = 6.0
@export var explosion_force: float = 10.0
@export var upward_force: float = 5.0
@export var max_damage: float = 35.0
@export var min_damage: float = 10.0
@export var rigid_body_force_multiplier: float = 100.0

@export var smoke_big : GPUParticles3D
@export var explosion_big : GPUParticles3D
@export var fire_small : GPUParticles3D

@export var timer : Timer

var owner_player: Node
var _dir: Vector3 = Vector3.ZERO
var _age := 0.0
var _traveled_distance: float = 0.0
var _max_distance: float = 20.0

# optional VFX nodes if you use them:

var valid : bool = true

# Indique au projectile enfant que le parent gère le mouvement
func _handle_projectile_movement() -> void:
	pass

func init(owner: Node, dir: Vector3) -> void:
	owner_player = owner
	_dir = dir.normalized()
	# look_at(global_position + _dir, Vector3.UP)
	# use look_at_from_position()
	# global_transform = Transform3D().looking_at(_dir, Vector3.UP).translated(global_transform.origin)

func _ready() -> void:
	# If launcher didn't call init(), infer direction from our transform
	if _dir == Vector3.ZERO:
		_dir = (-global_transform.basis.z).normalized()
		look_at(global_position + _dir, Vector3.UP)

func _physics_process(delta: float) -> void:
	if valid:
		var movement = _dir * speed * delta
		global_position += movement
		_traveled_distance += movement.length()
		
		_age += delta
		if _age >= life_time or _traveled_distance >= _max_distance:
			explode()
		

func _on_area_3d_body_entered(body):
	if !valid: return
	print("=-===-=--=-=-=-=-=")
	print(body)
	print("=-===-=--=-=-=-=-=")
	explode()
	
func _calc_damage(dist: float) -> float:
	if dist > explosion_radius: return 0.0
	var t = dist / explosion_radius
	var dmg = max_damage - t * (max_damage - min_damage)
	return clamp(dmg, min_damage, max_damage)

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
	hide_smoke()
	valid = false
	timer.start()
	

func hide_smoke():
	$Emitter.emitting = false
	$Flame.emitting = false
	$Smoke.emitting = false
	$FireSmall/Flame.emitting = false
	$FireSmall/Smoke.emitting = false
	$FireSmall/Sparks.emitting = false

func _on_timer_timeout():
	queue_free()
