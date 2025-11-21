extends Control

@onready var winner_label: Label = $WinnerLabel
@onready var replay_button: TextureButton = $ReplayButton
@onready var victory_sound: AudioStreamPlayer = $VictoryAudio

func _ready():
	var winner_name = GlobalState.winner_name
	
	winner_label.text = winner_name + " Gagne!"
	
	if victory_sound:
		victory_sound.play()
	
	replay_button.pressed.connect(_on_replay_pressed)

func _on_replay_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
