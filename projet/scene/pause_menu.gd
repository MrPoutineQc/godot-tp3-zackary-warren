extends Control

# --- Variables principales ---
var is_muted := false


# --- Ready : Initialisation du menu ---
func _ready():
	hide()  # Cache le menu au lancement
	var master_bus = AudioServer.get_bus_index("Master")
	is_muted = AudioServer.is_bus_mute(master_bus)
	_update_mute_button_text()
	
	if not $PanelContainer/VBoxContainer/resume.pressed.is_connected(_on_resume_pressed):
		$PanelContainer/VBoxContainer/resume.pressed.connect(_on_resume_pressed)
	if not $PanelContainer/VBoxContainer/restart.pressed.is_connected(_on_restart_pressed):
		$PanelContainer/VBoxContainer/restart.pressed.connect(_on_restart_pressed)
	if not $PanelContainer/VBoxContainer/sound.pressed.is_connected(_on_MuteButton_pressed):
		$PanelContainer/VBoxContainer/sound.pressed.connect(_on_MuteButton_pressed)


# --- Process : Détection de la touche Échap ---
func _process(_delta):
	escapeKey()


# --- Fonction : Reprendre le jeu ---
func resume():
	get_tree().paused = false
	hide()


# --- Fonction : Mettre le jeu en pause ---
func pause():
	get_tree().paused = true
	show()


# --- Fonction : Gestion de la touche pause (Échap) ---
func escapeKey():
	if Input.is_action_just_pressed("pause_menu"):
		if get_tree().paused:
			resume()
		else:
			pause()


# --- Fonction : Bouton Reprendre ---
func _on_resume_pressed():
	resume()


# --- Fonction : Bouton Recommencer ---
func _on_restart_pressed():
	get_tree().paused = false
	hide()
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()


# --- Fonction : Bouton Mute/Démute ---
func _on_MuteButton_pressed():
	var master_bus = AudioServer.get_bus_index("Master")
	is_muted = not AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(master_bus, is_muted)
	_update_mute_button_text()


# --- Fonction : Met à jour le texte du bouton son ---
func _update_mute_button_text():
	if is_muted:
		$PanelContainer/VBoxContainer/sound/Label.text = "Son coupé"
	else:
		$PanelContainer/VBoxContainer/sound/Label.text = "Son activé"
