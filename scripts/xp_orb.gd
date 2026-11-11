extends Area2D

@export var xp_amount : int = 10
@export var orb_speed : float = 50.0
@export var orb_lifetime : float = 5.0
@export var collection_radius : float = 20.0

@onready var sprite : Sprite2D = $Sprite
@onready var lifetime_timer : Timer = $LifetimeTimer

func _ready() -> void:
	_create_placeholder_sprite()
	# Fade out over orb_lifetime using create_tween()
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, orb_lifetime).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	# Connect timeout before starting
	lifetime_timer.connect("timeout", Callable(self, "_on_timeout"))
	lifetime_timer.start()
	# Body entered signal for collection
	connect("body_entered", Callable(self, "_on_body_entered"))

func _create_placeholder_sprite() -> void:
	# Simple blue circle texture
	var img = Image.new()
	img.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 1, 1))
	var tex = ImageTexture.new()
	tex.set_image(img)
	sprite.texture = tex

func _physics_process(delta: float) -> void:
	position.y -= orb_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("add_experience"):
		body.add_experience(xp_amount)
		# Stop timer to avoid double‑free
		if lifetime_timer.is_stopped() == false:
			lifetime_timer.stop()
		queue_free()

func _on_timeout() -> void:
	queue_free()
