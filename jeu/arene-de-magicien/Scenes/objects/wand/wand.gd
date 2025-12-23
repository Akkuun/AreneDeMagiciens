@tool
extends XRToolsPickable

enum WandState {IDLE, VACUUM}

var lock_position : bool = false
var can_rotate : bool = false

func change_state(new_state: WandState) -> void:
	if new_state == WandState.VACUUM:
		$Spells.change_state("Vacuum")
	else:
		$Spells.change_state("Idle")

var activate = true
func controller_action(controller : XRController3D):
	if is_picked_up():
		if controller.is_button_pressed("trigger_click"):
			if activate:
				change_state(WandState.VACUUM)
			else:
				change_state(WandState.IDLE)
			
			activate = !activate

func _input(event: InputEvent) -> void:
	if !is_picked_up():
		if event.is_action_pressed("debug_lock_rotation"):
			can_rotate = !can_rotate

func _physics_process(delta: float) -> void:
	if can_rotate:
		rotate_x(delta * deg_to_rad(90))
	
	axis_lock_linear_x = lock_position
	axis_lock_linear_y = lock_position
	axis_lock_linear_z = lock_position


func _on_spells_state_changed(new_state: String) -> void:
	$CurrentState.text = new_state
