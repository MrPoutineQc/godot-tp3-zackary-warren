extends CharacterBody2D

@export var speed := 150.0  # Vitesse de déplacement
@export var rotation_speed := 3.0  # Vitesse de rotation

func _physics_process(delta):
	var direction = 0.0
	var rotation_dir = 0.0

	# Contrôles (adaptés à ton Input Map)
	if Input.is_action_pressed("move_forward"):
		direction = 1
	elif Input.is_action_pressed("move_backward"):
		direction = -1

	if Input.is_action_pressed("turn_left"):
		rotation_dir = -1
	elif Input.is_action_pressed("turn_right"):
		rotation_dir = 1

	# Rotation
	rotation += rotation_dir * rotation_speed * delta

	# Déplacement selon la direction actuelle du tank
	velocity = Vector2(direction * speed, 0).rotated(rotation)
	move_and_slide()
