@tool
extends XRToolsPickable


@export var on_fire_material: ShaderMaterial

func _on_status_manager_status_applied(status: int) -> void:
	if(status == Global.StatusEnum.FIRE):
		$Model.material_overlay = on_fire_material


func _on_status_manager_status_removed(status: int) -> void:
	$Model.material_overlay = null


func _on_life_component_dead() -> void:
	queue_free()
