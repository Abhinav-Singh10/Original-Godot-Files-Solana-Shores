class_name Checkpoint extends Area2D

@onready var _sfx: AudioStreamPlayer2D= $AudioStreamPlayer2D
var id:int


func _on_body_entered(_body: Node2D) -> void:
	_sfx.play()
	collision_mask=0
	File.data.checkpoint =id
	
