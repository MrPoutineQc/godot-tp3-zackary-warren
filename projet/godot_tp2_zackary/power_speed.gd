extends Area2D

@export var speed_bonus := 1.5
@export var size_bonus := 0.5
@export var duration := 10.0
@onready var power_sound = $powerSound
var start_position: Vector2
var active := true

# --- Fonction : Ready ---
func _ready():
	add_to_group("power_star")
	start_position = position
	$CollisionShape2D.disabled = false
	show()
	active = true

# --- Fonction : Collision avec un tank ---
func _on_body_entered(body):
	if not active:
		return
	if not body.is_in_group("tank"):
		return

	power_sound.play()
	
	active = false
	body.apply_speed_bonus(speed_bonus, duration)
	body.apply_size_bonus(size_bonus, duration)

	$CollisionShape2D.disabled = true
	hide()

# --- Fonction : Reset ---
func reset():
	active = true
	position = start_position
	$CollisionShape2D.disabled = false
	show()
