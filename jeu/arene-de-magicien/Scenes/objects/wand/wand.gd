@tool
extends XRToolsPickable


func _on_spell_recognition_state_changed(new_state: String) -> void:
	$DebugText.text = new_state
