extends Node2D

@export var star_path: NodePath
@onready var star := get_node_or_null(star_path)
var respawn_in_progress := false

# --- READY ---
func _ready():
	add_to_group("game_manager")
	if star == null:
		star = get_node_or_null("PowerStar")

# --- RESPAWN DE TOUS LES TANKS ---
func respawn_all_tanks():
	if respawn_in_progress:
		return
	respawn_in_progress = true

	for tank in get_tree().get_nodes_in_group("tank"):
		if tank.has_method("respawn"):
			tank.respawn()

	_reset_star()
	await get_tree().create_timer(0.3).timeout
	respawn_in_progress = false

# --- RÉINITIALISATION DU POWER STAR ---
func _reset_star():
	if star == null and star_path != NodePath():
		star = get_node_or_null(star_path)
	if star == null:
		star = get_node_or_null("PowerStar")
		if star == null:
			var stars := get_tree().get_nodes_in_group("power_star")
			if stars.size() > 0:
				star = stars[0]
	if star and star.has_method("reset"):
		star.reset()

# --- RESET DU JEU ---
func reset_game():
	print("Le jeu a redémarré")
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
