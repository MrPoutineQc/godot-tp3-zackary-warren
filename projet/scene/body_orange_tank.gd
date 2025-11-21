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

# --- Autres variables ---
@onready var muzzle = $muzzle
@onready var move_sound = $MoveSound
var blink_tween: Tween = null
var is_ghost_mode := false
var ghost_mode_id: int = 0
@onready var hearts = [
	get_node_or_null(heart1_path),
	get_node_or_null(heart2_path),
	get_node_or_null(heart3_path)
]
var can_shoot := true
var base_scale := Vector2(1, 1)
var speed := base_speed

# --- Identifiants pour les bonus (empêche les anciens timers d'agir) ---
var speed_bonus_id: int = 0
var size_bonus_id: int = 0

# --- Variables pour la clé Ghost ---
var has_ghost_key := false
@onready var key_display_label: Label = null

# --- Fonction : Ready ---
func _ready():
	add_to_group("tank")
	respawn_position = Vector2(-138, -531)
	base_scale = scale
	_update_hearts()
	
	# --- Initialiser l'affichage des clés dans le HUD ---
	if name == "tank_1":
		key_display_label = get_node_or_null("/root/main/CanvasLayer/KeyDisplay2")
	else:
		key_display_label = get_node_or_null("/root/main/CanvasLayer/KeyDisplay1")
	
	_update_key_display()

# --- Fonction : Mouvement et tir ---
func _physics_process(delta):
	var direction := 0.0
	var rotation_dir := 0.0

	# --- Son de déplacement ---
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

		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm:
			var winner_name = "Tank Orange" if name == "tank_1" else "Tank Bleu"
			gm.declare_winner(winner_name)

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
	disable_ghost_mode()
	speed_bonus_id += 1
	size_bonus_id += 1
	ghost_mode_id += 1
	has_ghost_key = false
	_update_key_display()

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
	speed_bonus_id += 1
	var id = speed_bonus_id

	speed = base_speed * multiplier
	modulate = Color(1, 1, 0) # visuel temporaire

	var timer = get_tree().create_timer(duration)
	await timer.timeout

	if id == speed_bonus_id:
		speed = base_speed
		modulate = Color(1, 1, 1)

# --- Fonction : Bonus de taille ---
func apply_size_bonus(scale_factor: float, duration: float):
	size_bonus_id += 1
	var id = size_bonus_id

	scale = base_scale * scale_factor

	var timer = get_tree().create_timer(duration)
	await timer.timeout

	if id == size_bonus_id:
		scale = base_scale
		modulate = Color(1, 1, 1)

# --- Mode traversée de murs ---
func enable_ghost_mode(duration: float):
	if is_ghost_mode:
		# si le tank est déjà en fantôme, on redémarre le timer proprement
		ghost_mode_id += 1
	else:
		is_ghost_mode = true
		modulate = Color(0.6, 0.8, 1.0, 0.6)
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)

		blink_tween = create_tween().set_loops()
		blink_tween.tween_property(self, "modulate:a", 0.3, 0.3)
		blink_tween.tween_property(self, "modulate:a", 0.6, 0.3)

	ghost_mode_id += 1
	var id = ghost_mode_id

	var timer = get_tree().create_timer(duration)
	await timer.timeout

	if id == ghost_mode_id:
		disable_ghost_mode()

func disable_ghost_mode():
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
		blink_tween = null

	is_ghost_mode = false
	modulate = Color(1, 1, 1, 1)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)

# --- Fonction : Afficher l'état de la clé ---
func _update_key_display():
	if key_display_label == null:
		return
	
	if has_ghost_key:
		key_display_label.text = "🔑 CLÉ: OUI"
		key_display_label.modulate = Color.YELLOW
	else:
		key_display_label.text = "🔑 CLÉ: NON"
		key_display_label.modulate = Color.WHITE
