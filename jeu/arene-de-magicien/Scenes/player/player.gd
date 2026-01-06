extends XROrigin3D

@export var cam : Node3D
@export var menu : XRToolsViewport2DIn3D
@export var dist_menu_from_cam : float = 5.0
@export var menu_interpolation : Curve
@export var interpolation_speed: float = 1.0  

@export var left_hand_controller : XRController3D
@export var damage_overlay: MeshInstance3D  # Référence vers le damage overlay

var fireball : PackedScene = preload("res://Scenes/objects/fire_ball/fire_ball.tscn")

func _ready():
	var interface = XRServer.find_interface("name of the plugin")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().arvr = true
	
	# Connecte le signal take_damage du PlayerBody au damage overlay
	var player_body = $PlayerBody
	if player_body:
		player_body.player_damage_taken.connect(_on_player_damage_taken)

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

func launchFireball():
	var fireball_instance = fireball.instantiate()
	var hand_transform = left_hand_controller.global_transform
	var direction = -hand_transform.basis.z
	fireball_instance.init(self, direction)
	get_parent().add_child(fireball_instance)
	fireball_instance.global_transform = Transform3D().looking_at(direction, Vector3.UP).translated(hand_transform.origin)

func _on_hand_button_pressed(name: String) -> void:
	print("Button pressed: ", name)
	if name == "menu_button":
		menu.visible = !menu.visible
		menu.global_position = cam.global_position - cam.global_basis.z * dist_menu_from_cam
	if name == "trigger_click":
		launchFireball()


func _on_centering_timer_timeout() -> void:
	update_needed = false


func _on_player_damage_taken(damage_amount: int) -> void:
	if damage_overlay and damage_overlay.has_method("show_damage"):
		damage_overlay.show_damage()
