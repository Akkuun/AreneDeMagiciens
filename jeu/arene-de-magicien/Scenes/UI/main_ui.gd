extends Control

@export var settings_panel : Control


func hide_navigation():
	$Navigation.visible = false
func show_navigation():
	$Navigation.visible = true

func _on_settings_pressed() -> void:
	settings_panel.visible = true
	hide_navigation()


func _on_game_settings_closed() -> void:
	settings_panel.visible = false
	show_navigation()
