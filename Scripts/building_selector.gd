extends CanvasLayer

@onready var placementGrid = $".."
@onready var inventory = $"../Inventory"

var _buttons: Dictionary = {}

func _ready() -> void:
	var container = HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	container.offset_bottom = -8
	add_child(container)
	container.mouse_filter = Control.MOUSE_FILTER_PASS

	inventory.inventory_changed.connect(_refresh)
	placementGrid.building_placed.connect(_on_building_placed)
	_refresh()

func _refresh(_building: String = "", _quantity: int = 0) -> void:
	var container = get_child(0)
	for building in inventory.inventory:
		var entry = inventory.inventory[building]
		if entry["quantity"] > 0 and not _buttons.has(building):
			_create_button(container, building, entry["scene"], entry["quantity"])
		elif entry["quantity"] <= 0 and _buttons.has(building):
			_remove_button(building)
		elif _buttons.has(building):
			_update_button(building, entry["quantity"])

func _create_button(container: Control, building: String, scene: PackedScene, qty: int) -> void:
	var btn = Button.new()
	btn.text = building + " (" + str(qty) + ")"
	container.add_child(btn)
	btn.pressed.connect(_on_building_selected.bind(building, scene))
	_buttons[building] = btn

func _remove_button(building: String) -> void:
	_buttons[building].queue_free()
	_buttons.erase(building)

func _update_button(building: String, qty: int) -> void:
	_buttons[building].text = building + " (" + str(qty) + ")"

func _on_building_selected(building: String, scene: PackedScene) -> void:
	if placementGrid.object != null:
		return
	placementGrid.start_placement(building, scene)

func _on_building_placed(building: String) -> void:
	inventory.substract_building(building, 1)
