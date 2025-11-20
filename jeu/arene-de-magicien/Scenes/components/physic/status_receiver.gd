class_name StatusReceiver extends Area3D

signal status_entered(status: Global.StatusEnum)
signal status_leaved(status: Global.StatusEnum)


func _on_area_entered(area: StatusGiver) -> void:
	status_entered.emit(area.status)


func _on_area_exited(area: StatusGiver) -> void:
	status_leaved.emit(area.status)
