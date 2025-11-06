extends Node2D

@onready var music = $background_song

func _ready():
	if music.stream:
		music.stream.loop = true
	music.play()
