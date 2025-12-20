@tool
extends XRToolsPickable

enum WandState {IDLE, VACUUM}
var can_rotate : bool = true
func change_state(new_state: WandState) -> void:
	if new_state == WandState.VACUUM:
		$Spells.change_state("Vacuum")

var activate = true
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("launch_spell"):
		if activate:
			change_state(WandState.VACUUM)
		else:
			change_state(WandState.IDLE)
		activate = !activate
	elif event.is_action_pressed("debug_lock_rotation"):
		can_rotate = !can_rotate

func _physics_process(delta: float) -> void:
	if can_rotate:
		rotate_x(delta * deg_to_rad(90))


func _on_spells_state_changed(new_state: String) -> void:
	$CurrentState.text = new_state
