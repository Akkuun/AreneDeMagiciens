@tool
extends CenterContainer

var _move : Texture2D
@export var move = Texture2D.new():
	set(value):
		_move = value
		$Icon.texture = _move
	get():
		return _move
