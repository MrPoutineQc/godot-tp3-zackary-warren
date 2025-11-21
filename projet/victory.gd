extends Control

@onready var winner_label: Label = $WinnerLabel
@onready var replay_button: TextureButton = $ReplayButton
@onready var victory_sound: AudioStreamPlayer = $VictoryAudio

func _ready():
	# Récupère le nom du gagnant depuis GlobalState
	var winner_name = GlobalState.winner_name
	
	# Affiche le nom du gagnant
	winner_label.text = winner_name + " Gagne!"
	
	# Joue le son
	if victory_sound:
		victory_sound.play()
	
	# Connecte le bouton
	replay_button.pressed.connect(_on_replay_pressed)

func _on_replay_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
