@abstract
class_name State extends Node

@abstract
func get_state_name() -> String

var state_manager : StateManager

func state_process(delta: float) -> void:
	pass

func state_enter(args : Dictionary) -> bool:
	return true

func state_leave() -> void:
	pass
