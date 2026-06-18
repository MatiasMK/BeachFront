extends Control

signal on_play

@onready var options = $Options

func _ready():
	$Buttons/PlayButton.pressed.connect(_on_play_pressed)
	$Buttons/OptionsButton.pressed.connect(_on_options_pressed)
	$Buttons/ExitButton.pressed.connect(_on_exit_pressed)
	
func _on_play_pressed():
	on_play.emit()

func _on_options_pressed():
	options.visible = true

func _on_exit_pressed():
	get_tree().quit()
