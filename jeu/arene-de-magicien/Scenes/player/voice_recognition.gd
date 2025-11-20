extends Node


signal state_update(state: String)

@export var PYTHON_PATH := "python3"
@export var VOSK_MODEL_PATH := "res://resources/VoiceRecognition/models/vosk-model-small-fr-0.22"
@export var TRANSCRIBE_SCRIPT := "res://resources/VoiceRecognition/transcribe_vosk.py"
@export var CAPTURE_PATH := "user://capture.wav"


var effect
var recording: AudioStreamWAV 

func _ready() -> void:
	var audio_idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(audio_idx, 0)
	
	CAPTURE_PATH = ProjectSettings.globalize_path(CAPTURE_PATH)
	VOSK_MODEL_PATH = ProjectSettings.globalize_path(VOSK_MODEL_PATH)
	TRANSCRIBE_SCRIPT = ProjectSettings.globalize_path(TRANSCRIBE_SCRIPT)
	

func start_record():
	effect.set_recording_active(true)

func stop_record():
	effect.set_recording_active(false)
	recording = effect.get_recording()
	

func save_record(path: String):
	recording.save_to_wav(path)



func detect_voice():
	state_update.emit("start detect...")
	# Chemins et constantes
	const RECORD_SECONDS := 5
	
	state_update.emit("Enregistrement en cours...")
	start_record()
	get_tree().create_timer(RECORD_SECONDS).timeout.connect(func ():
		stop_record()
		save_record(CAPTURE_PATH)
		transcript_saved_record())


func transcript_saved_record():
	# Transcription
	var args := [TRANSCRIBE_SCRIPT, CAPTURE_PATH, VOSK_MODEL_PATH]
	var out2 := []
	var exit2 := OS.execute(PYTHON_PATH, args, out2)
	if exit2 != 0:
		state_update.emit("Transcription échouée (exit %d)\n%s" % [exit2, str(out2)])
		return

	var transcription := ""
	for line in out2:
		transcription += str(line) + "\n"
	transcription = transcription.strip_edges()
	if transcription == "":
		transcription = "(Aucun texte détecté)"
	state_update.emit(transcription)
