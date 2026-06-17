extends CanvasLayer

@onready var test = $".."

const BUILDINGS = {
	"Smashboy": preload("uid://cjbw6a27hy6tq"),
	"Bluericky": preload("uid://dg4g8p8ypg8uh"),
	"Teewee": preload("uid://6oowpa64cir8"),
	"SPA": preload("uid://biawoa84ynn1c"),
}

func _ready() -> void:
	var container = HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	container.offset_bottom = -8
	add_child(container)

	container.mouse_filter = Control.MOUSE_FILTER_PASS

	for building in BUILDINGS:
		var btn = Button.new()
		btn.text = building
		btn.pressed.connect(_on_building_selected.bind(BUILDINGS[building]))
		container.add_child(btn)

func _on_building_selected(scene: PackedScene) -> void:
	test.start_placement(scene)
