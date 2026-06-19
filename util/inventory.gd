extends Node3D

## List of building scenes to reference.
const BUILDINGS = {
	## Daytime.
	"Hotel": 5,#preload("uid://b061u217jqoof"),
	"Tennis Court": 3, #preload("uid://bex6koivmd6gv"),
	"Restaurant": 6,#preload("uid://dfyak3nqjseo0"),
	"Spa": 4,#preload("uid://biawoa84ynn1c"),
	"Cafe": 0, #preload("uid://mff76fra2ulj"),
	"Club": 1, #preload("uid://3fkt4o73fj7v"),
	"Shops": 2, #preload("uid://daajna354d8go"),
	## Nightime.
	#"Little Plant": preload("uid://f6qtwqtuk7xv"),
	#"Bigger Plant": preload("uid://f5huurirpqch"),
	#"Diago Plant": preload("uid://iigpcig122cl")
}
## Amount of each building at start of scene.
## Daytime.
@export var inv_hotel: int = 0
@export var inv_tennis_court: int = 0
@export var inv_club: int = 0
@export var inv_cafe: int = 0
@export var inv_shops: int = 0
@export var inv_restaurant: int = 0
@export var inv_spa: int = 0
## Nightime.
@export var inv_little_plant: int = 0
@export var inv_bigger_plant: int = 0
@export var inv_diago_plant: int = 0
## Stores each buildings scene, asociating it with its amount in inventory.
var inventory: Dictionary = {}

signal inventory_changed(building: String, quantity: int)

func _ready() -> void:
	_sync_inventory()
## Parses through all export variables, stores every one that starts with "inv_"
## in the dictionary, asociating it with its corresponding building scene.
func _sync_inventory() -> void:
	inventory.clear()
	for prop in get_property_list():
		if prop.name.begins_with("inv_"):
			var building = prop.name.trim_prefix("inv_")
			var display_name = building.replace("_", " ").capitalize()
			inventory[display_name] = {
				"scene": BUILDINGS.get(display_name),
				"quantity": get(prop.name)
			}

## Adds a given number to the amount of a given building.
func add_building(building: String, amount: int) -> void:
	if not inventory.has(building):
		return
	inventory[building]["quantity"] += amount
	_sync_export(building)
	inventory_changed.emit(building, inventory[building]["quantity"])

## Substract a given number to the amount of a given building.
func substract_building(building: String, amount: int) -> void:
	if not inventory.has(building):
		return
	inventory[building]["quantity"] = max(0, inventory[building]["quantity"] - amount)
	_sync_export(building)
	inventory_changed.emit(building, inventory[building]["quantity"])

## Syncs modified amounts of buildings for the editor view.
func _sync_export(building: String) -> void:
	var snake = building.to_lower().replace(" ", "_")
	var prop = "inv_" + snake
	for p in get_property_list():
		if p.name == prop:
			set(prop, inventory[building]["quantity"])
			return
