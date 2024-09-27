class_name Data extends Resource

@export var world: int
@export var level: int
@export var coins: int
@export var lives: int
@export_range(0,3) var diamonds: int
@export var checkpoint:int
@export var has_key: bool
@export var key: int
@export var potion: int
@export var skull: int
@export var time_passed:int

func _init() -> void:
	world=1
	level=1
	
	coins=0
	lives=1
	key=0
	potion=0
	skull=0
	time_passed=0
	
	diamonds=0
	checkpoint=0
	has_key=false

func retry():
	coins=0
	lives=1
	checkpoint=0
	has_key=false
