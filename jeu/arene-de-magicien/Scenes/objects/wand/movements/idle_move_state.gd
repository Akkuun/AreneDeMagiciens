extends State

@export var wand_root : XRToolsPickable
@export var sensibility : float = 0.1

func get_state_name() -> String:
	return "Idle"




func state_process(delta: float) -> void:
	if wand_root.get_picked_up_by_controller() != null:
		var alignement := wand_root.global_basis.y.dot(Vector3.UP)
		if alignement >= sensibility:
			if($Duration.is_stopped()):
				$Duration.start()
		else:
			$Duration.stop()
	elif !$Duration.is_stopped():
		$Duration.stop()

func _on_duration_timeout() -> void:
	state_manager.change_state("Armed")
