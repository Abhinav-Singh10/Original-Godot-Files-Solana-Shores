class_name Character extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var _sprite: Sprite2D= $Sprite2D

var _min: Vector2
var _max: Vector2
var _is_bound: bool

@export_category("Locomotion")
@export var _speed : float = 8
@export var _acceleration : float = 16
@export var _deceleration : float = 32

@export_category("Sprite")
@export var _is_facing_left: bool
@export var _inverted_sprite: bool = true


@export_category("Jump")
@export var _jump_dust: PackedScene
@export var _jump_height: float =2.5
@export var _air_control: float =0.5
var _jump_velocity:float
var _was_on_floor: bool

@export_category("Swim")
@export var _density:float= -0.1
@export var _drag: float= 0.5

var _water_surface_height: float
var _is_in_water: bool
var _is_below_surface: bool

var _collision_layer :int = collision_layer
var _collision_mask : int = collision_mask

@export_category("Combat")
@export var _is_hit : bool
@export var _is_dead : bool
@export_range(1,100) var _max_health : int = 5
@onready var _current_health: int =_max_health
@onready var _hurt_box: Area2D= $HurtBox
var _invincible_time: Timer
@export_range(0,5)  var _invincible_duration:float



signal changed_direction(is_facing_left: bool)
signal landed(floor_height: float)
signal health_changed(percentage:float)
signal died()

var _direction:float  # methods unconcerned with other scripts marked as _
# Like this above method is only for this script

func _ready() -> void:
	_speed*=Global.ppt
	_acceleration*=Global.ppt
	_deceleration*=Global.ppt
	_jump_height*=Global.ppt
	_jump_velocity=sqrt(_jump_height*gravity*2)*-1
	if _is_facing_left:
		face_left() 
	else:
		face_right()
	if _invincible_duration!=0:
		_invincible_time=$HurtBox/Invincible

#region public methods

func take_damage(amount:int, direction: Vector2):
	_current_health= max(_current_health- amount,0)
	health_changed.emit(float(_current_health)/ _max_health)
	velocity= direction*Global.ppt*5
	if _current_health == 0:
		_die()
	else:
		_is_hit=true
		print(_current_health)
		if _invincible_duration!=0 :
			become_invincible(_invincible_duration)
	
func recover(amount:int):
	File.data.potion+=1
	print("Recovered called")
	_current_health = min(_current_health + amount, _max_health)
	print(_current_health)
	health_changed.emit(float(_current_health) / _max_health)

func become_invincible(duration:float):
	print("Became Invincible")
	_hurt_box.set_deferred("monitorable",false);
	_invincible_time.start(duration)
	await _invincible_time.timeout
	_hurt_box.monitorable=true

func set_bounds(min_boundary: Vector2, max_boundary: Vector2):
	_is_bound=true
	_min=min_boundary
	_max=max_boundary
	var sprite_size: Vector2= _sprite.get_rect().size
	_min.x+=sprite_size.x/2
	_max.x-=sprite_size.x/2
	#_min.y=sprite_size.y


func face_left():
	if _is_dead:
		return
	_is_facing_left=true
	if _inverted_sprite:
		_sprite.flip_h=false
	else:	
		_sprite.flip_h=true
	changed_direction.emit(_is_facing_left)
	
func face_right():
	if _is_dead:
		return
	_is_facing_left=false
	if _inverted_sprite:
		_sprite.flip_h=true	
	else:
		_sprite.flip_h=false
	changed_direction.emit(_is_facing_left)
	
func run(direction: float):
	if _is_dead:
		return
	_direction=direction

func jump():
	if _is_dead:
		return
	if _is_in_water:
		if _is_below_surface:
			velocity.y = _jump_velocity* _drag
			landed.emit(position.y)
		else:
			velocity.y = _jump_velocity
	elif is_on_floor():
		_spawn_dust(_jump_dust)
		velocity.y=_jump_velocity 
		
func stop_jump() :
	if _is_dead:
		return
	if velocity.y<0 && not _is_in_water:
			velocity.y=0
			
func enter_water(water_surface_height: float):
	_water_surface_height=water_surface_height
	_is_in_water=true
	_is_below_surface=false
	landed.emit(position.y)
	if velocity.y>0:
		velocity.y*=_drag
	

func exit_water():
	_is_in_water=false

func dive():
	_is_below_surface=true

func revive():
	_is_dead=false
	_current_health= _max_health
	_hurt_box.monitorable= true
	collision_layer= _collision_layer
	collision_mask= _collision_mask
	landed.emit(global_position.y)
	health_changed.emit(float(_current_health)/ _max_health)
	

#endregion

func _physics_process(delta: float) -> void:
	if not _is_facing_left && sign(_direction)==-1:
		face_left()
	elif _is_facing_left && sign(_direction)==1:
		if _inverted_sprite:
			face_left()
		face_right()
	
	if _is_in_water:
		_water_physics(delta)
	elif is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	_was_on_floor=is_on_floor()
	move_and_slide()
	if not _was_on_floor && is_on_floor():
		_landed()
	if _is_bound:
		position.x=clamp(position.x,_min.x,_max.x)
		position.y= clamp(position.y,_min.y,_max.y)	
	
	
func _landed():
	landed.emit(position.y)

func _ground_physics(delta: float):
		#decelerate to zero
	if _direction==0: 
		velocity.x = move_toward(velocity.x, 0, _deceleration*delta) # move_toward(starting speed, move towards, amount decelearation)
	#meaning character is stationary or trying to move in same direction
	elif velocity.x==0 || sign(_direction)==sign(velocity.x): 
		velocity.x = move_toward(velocity.x,_direction * _speed,_acceleration*delta)
	else:
		velocity.x = move_toward(velocity.x,_direction * _speed,_deceleration*delta)

func _air_physics(delta:float):
	velocity += get_gravity() * delta
	if _direction:
		velocity.x=move_toward(velocity.x,_direction * _speed,_acceleration*_air_control*delta)

func _spawn_dust(dust: PackedScene):
	var _dust= dust.instantiate()
	_dust.position= position
	_dust.flip_h=_sprite.flip_h
	get_parent().add_child(_dust)
	
func _water_physics(delta: float):
	if _direction==0: 
		velocity.x = move_toward(velocity.x, 0, _deceleration*_drag*delta)
	else:
		velocity.x = move_toward(velocity.x,_direction * _speed,_acceleration*delta*_drag)
	
	if _is_below_surface || _density >0:
		velocity.y =move_toward(velocity.y, gravity*_density*_drag, gravity*_drag*delta)
	elif position.y - float(Global.ppt)/4 < _water_surface_height:
		velocity.y =move_toward(velocity.y, gravity*_density*_drag, gravity*_drag*delta)
	else:
		velocity.y =move_toward(velocity.y, gravity*_density*_drag*-1, gravity*_drag*delta)
	
func _die():
	_is_dead=true
	died.emit()
	_hurt_box.set_deferred("monitorable",false)
	collision_layer=0
	collision_mask=1
	_direction=0
	
