extends State

@export var wand_root : XRToolsPickable
@export var move_recognizer : MoveRecognizer

var is_horizontal : bool = false
var is_from_bot : bool = false

func get_state_name() -> String:
	return "Armed"

func state_enter(args : Dictionary) -> bool:
	is_horizontal = args.initial_orientation == MoveRecognizer.MoveType.FORWARD
	is_from_bot = args.initial_orientation == MoveRecognizer.MoveType.DOWN
	return true

func state_process(delta: float) -> void:
	if wand_root.is_picked_up():
		if move_recognizer.current_move == MoveRecognizer.MoveType.THRUST_Y:
			if is_from_bot:
				state_manager.change_state("Earth")
			else:
				state_manager.change_state("Aim", {"Type": "Fire"})
		elif move_recognizer.current_move == MoveRecognizer.MoveType.CIRCLE:
			if is_horizontal:
				state_manager.change_state("Vacuum")
			else:
				state_manager.change_state("Circle")
