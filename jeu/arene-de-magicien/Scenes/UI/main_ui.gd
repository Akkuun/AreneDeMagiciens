extends Control

@export var level_selection_available : bool = false

func hide_navigation():
	$Navigation.visible = false
func show_navigation():
	$Navigation.visible = true

func _ready() -> void:
	$Navigation/Levels.visible = level_selection_available

func _on_settings_pressed() -> void:
	$GameSettings.visible = true
	hide_navigation()


func _on_game_settings_closed() -> void:
	$GameSettings.visible = false
	show_navigation()


func _on_levels_pressed() -> void:
	$LobbyUi.visible = true
	hide_navigation()
