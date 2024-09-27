extends Control

@export var _max_pixels:int =75
@onready var _fill:TextureRect= $Fill

func set_value(percentage:float):
	_fill.size.x=_max_pixels*percentage
