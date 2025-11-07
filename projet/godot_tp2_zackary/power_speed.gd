extends Area2D

@export var speed_bonus := 1.5
@export var size_bonus := 0.5
@export var duration := 10.0
@onready var power_sound = $powerSound
@onready var sprite := $Sprite2D
@onready var shape := $CollisionShape2D

var start_position: Vector2
var active := true
var pulse_tween: Tween = null

# --- Fonction : Ready ---
func _ready():
	add_to_group("power_star")
	start_position = position
	active = true

	# ✅ Assure que le signal est bien connecté
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	# 🟢 Relance les effets visuels de base
	_start_pulse()

	# 🔁 Remet à zéro après un reload de scène
	call_deferred("_reset_star")

# --- Fonction : Collision avec un tank ---
func _on_body_entered(body):
	if not active:
		return
	if not body.is_in_group("tank"):
		return

	active = false
	power_sound.play()

	# --- Applique les bonus (réinitialisés à chaque fois) ---
	body.disable_ghost_mode() # 🛑 coupe un effet restant s’il existait
	body.apply_speed_bonus(speed_bonus, duration)
	body.apply_size_bonus(size_bonus, duration)
	body.enable_ghost_mode(duration)

	# --- Stop la pulsation ---
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	# --- 💚 Effet visuel vert au ramassage ---
# --- 💚 Effet visuel vert au ramassage ---
	if sprite:
		sprite.modulate = Color(0.3, 1.0, 0.3, 1.0)  # flash vert
		var t = create_tween()
		t.tween_property(sprite, "scale", Vector2(1.6, 1.6), 0.15)
		t.tween_property(sprite, "modulate", Color(0.3, 1.0, 0.3, 0.4), 0.25)
		t.tween_property(sprite, "modulate", Color(0.3, 1.0, 0.3, 0.0), 0.35)
		
	# Attend la fin du tween avant de cacher
		await t.finished

	# ✅ Désactive la collision proprement (sans bug)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	shape.set_deferred("disabled", true)
	call_deferred("hide")

# --- Fonction : Reset ---
func reset():
	call_deferred("_reset_star")

func _reset_star():
	active = true
	position = start_position
	sprite.modulate = Color(1, 1, 1, 1)
	sprite.scale = Vector2(1, 1)
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	shape.set_deferred("disabled", false)

	# 🔁 Redémarre la pulsation d’affordance
	_start_pulse()

# --- Effet visuel de pulsation ---
func _start_pulse():
	if not sprite:
		return

	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.7)
	pulse_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.7)
	pulse_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0.6), 0.7)
	pulse_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.7)
