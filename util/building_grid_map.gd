extends GridMap

## Gridmap of all blocked cells.
@export var obstacles: GridMap
@export var gridWidth: int = 16
@export var gridHeight: int = 9

@onready var building_selector = $BuildingSelector

const BUILDING_LEVEL = 0
const OCCUPIED_ID = 7

var selected_id = -1
var _ghost: MeshInstance3D
var _current_object_name: String = ""
var accept_input = false

signal building_placed(building_name: String)
var _overlay_green: Material
var _overlay_red: Material

# 0 = up | 1 = right | 2 = down | 3 = left
var rotation_index = 0
var rotation_dir = 0

func _ready() -> void:
	_overlay_green = StandardMaterial3D.new()
	_overlay_green.albedo_color = Color(0, 1, 0, 0.3)
	_overlay_green.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_overlay_red = StandardMaterial3D.new()
	_overlay_red.albedo_color = Color(1, 0, 0, 0.3)
	_overlay_red.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	check_obstacles()

## Cancel the current placement and clean up.
func cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	selected_id = -1
	rotation_index = 0
	
func start_placement(building_name, item_id):
	var mesh = mesh_library.get_item_mesh(item_id)
	_ghost = MeshInstance3D.new()
	_ghost.mesh = mesh
	add_child(_ghost)
	selected_id = item_id
	_current_object_name = building_name

func rotate_ghost(deg:float):
	var degree = _ghost.rotation.y
	print(rotation)
	if degree == 0 and deg < 0:
		_ghost.basis = Basis(Vector3(0,1,0), 1.5*PI)
	elif degree == 1.5*PI and deg > 0:
		_ghost.basis = Basis(Vector3(0,1,0), 0)
	else:
		_ghost.basis = Basis(Vector3(0,1,0), deg) * _ghost.basis

func _input(_event: InputEvent) -> void:
	## If there isn't a building selected, skip the rest.
	if selected_id == -1: return
	## Cancel placement on Escape.
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_placement()
		return
	## On_click place building on grid.
	if Input.is_action_just_pressed("left_mouse_click"):
		## Get current mouse position.
		var click_pos = _get_click_position()
		#print(click_pos)
		if click_pos and _pos_is_valid(click_pos):
			var cells = get_building_cells(selected_id)
			for cell in cells:
				print(Vector3i(click_pos.x+cell.x,BUILDING_LEVEL,click_pos.z+cell.y))
				set_cell_item(Vector3i(click_pos.x+cell.x,BUILDING_LEVEL,click_pos.z+cell.y),OCCUPIED_ID,rotation_index)
			set_cell_item(Vector3i(click_pos.x,BUILDING_LEVEL,click_pos.z),selected_id,rotation_index)
			## Resets selected_id.
			building_placed.emit(_current_object_name)
			cancel_placement()
	
	if Input.is_action_just_pressed("rotate_left"):
		rotation_dir = -1
		rotate_ghost(PI/2)
		if rotation_index == 0:
			rotation_index = 16 # left
		elif rotation_index == 16:
			rotation_index = 10 # down
		elif rotation_index == 10:
			rotation_index = 22 # right
		else:
			rotation_index =0
	if Input.is_action_just_pressed("rotate_right"):
		rotation_dir = 1
		rotate_ghost(-PI/2)
		if rotation_index == 0:
			rotation_index = 22 #right
		elif rotation_index == 22:
			rotation_index = 10 #down
		elif rotation_index == 10:
			rotation_index = 16 # left
		else:
			rotation_index = 0
		
		
	
func _physics_process(_delta: float) -> void:
	## If there isn't a building selected, skip the rest.
	if selected_id == -1: return
	## Get current mouse position.
	var cell = _get_click_position()
	if _ghost and cell != null:
		_ghost.global_position = to_global(map_to_local(cell))
		var valid = _pos_is_valid(cell)
		_ghost.material_override = _overlay_green if valid else _overlay_red
	


## Get corresponding grid position to the current mouse position.
func _get_click_position():
	var current_cell = null
	# Cast a ray from the camera to the mouse position
	var cam = get_viewport().get_camera_3d()
	if not cam: return null
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mouse_pos)#project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	# Convert global collision point to local GridMap space
	var local_pos = to_local(result.position)
	# Convert local space to specific GridMap Cell coordinates
	current_cell = local_to_map(local_pos)
	print("cell: ", current_cell)
	return current_cell

func _pos_is_valid(pos : Vector3i):
	if pos:
		#pos.y -= 1
		var cells = get_building_cells(selected_id)
		
		for cell in cells:
			cell.x += pos.x
			cell.y += pos.z #+ 1
			print("valido celdas ", cell)
			if cell.x < 0 or cell.y < 0:
				return false
			elif cell.x >= gridWidth or cell.y >= gridHeight:
				return false
			if get_cell_item(Vector3i(cell.x,BUILDING_LEVEL,cell.y)) != INVALID_CELL_ITEM:
				return false
		return true
	return false
	
	
func get_building_cells(id : int):
	var cells
	match id:
		0: cells= [Vector2i(0,0), Vector2i(1,1), Vector2i(1,0), Vector2i(-1,0)]
		1: cells= [Vector2i(0,0), Vector2i(0,-1), Vector2i(-1,-1), Vector2i(1,0)]
		2: cells= [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(2,0)]
		3: cells= [Vector2i(0,0), Vector2i(0,-1), Vector2i(0,1), Vector2i(1,1)]
		4: cells= [Vector2i(0,0), Vector2i(-1,0), Vector2i(0,-1), Vector2i(1,-1)]
		5: cells= [Vector2i(0,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(1,-1)]#hotel
		6: cells= [Vector2i(0,0), Vector2i(-1,0), Vector2i(0,-1), Vector2i(1,0)]
		
		
		
	if rotation_index == 0:
		return cells
	var result : Array[Vector2i] = []
	if rotation_index == 22:
		for cell in cells:
			result.append(Vector2i(-cell.y,cell.x))
	elif rotation_index == 10:
		for cell in cells:
			result.append(Vector2i(-cell.x,-cell.y))
	elif rotation_index == 16:
		for cell in cells:
			result.append(Vector2i(cell.y,-cell.x))
	return result
	
func check_obstacles():
	for width in gridWidth:
		for height in gridHeight:
			var cell = obstacles.get_cell_item(Vector3i(width,BUILDING_LEVEL,height))
			if cell == 0:
				set_cell_item(Vector3(width,BUILDING_LEVEL,height), 7, rotation_index)
