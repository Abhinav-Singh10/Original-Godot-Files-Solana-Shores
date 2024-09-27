#extends Node
#
#@export var characters: Array[CharacterBody2D]
#var _current_character_index: int = 0
#
#@onready var _character = characters[_current_character_index]
#
#func _ready() -> void:
	## Set the initial character to control
	#_character = characters[_current_character_index]
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("jump"):
		#_character.jump()
	#if event.is_action_released("jump"):
		#_character.stop_jump()
#
	#if event.is_action_pressed("ui_switch_character"):
		#switch_character()
#
#func _process(_delta: float) -> void:
	#_character.run(Input.get_axis("run_left", "run_right"))
#
#func switch_character() -> void:
	## Deactivate the current character if needed
	#_current_character_index = (_current_character_index + 1) % characters.size()
	#_character = characters[_current_character_index]

extends Node

@onready var _character= get_parent() # at onready helps the node to be assigned values only after it knows who
# its parent is
var _is_enabled:bool

func set_enabled(is_enabled: bool):
	_is_enabled=is_enabled

func _input(event: InputEvent) -> void: # this method is more efficient for handling input and release events
	if not _is_enabled:
		return
	if event.is_action_pressed("jump"):
		_character.jump()
	if event.is_action_released("jump"):
		_character.stop_jump()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: # delta is usually 1/60th of a second
	# since we didn't need delta in this function we added an underscore in front of it, letting godot know we don't need its value
	if not _is_enabled:
		return
	_character.run(Input.get_axis("run_left","run_right"))
