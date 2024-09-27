extends Area2D

@export var _splash : PackedScene
@onready var _sfx : AudioStreamPlayer2D = $AudioStreamPlayer2D

var _is_splash_playing: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is TileMap:
		return
	_spawn_splash(body.position.x)
	if body is Character:
		body.enter_water(position.y)

func _spawn_splash(x: float):
	var splash = _splash.instantiate()
	add_child(splash)
	splash.global_position.x = x
	if not _is_splash_playing:
		_is_splash_playing = true
		_sfx.play()

func _on_body_exited(body: Node2D) -> void:
	if body is Character:
		if body.position.y - float(Global.ppt) / 2 <= position.y:
			body.exit_water()
			_spawn_splash(body.position.x)
		else:
			body.dive()

func _on_sfx_finished():
	_is_splash_playing = false
