class_name StateManager extends Node

signal state_changed(new_state: String)

var current_state : State
var available_states : Dictionary[String, State]

func _ready() -> void:
	for child in get_children():
		if child is State:
			available_states[child.get_state_name()] = child

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.state_process(delta)

func change_state(new_state: String) -> void:
	if(!available_states.has(new_state)):
		return
	
	if current_state != null:
		current_state.state_leave()
	current_state = available_states[new_state]
	current_state.state_enter()
	
	emit_signal("state_changed", current_state.get_state_name())
