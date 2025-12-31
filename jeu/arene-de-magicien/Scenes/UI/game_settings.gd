extends VBoxContainer

@export var user_path : String = "user://settings.tres"
@export var base_settings : Settings

var settings_copy : Settings

signal closed

func _ready() -> void:
	if base_settings == null:
		base_settings = Settings.new()
	
	base_settings.resource_path = user_path
	ResourceSaver.save(base_settings)

func _on_master_volume_input_value_changed(value: float) -> void:
	base_settings.master_volume = int(value)

func _on_cancel_pressed() -> void:
	base_settings = settings_copy
	closed.emit()

func _on_confirm_pressed() -> void:
	ResourceSaver.save(base_settings)
	closed.emit()


func _on_visibility_changed() -> void:
	settings_copy = base_settings.duplicate()
	$MasterVolumeInput.value = base_settings.master_volume
