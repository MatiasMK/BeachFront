extends Node

@onready var ui = $UI
@onready var level_container = $LevelContainer
@onready var loading_screen = $UI/LoadingScreen
@onready var dialogue : DialogueManager = $UI/Dialogue

const MAIN_MENU = preload("res://scenes/main_menu.tscn")
var LEVEL_1_PATH = "res://levels/level_1.tscn"

var levels = [LEVEL_1_PATH]
var curr_level = null
var curr_level_ind = -1
var phase = 1

func _ready():
	var main_menu = MAIN_MENU.instantiate()
	ui.add_child(main_menu) # carga menu principal
	main_menu.connect("on_play",load_level.bind(0))

func _process(delta: float) -> void:
	# Pantalla de carga (dudo que se llegue a ver)
	if curr_level_ind >= 0:
		var status = ResourceLoader.load_threaded_get_status(levels[curr_level_ind])
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				loading_screen.visible = true
			ResourceLoader.THREAD_LOAD_LOADED:
				loading_screen.visible = false

func load_level(level_ind : int):
	if level_ind < 0 or levels.size() <= level_ind:
		print("No existe nivel de indice ", level_ind)
	else:
		curr_level_ind = level_ind
		
		# remueve el menu principal.
		var menu = get_node_or_null("UI/MainMenu")
		if menu:
			ui.remove_child(menu)
		
		# borra el nivel actual y carga el nivel deseado.
		level_container.get_children()
		level_container.remove_child(curr_level)
		if curr_level:
			curr_level.queue_free()
		curr_level = ResourceLoader.load_threaded_get(levels[level_ind])
		add_child(curr_level)
		
		# carga dialogo del nivel y ejecuta la fase 1.
		dialogue.load_dialogue(curr_level_ind)
		phase = 1
		dialogue.run_dialogue(curr_level_ind,phase)
		dialogue.dialogue_end.connect(_on_dialogue_end)
			
func _on_dialogue_end():
	var lvl = level_container.get_child(0)
	if phase == 1:
		lvl.start_phase(1)
		
	elif phase == 2:
		lvl.start_phase(2)
