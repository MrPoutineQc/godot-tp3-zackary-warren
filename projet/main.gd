extends Node2D

@onready var music = $background_song

func _ready():
	if music.stream:
		music.stream.loop = true
	music.play()

func go_to_victory_scene(winner_name: String):
	if music.playing:
		music.stop()
	# Passer à la scène de victoire
	get_tree().change_scene_to_file("res://scenes/victory.tscn")
