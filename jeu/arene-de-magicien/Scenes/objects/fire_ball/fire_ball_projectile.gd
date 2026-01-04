extends Area3D

@export var _dir : Vector3 = Vector3(0,0,1)
var _age := 0.0

@export var speed: float = 20.0
@export var life_time: float = 5.0
@export var explosion_radius: float = 6.0
@export var explosion_force: float = 10.0
@export var upward_force: float = 5.0
@export var max_damage: float = 35.0
@export var min_damage: float = 10.0
@export var rigid_body_force_multiplier: float = 100.0


func init(owner: Node, dir: Vector3) -> void:
	#owner_player = owner
	_dir = dir.normalized()
	look_at(global_position + _dir, Vector3.UP)
	# use look_at_from_position()
	# global_transform = Transform3D().looking_at(_dir, Vector3.UP).translated(global_transform.origin)

func _physics_process(delta: float) -> void:
	global_position += _dir * speed * delta
	_age += delta
	if _age >= life_time:
		explode()

func _calc_damage(dist: float) -> float:
	if dist > explosion_radius: return 0.0
	var t = dist / explosion_radius
	var dmg = max_damage - t * (max_damage - min_damage)
	return clamp(dmg, min_damage, max_damage)


func _apply_explosion_force_to_rigidbody(body):
	if body is RigidBody3D:
		var dir = (body.global_transform.origin - global_transform.origin).normalized()
		var force = dir * explosion_force * rigid_body_force_multiplier
		body.apply_force(force, body.global_transform.origin)
	elif body is CharacterBody3D:
		var dir = (body.global_transform.origin - global_transform.origin).normalized()
		var impulse = dir * explosion_force
		impulse.y += upward_force
		body.velocity += impulse

func hide_smoke():
	$Emitter.emitting = false
	$Flame.emitting = false
	$Smoke.emitting = false
	$FireSmall/Flame.emitting = false
	$FireSmall/Smoke.emitting = false
	$FireSmall/Sparks.emitting = false

func explode():
	hide_smoke()
	queue_free()
	#timer.start()


func _on_body_entered(body: Node3D) -> void:
	_apply_explosion_force_to_rigidbody(body)
	explode()
