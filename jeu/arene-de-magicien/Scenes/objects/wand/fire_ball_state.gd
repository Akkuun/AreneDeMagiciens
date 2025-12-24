extends State

@onready var fireball_scene = load("res://Scenes/objects/fire_ball/fire_ball_projectile.tscn")

@export var wand_muzzle : RayCast3D

func get_state_name() -> String:
	return "FireBall"

func state_enter(state_manager: StateManager) -> bool:
	var ball_instance = fireball_scene.instantiate()
	ball_instance.initial_direction = wand_muzzle.global_basis.y
	ball_instance.position = wand_muzzle.global_position
	get_tree().get_nodes_in_group("root_3d").front().add_child(ball_instance)
	
	state_manager.change_state("Idle")
	return true
