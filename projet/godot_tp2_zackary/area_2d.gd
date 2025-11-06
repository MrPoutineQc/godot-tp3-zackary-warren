extends Area2D

@export var speed := 600.0
var exploding := false
var shooter = null

# --- Fonction : Ready ---
func _ready():
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.1).timeout
	$CollisionShape2D.disabled = false
	if "idle" in $AnimatedSprite2D.sprite_frames.get_animation_names():
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.stop()

# --- Fonction : Mouvement de la balle ---
func _physics_process(delta):
	if exploding:
		return
	position += Vector2.UP.rotated(rotation) * speed * delta

# --- Fonction : Détection de collision ---
func _on_body_entered(body):
	if exploding:
		return
	exploding = true
	$explosion_obus.play()
	$CollisionShape2D.disabled = true
	set_physics_process(false)

	if body.is_in_group("tank") and body != shooter and body.has_method("take_damage"):
		body.take_damage()
		$explosionSoundTank.play()
		
		var gms := get_tree().get_nodes_in_group("game_manager")
		if gms.size() > 0 and gms[0].has_method("respawn_all_tanks"):
			gms[0].respawn_all_tanks()
	else: 
		$explosion_obus.play()

	# Explosion puis suppression
	if "explosion" in $AnimatedSprite2D.sprite_frames.get_animation_names():
		$AnimatedSprite2D.play("explosion")
		var cb := Callable(self, "_on_explosion_finished")
		if not $AnimatedSprite2D.is_connected("animation_finished", cb):
			$AnimatedSprite2D.connect("animation_finished", cb, Object.CONNECT_ONE_SHOT)
	else:
		queue_free()

# --- Fonction : Fin d'explosion ---
func _on_explosion_finished():
	queue_free()
