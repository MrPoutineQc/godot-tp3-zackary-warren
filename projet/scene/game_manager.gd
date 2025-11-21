extends Node2D

@export var star_path: NodePath
@export var key_path: NodePath
@onready var star: Node = get_node_or_null(star_path)
@onready var key: Node = get_node_or_null(key_path)
var respawn_in_progress: bool = false

# --- READY ---
func _ready():
	add_to_group("game_manager")
	if star == null:
		star = get_node_or_null("PowerStar")
	if key == null:
		key = get_node_or_null("GhostKey")

# --- RESPAWN DE TOUS LES TANKS ---
func respawn_all_tanks():
	if respawn_in_progress:
		return
	respawn_in_progress = true
	
	for tank in get_tree().get_nodes_in_group("tank"):
		if tank.has_method("respawn"):
			tank.respawn()
	
	# Reset des bonus
	_reset_star()
	_reset_key()
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

# --- RÉINITIALISATION DE LA GHOST KEY ---
func _reset_key():
	if key == null and key_path != NodePath():
		key = get_node_or_null(key_path)
	if key == null:
		key = get_node_or_null("GhostKey")
		if key == null:
			var keys := get_tree().get_nodes_in_group("key")
			if keys.size() > 0:
				key = keys[0]
	if key and key.has_method("reset"):
		key.reset()

# --- RESET DU JEU ---
func reset_game():
	print("Le jeu a redémarré")
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

# --- VICTOIRE ---
func declare_winner(player_name: String):
	print("%s a gagné !" % player_name)
	
	# Sauvegarder le gagnant
	GlobalState.winner_name = player_name
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scene/victory.tscn")
