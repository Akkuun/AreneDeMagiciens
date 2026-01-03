extends State

@onready var fireball_scene : PackedScene = load("res://Scenes/objects/fire_ball/fire_ball_projectile.tscn")
@onready var tornado_scene : PackedScene = load("res://scenes/objects/tornado/tornado.tscn")

@export var wand_muzzle : RayCast3D

func get_state_name() -> String:
	return "Projectile"

func state_enter(args : Dictionary) -> bool:
	var projectile_instance : Node3D
	if args.type == "fire":
		projectile_instance = fireball_scene.instantiate()
	else:
		projectile_instance = tornado_scene.instantiate()
	
	projectile_instance.initial_direction = wand_muzzle.global_basis.y
	projectile_instance.position = wand_muzzle.global_position
	get_tree().get_nodes_in_group("root_3d").front().add_child(projectile_instance)
	
	state_manager.change_state("Idle")
	return true
