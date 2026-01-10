extends State

@export var smoke_effect_node: GPUParticles3D

func get_state_name() -> String:
	return "Fail"

func state_enter(args : Dictionary) -> bool:
	get_tree().create_timer(1).timeout.connect(func ():
		state_manager.change_state("Idle"))
	
	smoke_effect_node.emitting = true
	return true
