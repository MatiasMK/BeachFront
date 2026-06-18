extends CanvasLayer

@onready var placementGrid: Node3D = $".."

## List of possible buildings, links to their scenes.
const BUILDINGS = {
	"Hotel": preload("uid://b061u217jqoof"),
	"Tennis Court": preload("uid://bex6koivmd6gv"),
	"Restaurant": preload("uid://dfyak3nqjseo0"),
	"Spa": preload("uid://biawoa84ynn1c"),
	"Cafe": preload("uid://mff76fra2ulj"),
	"Club": preload("uid://3fkt4o73fj7v"),
	"Shops": preload("uid://daajna354d8go")
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
	if placementGrid.object == null:
		placementGrid.start_placement(scene)
