extends Control


func set_max_health(value: int):
	$Health.max_value = value
func set_health(value: int):
	$Health.value = value

func show_death_screen():
	$ColorRect.visible = true
