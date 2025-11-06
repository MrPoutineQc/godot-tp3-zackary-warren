extends CharacterBody2D

# --- Variables principales ---
@export var base_speed := 150.0
@export var rotation_speed := 3.0
@export var bullet_scene: PackedScene
@export var shoot_action := "a_shoot"
@export var shoot_cooldown := 0.5

# --- Système de vies ---
@export var heart1_path: NodePath
@export var heart2_path: NodePath
@export var heart3_path: NodePath
@export var max_lives := 3
var lives := max_lives
var respawn_position: Vector2

# --- Autres variables (Coeur, Point de sortie de la balle)---
@onready var muzzle = $muzzle
@onready var move_sound = $MoveSound
@onready var hearts = [
	get_node_or_null(heart1_path),
	get_node_or_null(heart2_path),
	get_node_or_null(heart3_path)
]
var can_shoot := true
var base_scale := Vector2(1, 1)
var speed := base_speed

# --- Fonction : Ready ---
func _ready():
	add_to_group("tank")
	respawn_position = Vector2(-138, -531)
	base_scale = scale
	_update_hearts()

# --- Fonction : Mouvement et tir ---
func _physics_process(delta):
	var direction := 0.0
	var rotation_dir := 0.0
	
# --- Son Déplacement ---
	var moving = Input.is_action_pressed("a_up") or Input.is_action_pressed("a_down") or Input.is_action_pressed("a_left") or Input.is_action_pressed("a_right") 

	if moving:
		if not move_sound.playing:
			move_sound.play()
		move_sound.volume_db = -30	
	else:
		if move_sound.playing:
			move_sound.stop()

# --- Déplacement ---
	if Input.is_action_pressed("a_up"):
		direction = 1
		
	elif Input.is_action_pressed("a_down"):
		direction = -1

	if Input.is_action_pressed("a_left"):
		rotation_dir = -1
	elif Input.is_action_pressed("a_right"):
		rotation_dir = 1

	rotation += rotation_dir * rotation_speed * delta
	velocity = Vector2(0, -direction * speed).rotated(rotation)
	move_and_slide()

	if Input.is_action_just_pressed(shoot_action) and can_shoot:
		_start_shoot()

# --- Fonction : Démarrer le tir ---
func _start_shoot() -> void:
	can_shoot = false
	_spawn_bullet()
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

# --- Fonction : Créer une balle ---
func _spawn_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = muzzle.global_position
	bullet.rotation = rotation
	bullet.shooter = self
	get_tree().current_scene.add_child(bullet)

# --- GÉRER LES DÉGÂTS ---
func take_damage():
	lives -= 1
	_update_hearts()

	if lives > 0:
		respawn()
	else:
		hide()
		set_physics_process(false)

		await get_tree().create_timer(0.3).timeout

		var gms := get_tree().get_nodes_in_group("game_manager")
		if gms.size() > 0 and gms[0].has_method("reset_game"):
			gms[0].reset_game()

# --- Fonction : Mettre à jour les cœurs ---
func _update_hearts():
	for i in range(hearts.size()):
		var h = hearts[i]
		if h == null:
			continue
		if i < lives:
			h.texture = preload("res://assets/images/sprites/heart_icons/heart.png")
		else:
			h.texture = preload("res://assets/images/sprites/heart_icons/heart_black.png")

# --- Fonction : Respawn ---
func respawn():
	await get_tree().create_timer(0.3).timeout
	position = respawn_position
	rotation = deg_to_rad(-90)
	velocity = Vector2.ZERO

	speed = base_speed
	scale = base_scale
	modulate = Color(1, 1, 1)
	show()

# --- Fonction : Bonus de vitesse ---
func apply_speed_bonus(multiplier: float, duration: float):
	speed = base_speed * multiplier
	modulate = Color(1, 1, 0)
	await get_tree().create_timer(duration).timeout
	speed = base_speed
	modulate = Color(1, 1, 1)

# --- Fonction : Bonus de taille ---
func apply_size_bonus(scale_factor: float, duration: float):
	scale = base_scale * scale_factor
	await get_tree().create_timer(duration).timeout
	scale = base_scale
	modulate = Color(1, 1, 1)
