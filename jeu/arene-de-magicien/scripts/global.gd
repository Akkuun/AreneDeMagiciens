extends Node

enum StatusEnum {
	NONE,
	FIRE,
	WATER,
	HEAL
}


enum MoveTypeEnum {SEND, TORNADO, WAVE}


signal level_loading(level: PackedScene)
func load_level(level: PackedScene):
	level_loading.emit(level)


var draw_recog : DrawingRecognizer
var gesture_node : GestureNode

func get_drawing_name() -> String:
	return gesture_node.classiffy_gesture(draw_recog.get_drawing())
