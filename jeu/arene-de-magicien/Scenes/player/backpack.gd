@tool
extends XRToolsPickable




func _on_grabbed(pickable: Variant, by: Variant) -> void:
	$InventoryVisual.visible = false


func _on_dropped(pickable: Variant) -> void:
	$InventoryVisual.visible = true
