class_name DialogueManager
extends Control

@onready var text_display : Label = $TextBox/Text
@onready var speaker_name_display : Label = $TextBox/Speaker

const LEVEL_1_PATH = "res://assets/dialogue/level1_dialogue.json"
var ph1_dialogue = null
var ph2_dialogue = null
var dialogue_index = 0

var dialogue_is_running = false

signal dialogue_end

# si el nivel no tiene dialogo poner un json vacio
# FORMATO DEL JSON: UN ARRAY DE 2 OBJETOS FASE COMO EL SIGUIENTE:
# {"phase":"1","dialogue":[{"speaker":"..","text":".."}]}
# SI NO ES ASI, EL JUEGO EXPLOTA ...........
var levels = [LEVEL_1_PATH]
var curr_level = 0
var curr_phase = 0
	
func load_dialogue(level_ind):
	var content = readJSON(levels[level_ind])
	if typeof(content) != TYPE_ARRAY:
		print("error loading dialogue")
	else:
		ph1_dialogue = content[0]["dialogue"]
		ph2_dialogue = content[1]["dialogue"]
		

func readJSON(json_file_path):
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var finish = JSON.parse_string(content)
	return finish
	
func _input(event: InputEvent) -> void:
	if dialogue_is_running:
		if event.is_action_pressed("advance_dialogue"):
			on_advance_dialogue()
	else:
		pass
		
		
func run_dialogue(level,phase):
	dialogue_is_running = true
	curr_level = level
	curr_phase = phase
	on_advance_dialogue()
	visible = true

func on_advance_dialogue():
	if curr_phase == 1:
		if ph1_dialogue != null and ph1_dialogue.size() > dialogue_index:
			speaker_name_display.text = ph1_dialogue[dialogue_index]["speaker"]
			text_display.text = ph1_dialogue[dialogue_index]["text"]
			dialogue_index+=1
		else:
			visible = false
			dialogue_is_running = false
			dialogue_index = 0
			dialogue_end.emit()
			
