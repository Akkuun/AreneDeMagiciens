extends State

@onready var fireball_scene : PackedScene = load("res://Scenes/objects/fire_ball/fire_ball_projectile.tscn")
@onready var fireball_preparation_scene : PackedScene = load("res://Scenes/objects/fire_ball/fire_preparation.tscn")

@onready var tornado_scene : PackedScene = load("res://scenes/objects/tornado/tornado.tscn")

@export var wand_muzzle : RayCast3D
@export var effect_target : Node3D

var effect : Node3D 

func get_state_name() -> String:
	return "Aim"

enum ProjType{TORNADO, FIRE}

func shoot(type: ProjType):
	effect.queue_free()
	
	var projectile_instance : Node3D
	match type:
		ProjType.FIRE:
			projectile_instance = fireball_scene.instantiate()
		ProjType.TORNADO:
			projectile_instance = tornado_scene.instantiate()
	
	projectile_instance.position = wand_muzzle.global_position
	projectile_instance.ready.connect(func(): projectile_instance.init(wand_muzzle, wand_muzzle.global_basis.y))
	get_tree().get_nodes_in_group("root_3d").front().add_child(projectile_instance)
	state_manager.change_state("Idle")

func state_process(delta: float) -> void:
	effect.global_position = effect_target.global_position

func state_enter(args : Dictionary) -> bool:
	if args.Type == "Fire":
		get_tree().create_timer(3).timeout.connect(func(): shoot(ProjType.FIRE))
		effect = fireball_preparation_scene.instantiate()
		get_tree().get_nodes_in_group("root_3d").front().add_child(effect)
	else:
		get_tree().create_timer(1).timeout.connect(func(): shoot(ProjType.TORNADO))
	
	return true


#func launchFireball():
	#var fireball_instance = fireball.instantiate()
	#var hand_transform = left_hand_controller.global_transform
	#var direction = -hand_transform.basis.z
	#fireball_instance.init(self, direction)
	#get_parent().add_child(fireball_instance)
	#fireball_instance.global_transform = Transform3D().looking_at(direction, Vector3.UP).translated(hand_transform.origin)
#
#func launchTornado():
	#var tornado_instance = tornado.instantiate()
	#var hand_transform = left_hand_controller.global_transform
	#var direction = -hand_transform.basis.z
	#tornado_instance.init(self, direction)
	#get_parent().add_child(tornado_instance)
	#tornado_instance.global_transform = Transform3D().looking_at(direction, Vector3.UP).translated(hand_transform.origin)
