@abstract
class_name State extends Node

@abstract
func get_state_name() -> String

func state_process(delta: float) -> void:
	pass

func state_enter(state_manager: StateManager) -> bool:
	return true

func state_leave() -> void:
	pass
