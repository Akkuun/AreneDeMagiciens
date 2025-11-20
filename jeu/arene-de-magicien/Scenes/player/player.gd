extends XROrigin3D

@export var resultVoiceRecognition : Label3D 

func _ready():
	var interface = XRServer.find_interface("name of the plugin")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().arvr = true
	$VoiceRecognition.connect("state_update", func(content: String):
		resultVoiceRecognition.text = content
		)
# detect all action from Left Hand
func _on_left_hand_button_pressed(name: String) -> void:
	if name == "by_button" : 
		#launch voice_recognition
		$VoiceRecognition.detect_voice()
		
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_accept")):
		$VoiceRecognition.detect_voice()
