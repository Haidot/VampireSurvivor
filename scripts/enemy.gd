extends CharacterBody2D

@export var max_health : int = 10
@export var xp_value : int = 10
@export var death_animation_duration : float = 0.5

var health : int
var is_dead : bool = false

@onready var anim_player : AnimationPlayer = $AnimPlayer
@onready var sprite : Sprite2D = $Sprite
@onready var hitbox : CollisionShape2D = $Hitbox

func _ready() -> void:
	health = max_health
	_create_placeholder_sprite()
	_create_placeholder_animations()
	anim_player.play("idle")

func _create_placeholder_sprite() -> void:
	# Simple red square texture
	var img = Image.new()
	img.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 0, 0, 1))
	var tex = ImageTexture.new()
	tex.set_image(img)
	sprite.texture = tex

func _create_placeholder_animations() -> void:
	# Idle: 1 frame loop
	var idle = Animation.new()
	idle.length = 0.5
	idle.loop = true
	idle.track_set_path(0, "Sprite:modulate")
	idle.track_insert_key(0, 0.0, Color(1, 0, 0, 1))
	anim_player.add_animation("idle", idle)

	# Death: 0.5s single frame, call method at end
	var death = Animation.new()
	death.length = death_animation_duration
	death.loop = false
	death.track_set_path(0, "Sprite:modulate")
	death.track_insert_key(0, 0.0, Color(1, 0, 0, 1))
	# Create a method track that calls _on_death_animation_finished at the end
	var method_track = death.add_track(Animation.TYPE_METHOD)
	death.track_set_path(method_track, "")
	death.track_insert_key(method_track, death_animation_duration, Callable(self, "_on_death_animation_finished"))
	anim_player.add_animation("death", death)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	hitbox.disabled = true
	anim_player.play("death")

func _on_death_animation_finished() -> void:
	# Called via animation method track
	spawn_xp_orb()
	queue_free()

func spawn_xp_orb() -> void:
	var orb_scene = preload("res://scenes/XPOrb.tscn")
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	orb.xp_amount = xp_value
	get_parent().add_child(orb)
