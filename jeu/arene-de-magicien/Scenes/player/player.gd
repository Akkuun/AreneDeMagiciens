extends XROrigin3D

@export var fireball : PackedScene
@export var tornado : PackedScene
@export var left_hand_controller : XRController3D

func _ready():
	var interface = XRServer.find_interface("name of the plugin")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().arvr = true

func launchFireball():
	var fireball_instance = fireball.instantiate()
	var hand_transform = left_hand_controller.global_transform
	var direction = -hand_transform.basis.z
	fireball_instance.init(self, direction)
	get_parent().add_child(fireball_instance)
	fireball_instance.global_transform = Transform3D().looking_at(direction, Vector3.UP).translated(hand_transform.origin)

func launchTornado():
	var tornado_instance = tornado.instantiate()
	var hand_transform = left_hand_controller.global_transform
	var direction = -hand_transform.basis.z
	tornado_instance.init(self, direction)
	get_parent().add_child(tornado_instance)
	tornado_instance.global_transform = Transform3D().looking_at(direction, Vector3.UP).translated(hand_transform.origin)

# detect all action from Left Hand
func _on_left_hand_button_pressed(name: String) -> void:
	print("Button pressed on Left Hand: %s" % name)
	if name == "select_button" : 
		#launch fireball
		print("Launch Fireball")
		launchFireball()
	elif name == "menu_button" :
		#launch tornado
		print("Launch Tornado")
		launchTornado()
