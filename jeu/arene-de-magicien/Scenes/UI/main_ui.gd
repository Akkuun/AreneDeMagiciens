extends Control

@export var settings_panel : Control
@export var level_selection_available : bool = false

func hide_navigation():
	$Navigation.visible = false
func show_navigation():
	$Navigation.visible = true

func _ready() -> void:
	$Navigation/Levels.visible = level_selection_available

func _on_settings_pressed() -> void:
	settings_panel.visible = true
	hide_navigation()


func _on_game_settings_closed() -> void:
	settings_panel.visible = false
	show_navigation()


func _on_levels_pressed() -> void:
	$LobbyUi.visible = true
	hide_navigation()
