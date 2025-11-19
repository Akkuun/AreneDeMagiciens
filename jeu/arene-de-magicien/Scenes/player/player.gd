extends XROrigin3D

@export var resultVoiceRecognition : Label3D 

func _ready():
	var interface = XRServer.find_interface("name of the plugin")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().arvr = true

# detect all action from Left Hand
func _on_left_hand_button_pressed(name: String) -> void:
	if name == "by_button" : 
		#launch voice_recognition
		detect_voice()

func detect_voice():
	resultVoiceRecognition.text = "start detect..."
	# Chemins et constantes
	var FFMPEG_PATH := "ffmpeg"
	var PYTHON_PATH := "python3"
	var TRANSCRIBE_SCRIPT := "res://resources/VoiceRecognition/transcribe_vosk.py"
	var VOSK_MODEL_PATH := "res://resources/VoiceRecognition/models/vosk-model-small-fr-0.22"
	const RECORD_SECONDS := 1

	# Globaliser les chemins
	TRANSCRIBE_SCRIPT = ProjectSettings.globalize_path(TRANSCRIBE_SCRIPT)
	VOSK_MODEL_PATH = ProjectSettings.globalize_path(VOSK_MODEL_PATH)
	var capture_rel := "user://capture.wav"
	var capture_abs := ProjectSettings.globalize_path(capture_rel)

	# Enregistrement audio
	if resultVoiceRecognition:
		resultVoiceRecognition.text = "Enregistrement en cours..."
	await get_tree().process_frame
	var ffmpeg_args := []
	var os_name := OS.get_name()
	if os_name == "Windows":
		var device := "audio=Microphone (Realtek(R) Audio)"
		ffmpeg_args = ["-y", "-f", "dshow", "-i", device, "-t", str(RECORD_SECONDS), "-ar", "16000", "-ac", "1", capture_abs]
	elif os_name == "Linux":
		ffmpeg_args = ["-y", "-f", "pulse", "-i", "default", "-t", str(RECORD_SECONDS), "-ar", "16000", "-ac", "1", capture_abs]
	elif os_name == "OSX":
		ffmpeg_args = ["-y", "-f", "avfoundation", "-i", ":0", "-t", str(RECORD_SECONDS), "-ar", "16000", "-ac", "1", capture_abs]
	else:
		resultVoiceRecognition.text = "OS non pris en charge automatiquement: " + os_name
		return

	var out := []
	var exit_code := OS.execute(FFMPEG_PATH, ffmpeg_args, out)
	if exit_code != 0:
		resultVoiceRecognition.text = "ffmpeg failed (exit %d)\n%s" % [exit_code, str(out)]
		return

	resultVoiceRecognition.text = "Transcription en cours..."
	await get_tree().process_frame

	# Transcription
	var args := [TRANSCRIBE_SCRIPT, capture_abs, VOSK_MODEL_PATH]
	var out2 := []
	var exit2 := OS.execute(PYTHON_PATH, args, out2)
	if exit2 != 0:
		resultVoiceRecognition.text = "Transcription échouée (exit %d)\n%s" % [exit2, str(out2)]
		return

	var transcription := ""
	for line in out2:
		transcription += str(line) + "\n"
	transcription = transcription.strip_edges()
	if transcription == "":
		transcription = "(Aucun texte détecté)"
	resultVoiceRecognition.text = transcription
