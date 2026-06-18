extends Node

@onready var ui = $UI
@onready var level_container = $LevelContainer
@onready var dialogue : DialogueManager = $UI/Dialogue

const MAIN_MENU = preload("res://scenes/main_menu.tscn")
var LEVEL_1_PATH = "res://levels/level_1.tscn"

var levels = [LEVEL_1_PATH]
var curr_level = null
var curr_level_ind = -1
var phase = 0

var loading_screen
var loading_screen_node
var main_menu
var pause_menu

func _ready():
	main_menu = MAIN_MENU.instantiate()
	loading_screen = load("res://scenes/loading_screen.tscn")
	ui.add_child(main_menu) # carga menu principal
	main_menu.connect("on_play",load_level.bind(0))
	pause_menu = $UI/PauseMenu
	var pause_menu_resume = $UI/PauseMenu/TextureRect/Resume
	pause_menu_resume.pressed.connect(_on_resume)
	var pause_menu_quit = $UI/PauseMenu/TextureRect/Quit
	pause_menu_quit.pressed.connect(_on_quit)

func load_level(level_ind : int):
	if level_ind < 0 or levels.size() <= level_ind:
		print("No existe nivel de indice ", level_ind)
	else:
		curr_level_ind = level_ind
		
		# remueve el menu principal.
		var menu = get_node_or_null("UI/MainMenu")
		if menu:
			ui.remove_child(menu)
		
		# comienza a cargar nivel
		var err = ResourceLoader.load_threaded_request(levels[curr_level_ind])
		print(err)
		# loading screen
		loading_screen_node = loading_screen.instantiate()
		ui.add_child(loading_screen_node)
		loading_screen_node.set_level(levels[curr_level_ind])
		loading_screen_node.connect("level_loaded",_on_level_loaded)
		
		# carga dialogo del nivel y ejecuta la fase 1.
		dialogue.load_dialogue(curr_level_ind)
		phase = 1
		dialogue.run_dialogue(curr_level_ind,phase)
		dialogue.dialogue_end.connect(_on_dialogue_end)

func _on_level_loaded():
	# borra el nivel actual y carga el nivel deseado.
	for child in level_container.get_children():
		child.queue_free()
	curr_level = ResourceLoader.load_threaded_get(levels[curr_level_ind])
	level_container.add_child(curr_level.instantiate())
	loading_screen_node.queue_free()
				

func _on_dialogue_end():
	var lvl = level_container.get_child(0)
	if phase == 1:
		lvl.start_phase(1)
		
	elif phase == 2:
		lvl.start_phase(2)
		
func _on_resume():
	pause_menu.visible = false
	
func _on_quit():
	pause_menu.visible = false
	# borra el nivel actual.
	for child in level_container.get_children():
		child.queue_free()
	ui.add_child(main_menu)
	
func _input(event: InputEvent) -> void:
	if curr_level_ind != -1:
		if event.is_action_pressed("pause"):
			pause_menu.visible = true
