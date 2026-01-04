extends State

@export var wand_root : XRToolsPickable
@export var move_recognizer : MoveRecognizer

func get_state_name() -> String:
	return "Circle"


func state_process(delta: float) -> void:
	if wand_root.is_picked_up():
		if move_recognizer.current_move == MoveRecognizer.MoveType.THRUST_Y:
			move_recognizer.consume_move()
			state_manager.change_state("Aim", {"Type": "Tornado"})
