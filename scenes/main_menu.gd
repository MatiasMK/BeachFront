extends Control

signal on_play

func _ready():
	$Buttons/PlayButton.pressed.connect(_on_play_pressed)
	
func _on_play_pressed():
	on_play.emit()
