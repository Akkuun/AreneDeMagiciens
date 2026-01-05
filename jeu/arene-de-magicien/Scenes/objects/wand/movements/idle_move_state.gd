extends State

@export var wand_root : XRToolsPickable
@export var move_recognizer : MoveRecognizer

func get_state_name() -> String:
	return "Idle"

var init_move : MoveRecognizer.MoveType
func state_enter(args : Dictionary) -> bool:
	init_move = move_recognizer.current_move
	return true


func state_process(delta: float) -> void:
	if wand_root.get_picked_up_by_controller() != null:
		if move_recognizer.current_move == init_move:
			return
		var is_up := move_recognizer.current_move == MoveRecognizer.MoveType.UP
		var is_down := move_recognizer.current_move == MoveRecognizer.MoveType.DOWN
		var is_fwd := move_recognizer.current_move == MoveRecognizer.MoveType.FORWARD
		
		if is_up or is_down or is_fwd:
			if($Duration.is_stopped()):
				move_recognizer.consume_move()
				$Duration.start()
		else:
			$Duration.stop()
	elif !$Duration.is_stopped():
		$Duration.stop()

func state_leave() -> void:
	move_recognizer.consume_move()

func _on_duration_timeout() -> void:
	state_manager.change_state("Armed", {"initial_orientation" :  move_recognizer.current_move})
