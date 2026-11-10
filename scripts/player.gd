extends CharacterBody2D

## Movement parameters
@export var speed : float = 200.0          # pixels per second
@export var acceleration : float = 800.0   # pixels per second²
@export var friction : float = 600.0       # pixels per second²

## Attack parameters
@export var attack_cooldown : float = 0.5   # seconds
@export var attack_animation_name : String = "attack"

## Animation parameters
@export var animation_speed : float = 12.0  # frames per second

## Internal state
var _velocity : Vector2 = Vector2.ZERO
var _attack_timer : float = 0.0
var _is_attacking : bool = false

## Node references
onready var _anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Ensure the AnimationPlayer has the expected animations
	assert(_anim_player.has_animation("idle"))
	assert(_anim_player.has_animation("walk"))
	assert(_anim_player.has_animation(attack_animation_name))
	_anim_player.play("idle")
	_anim_player.playback_speed = animation_speed

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_attack(delta)
	_update_animation()

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.y -= Input.get_action_strength("ui_up")
	input_dir.y += Input.get_action_strength("ui_down")
	input_dir.x -= Input.get_action_strength("ui_left")
	input_dir.x += Input.get_action_strength("ui_right")
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		# Accelerate towards desired velocity
		_velocity = _velocity.move_toward(input_dir * speed, acceleration * delta)
	else:
		# Apply friction when no input
		_velocity = _velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Move and slide handles collision automatically
	_velocity = move_and_slide(_velocity)

func _handle_attack(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta
		# If attack animation finished, reset flag
		if _is_attacking and not _anim_player.is_playing():
			_is_attacking = false
	else:
		if Input.is_action_just_pressed("attack"):
			_start_attack()

func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_cooldown
	_anim_player.play(attack_animation_name)

func _update_animation() -> void:
	if _is_attacking:
		# Attack animation already playing; do nothing
		return
	
	if _velocity.length() > 1.0:  # threshold to avoid flicker
		if _anim_player.current_animation != "walk":
			_anim_player.play("walk")
	else:
		if _anim_player.current_animation != "idle":
			_anim_player.play("idle")
