extends Node3D

@onready var grid: Node3D = $Grid

const SMASHBOY = preload("uid://cjbw6a27hy6tq")
const BLUERICKY = preload("uid://dg4g8p8ypg8uh")

var object
var _last_print: int = 0

func _should_print() -> bool:
	var now = Time.get_ticks_msec()
	if now - _last_print > 1000:
		_last_print = now
		return true
	return false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_mouse_click") and not object:
		var buildings = [SMASHBOY,BLUERICKY]
		var newPlacement = buildings.pick_random().instantiate()
		add_child(newPlacement)
		object = newPlacement
	elif Input.is_action_just_pressed("left_mouse_click") and object:
		var click_pos = _get_grid_position()
		if click_pos:
			object.global_position = click_pos
			var cells = _get_object_cells()
			if _check_and_highlight_cells(cells):
				_place_placement(cells)

func _process(delta: float) -> void:
	if not object: return
	
	var mouseGridPosition = _get_grid_position()
	if mouseGridPosition:
		object.global_position = mouseGridPosition
		
		_reset_highlight()
		var cells = _get_object_cells()
		_check_and_highlight_cells(cells)

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

func _reset_highlight():
	for child in grid.get_children():
		child.change_color(grid.defaultColor)

func _get_object_cells():
	var cells := []
	var grid_origin = grid.global_position
	var anchor_col = round((object.global_position.x - grid_origin.x) / grid.cellSize.x)
	var anchor_row = round((object.global_position.z - grid_origin.z) / grid.cellSize.y)
	var child_map := {}
	for child in grid.get_children():
		var child_pos = Vector2i(
			round((child.global_position.x - grid_origin.x) / grid.cellSize.x),
			round((child.global_position.z - grid_origin.z) / grid.cellSize.y)
		)
		child_map[child_pos] = child

	var statuses := []
	for offset in object.get_cell_offsets():
		var target = Vector2i(anchor_col + offset.x, anchor_row + offset.y)
		if child_map.has(target):
			var cell = child_map[target]
			if cell.full:
				statuses.append("(" + str(target.x) + "," + str(target.y) + ") OCUPADA")
			else:
				statuses.append("(" + str(target.x) + "," + str(target.y) + ") libre")
			cells.append(cell)
		else:
			statuses.append("(" + str(target.x) + "," + str(target.y) + ") FUERA")

	if _should_print():
		print(object.name, " celdas: ", ", ".join(statuses))

	return cells

func _check_and_highlight_cells(objectCells: Array):
	var expected = object.get_cell_offsets().size()

	if objectCells.size() != expected:
		for cell in objectCells:
			cell.change_color(Color.RED)
		return false

	var isValid = true
	for cell in objectCells:
		if cell.full:
			isValid = false
			cell.change_color(Color.RED)
		else:
			cell.change_color(Color.GREEN)

	return isValid

func _place_placement(objectCells):
	object = null

	for cell in objectCells:
		cell.full = true
	
	_reset_highlight()
