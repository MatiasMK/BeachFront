extends CanvasLayer

@onready var test: Node3D = $".."

## List of possible buildings, links to their scenes.
const BUILDINGS = {
	"Hotel": preload("uid://cjbw6a27hy6tq"),
	"Tennis Court": preload("uid://bex6koivmd6gv"),
	"Restaurant": preload("uid://dfyak3nqjseo0"),
	"Spa": preload("uid://biawoa84ynn1c")
}

func _ready() -> void:
	## Canvas layer settings
	var container = HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	container.offset_bottom = -8
	add_child(container)

	container.mouse_filter = Control.MOUSE_FILTER_PASS
	## Creates a button to select each building.
	for building in BUILDINGS:
		var button = Button.new()
		button.text = building
		## When pressed, each button selects its corresponding building.
		button.pressed.connect(_on_building_selected.bind(BUILDINGS[building]))
		container.add_child(button)

func _on_building_selected(scene: PackedScene) -> void:
	## Starts the placing process with the given building.
	if test.object == null:
		test.start_placement(scene)
