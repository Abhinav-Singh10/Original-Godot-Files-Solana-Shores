class_name Treasure extends CollisionObject2D

@onready var _sprite: AnimatedSprite2D= $AnimatedSprite2D
@onready var _sfx: AudioStreamPlayer2D= $AudioStreamPlayer2D
var _character:Character

func _collect():
	pass

func _on_body_entered(body: Node) -> void:
	if not body is Character:
		return
	_sfx.play()
	_character=body
	collision_mask=0
	_collect()
	_sprite.play("effect")
	await _sprite.animation_finished
	queue_free()
