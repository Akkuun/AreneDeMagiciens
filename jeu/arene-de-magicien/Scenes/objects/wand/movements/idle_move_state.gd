extends State

@export var wand_root : XRToolsPickable
@export var move_recognizer : MoveRecognizer

func get_state_name() -> String:
	return "Idle"




func state_process(delta: float) -> void:
	if wand_root.get_picked_up_by_controller() != null:
		if move_recognizer.current_move == MoveRecognizer.MoveType.UP:
			move_recognizer.consume_move()
			if($Duration.is_stopped()):
				$Duration.start()
		else:
			$Duration.stop()
	elif !$Duration.is_stopped():
		$Duration.stop()

func _on_duration_timeout() -> void:
	state_manager.change_state("Armed")
