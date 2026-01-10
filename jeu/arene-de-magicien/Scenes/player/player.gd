extends XROrigin3D

@export var cam : Node3D
@export var menu : XRToolsViewport2DIn3D
@export var dist_menu_from_cam : float = 5.0
@export var menu_interpolation : Curve
@export var interpolation_speed: float = 1.0

@onready var player_ui : Control = $XRCamera3D/Viewport2Din3D/Viewport/PlayerUi
 
var _disable_move : bool = false
@export var disable_move : bool:
	set(value):
		if _disable_move == value:
			return
		_disable_move = value
		$LeftHand/MovementDirect.enabled = !_disable_move
	get():
		return _disable_move

func _ready():
	var interface = XRServer.find_interface("name of the plugin")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().arvr = true
	
	player_ui.set_max_health($LifeComponent.max_life)

var update_needed : bool = false
var interpolation_progress: float = 0.0  
func _physics_process(delta: float) -> void:
	if (menu.position - cam.position).normalized().dot(-cam.basis.z) < 0.7:
		$Viewport2Din3D/CenteringTimer.start()
		if !update_needed:
			interpolation_progress = 0.0
		update_needed = true
		
	
	interpolation_progress += delta * interpolation_speed
	interpolation_progress = clamp(interpolation_progress, 0.0, 1.0)
	
	var curve_value = menu_interpolation.sample(interpolation_progress)
	var target_pos = cam.position - cam.basis.z * dist_menu_from_cam
	if update_needed:
		menu.position = menu.position.lerp(target_pos, curve_value)
	menu.rotation = menu.rotation.lerp(cam.rotation, curve_value)


func _on_hand_button_pressed(interaction_name: String) -> void:
	if interaction_name == "menu_button":
		menu.visible = !menu.visible
		set_menu_interaction(menu.visible)
		menu.global_position = cam.global_position - cam.global_basis.z * dist_menu_from_cam

func set_menu_interaction(state: bool):
	$RightHand/FunctionPointer.enabled = state
	$RightHand/FunctionPointer.visible = state
	$LeftHand/FunctionPointer.enabled = state
	$LeftHand/FunctionPointer.visible = state

func set_belt_visibility(state: bool):
	$PlayerBody/Belt.set_visibility(state)

func _on_centering_timer_timeout() -> void:
	update_needed = false


func _on_status_manager_dammage_taken(quantity: int) -> void:
	if quantity > 0:
		$XRCamera3D/DamageOverlay.show_damage()


func _on_life_component_dead() -> void:
	player_ui.show_death_screen()
