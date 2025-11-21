extends Area2D

@export var ghost_duration := 10.0
@onready var key_sound: AudioStreamPlayer = $keySound
@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var active := true
var pulse_tween: Tween = null

# --- Ready ---
func _ready():
	add_to_group("key")
	start_position = position
	active = true

	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	_start_pulse()
	call_deferred("_reset_key")

# --- Collision avec un tank ---
func _on_body_entered(body: Node):
	if not active:
		return
	if not body.is_in_group("tank"):
		return

	active = false
	if key_sound:
		key_sound.play()

	# --- Applique l’effet ghost ---
	if body.has_method("enable_ghost_mode"):
		body.enable_ghost_mode(ghost_duration)
	if body.has_method("_update_key_display"):
		body.has_ghost_key = true
		body._update_key_display()

	# --- Stop la pulsation ---
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	# --- Effet visuel au ramassage ---
	if sprite:
		sprite.modulate = Color(0.3, 0.8, 1.0, 1.0)  # flash bleu
		var t = create_tween()
		t.tween_property(sprite, "scale", Vector2(0.2, 0.2), 0.15)
		t.tween_property(sprite, "modulate", Color(0.3, 0.8, 1.0, 0.4), 0.25)
		t.tween_property(sprite, "modulate", Color(0.3, 0.8, 1.0, 0.0), 0.35)
		await t.finished

	# --- Désactive la collision ---
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	shape.set_deferred("disabled", true)
	call_deferred("hide")

# --- Reset public ---
func reset():
	call_deferred("_reset_key")

# --- Reset interne ---
func _reset_key():
	active = true
	position = start_position
	sprite.modulate = Color(1, 1, 1, 1)
	sprite.scale = Vector2(0.16, 0.16)

	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	shape.set_deferred("disabled", false)

	# Redémarre la pulsation
	_start_pulse()

# --- Pulsation visuelle ---
func _start_pulse():
	if not sprite:
		return

	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(sprite, "scale", Vector2(0.15, 0.15), 0.7)
	pulse_tween.tween_property(sprite, "scale", Vector2(0.16, 0.16), 0.7)
	pulse_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0.6), 0.7)
	pulse_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.7)
