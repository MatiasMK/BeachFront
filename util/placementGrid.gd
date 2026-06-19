extends Node3D

## Gridmap of all blocked cells.
@export var obstacles: GridMap
@onready var grid: Node3D = $Grid

var object
var _current_object_name: String = ""
var _last_print: int = 0

signal building_placed(building_name: String)
var _overlay_green: Material
var _overlay_red: Material


# 0 = up | 1 = right | 2 = down | 3 = left
var rotation_index = 0

func _ready() -> void:
	_overlay_green = StandardMaterial3D.new()
	_overlay_green.albedo_color = Color(0, 1, 0, 0.3)
	_overlay_green.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_overlay_red = StandardMaterial3D.new()
	_overlay_red.albedo_color = Color(1, 0, 0, 0.3)
	_overlay_red.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _should_print() -> bool:
	var now = Time.get_ticks_msec()
	if now - _last_print > 1000:
		_last_print = now
		return true
	return false

## Cancel the current placement and clean up.
func cancel_placement() -> void:
	if not object: return
	object.queue_free()
	_current_object_name = ""
	object = null

## Starts the placement process.
func start_placement(building: String, scene: PackedScene) -> void:
	_current_object_name = building
	var newPlacement = scene.instantiate()
	add_child(newPlacement)
	object = newPlacement

func _input(event: InputEvent) -> void:
	## If there isn't a building selected, skip the rest.
	if not object: return
	## Cancel placement on Escape.
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_placement()
		return
	## On_click place building on grid.
	if Input.is_action_just_pressed("left_mouse_click"):
		## Get current mouse position.
		var click_pos = _get_grid_position()
		if click_pos:
			## Set object to mouses position.
			object.global_position = click_pos
			## Based on mouse position, get cell candidates for placement.
			var cells = _get_object_cells()
			## Higlight candidate cells. And check if placement is posible.
			if _check_cells(cells):
				_place_placement(cells)
	if Input.is_action_just_pressed("rotate_left"):
		if rotation_index == 0:
			rotation_index = 3
		else:
			rotation_index -= 1
		if object.rotation.y == 2*PI:
			object.get_child(0).rotation = Vector3(0,PI/2,0)
		else:
			object.get_child(0).rotation = Vector3(0,object.get_child(0).rotation.y + PI/2,0)
		var gridpos = _get_grid_position()
		if gridpos:
			object.position = gridpos
	if Input.is_action_just_pressed("rotate_right"):
		if rotation_index == 3:
			rotation_index = 0
		else:
			rotation_index += 1
		if object.rotation.y == -2*PI:
			object.get_child(0).rotation = Vector3(0,-PI/2,0)
		else:
			object.get_child(0).rotation = Vector3(0,object.get_child(0).rotation.y -PI/2,0)
		var gridpos = _get_grid_position()
		if gridpos:
			object.position = gridpos
		
		
	
func _process(delta: float) -> void:
	## If there isn't a building selected, skip the rest.
	if not object: return
	## Get current mouse position.
	var mouseGridPosition = _get_grid_position()
	if mouseGridPosition:
		## Set object to follow the mouse.
		object.global_position = mouseGridPosition

		## Get cell candidates for placement.
		var cells = _get_object_cells()
		## Highlight candidate cells. And check if placement is posible.
		var valid = _check_cells(cells)
		## Set object overlay to red (unplaceable) or green (placeable).
		_set_block_overlay(_overlay_green if valid else _overlay_red)

## Get corresponding grid position to the current mouse position.
func _get_grid_position():
	var mousePositionDepth = 100
	var mousePosition := get_viewport().get_mouse_position()
	var currentCamera := get_viewport().get_camera_3d()
	var params := PhysicsRayQueryParameters3D.new()

	params.from = currentCamera.project_ray_origin(mousePosition)
	params.to = currentCamera.project_position(mousePosition, mousePositionDepth)
	params.collide_with_bodies = false
	params.collide_with_areas = true

	var worldspace := get_world_3d().direct_space_state
	var intersect := worldspace.intersect_ray(params)

	if not intersect:
		return

	if intersect.collider.get_parent().name != "Grid":
		return

	var hit = intersect.position
	var local = grid.to_local(hit)
	var col = round(local.x / grid.cellSize.x)
	var row = round(local.z / grid.cellSize.y)

	return Vector3(
		grid.global_position.x + col * grid.cellSize.x,
		grid.global_position.y,
		grid.global_position.z + row * grid.cellSize.y
	)

## Get the candidate cells for the placement of the current object.
func _get_object_cells():
	var cells := [] ## Var to return, list of candidate cells.
	var grid_origin = grid.global_position
	var anchor_col = round((object.global_position.x - grid_origin.x) / grid.cellSize.x) ## Anchor column of object.
	var anchor_row = round((object.global_position.z - grid_origin.z) / grid.cellSize.y) -1 ## Anchor row of object.
	var statuses = []
	#print(anchor_col, " ", anchor_row)
	for offset in object.get_cell_offsets(rotation_index):
		var target = Vector2i(anchor_col + offset.x, anchor_row + offset.y)
		if grid.child_coords.has(target):
			var cell = grid.child_coords[target]
			if not cell.full:
				statuses.append("(" + str(target.x) + "," + str(target.y) + ") Empty") ## DEBUGG
				cells.append(cell)
			else: statuses.append("(" + str(target.x) + "," + str(target.y) + ") Full") ## DEBUGG
		else: statuses.append("(" + str(target.x) + "," + str(target.y) + ") OOB") ## Out Of Bounds. DEBUGG

	if _should_print():print(object.name, " celdas: ", ", ".join(statuses)) ## DEBUGG

	return cells

## Checks if the cells given are occupied. And changes their color acordingly.
func _check_cells(objectCells: Array):
	var expected = object.get_cell_offsets(rotation_index).size()

	if objectCells.size() != expected:
		return false

	var isValid = true

	return isValid

## Changes the objects overlay.
func _set_block_overlay(material: Material):
	for mesh in object.find_children("*", "MeshInstance3D", true):
		mesh.material_override = material

## Places the building.
func _place_placement(objectCells):
	## Get rid of the green overlay.
	_set_block_overlay(null)
	
	object = null
	## Set all cell candidates to full.
	for cell in objectCells:
		cell.full = true
	## Signal that the building has been placed.
	building_placed.emit(_current_object_name)
