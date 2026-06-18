extends Node

@onready var ui = $UI
@onready var main_menu = $UI/MainMenu
@onready var level_container = $LevelContainer
@onready var pause_menu = $UI/PauseMenu
@onready var dialogue : DialogueManager = $UI/Dialogue

const MAIN_MENU = preload("res://scenes/main_menu.tscn")
var LEVEL_1_PATH = "res://levels/level_1.tscn"

var levels = [LEVEL_1_PATH]
var curr_level = null
var curr_level_ind = -1
var phase = 0

var loading_screen
var loading_screen_node
var is_paused = false

func _ready():
	loading_screen = load("res://scenes/loading_screen.tscn")
	main_menu.connect("play_pressed",load_level.bind(0)) # boton play => nivel 1
	$UI/PauseMenu/TextureRect/Resume.pressed.connect(_on_resume)
	$UI/PauseMenu/TextureRect/Quit.pressed.connect(_on_quit)

func load_level(level_ind : int):
	if level_ind < 0 or levels.size() <= level_ind:
		print("No existe nivel de indice ", level_ind)
	else:
		curr_level_ind = level_ind
		
		# remueve el menu principal. (pero queda en memoria)
		var menu = get_node_or_null("UI/MainMenu")
		if menu:
			ui.remove_child(menu)
		
		# comienza a cargar nivel
		var err = ResourceLoader.load_threaded_request(levels[curr_level_ind])
		
		# loading screen
		loading_screen_node = loading_screen.instantiate()
		ui.add_child(loading_screen_node)
		loading_screen_node.set_level(levels[curr_level_ind])
		loading_screen_node.connect("level_loaded",_on_level_loaded)
		
		# carga dialogo del nivel y ejecuta la fase 1.
		dialogue.load_dialogue(curr_level_ind)
		phase = 1
		dialogue.dialogue_end.connect(_on_dialogue_end)
		dialogue.run_dialogue(curr_level_ind,phase)
		

func _on_level_loaded():
	# borra el nivel actual y carga el nivel deseado.
	for child in level_container.get_children():
		child.queue_free()
	curr_level = ResourceLoader.load_threaded_get(levels[curr_level_ind]).instantiate()
	level_container.add_child(curr_level)
	curr_level.start_phase(1)
	loading_screen_node.queue_free()
				

func _on_dialogue_end():
	var lvl = level_container.get_child(0)
	lvl.set_accept_input(true)
	lvl.start_phase(2)

func _on_pause():
	is_paused = true
	dialogue.accept_input = false
	if level_container.get_child_count() > 0:
		level_container.get_child(0).set_accept_input(false)
	pause_menu.visible = true
				
func _on_resume():
	is_paused = false
	pause_menu.visible = false
	if level_container.get_child_count() > 0:
		level_container.get_child(0).set_accept_input(false)
	dialogue.accept_input = true
	
func _on_quit():
	pause_menu.visible = false
	# borra el nivel actual.
	for child in level_container.get_children():
		child.queue_free()
	ui.add_child(main_menu)
	
func _on_phase_end():
	if phase == 1:
		phase = 2
		curr_level.start_phase(2) # testing purposes
		dialogue.run_dialogue(curr_level_ind,phase)
	else:
		pass # fin del juego

func _input(event: InputEvent) -> void:
	if curr_level_ind != -1:
		if event.is_action_pressed("pause"):
			if !is_paused:
				_on_pause()
			else:
				_on_resume()
