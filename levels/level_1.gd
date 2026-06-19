extends Node3D

@export var hover_material: Material
@onready var cam = $Camera3D
@onready var ground_grid_map: GridMap = $GroundGridMap
@onready var building_grid_map = $BuildingGridMap

var current_cell: Vector3i = Vector3i.ZERO
var previous_cell: Vector3i = Vector3i.ZERO
var cell_has_hover: bool = false
var accept_input : bool = false # cuando esta corriendo el dialogo o el menu de pausa, false

signal end_of_phase

func _ready() -> void:
	building_grid_map.building_selector.inventory.inventory_empty.connect(_on_inventory_empty)

func _physics_process(_delta):
	# Cast a ray from the camera to the mouse position
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = cam.position#project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)

	if result:
		if result.collider.get_parent() is GridMap:
			# Convert global collision point to local GridMap space
			var local_pos = ground_grid_map.to_local(result.position)
			# Convert local space to specific GridMap Cell coordinates
			current_cell = ground_grid_map.local_to_map(local_pos)
			if current_cell != previous_cell or not cell_has_hover:
				reset_previous_tile()
				previous_cell = current_cell
				cell_has_hover = true
		else:
			reset_previous_tile()
	else:
		reset_previous_tile()

func highlight_tile(cell_pos: Vector3i):
	ground_grid_map.set_cell_item(Vector3i(cell_pos.x,1,cell_pos.z),2)

func reset_previous_tile():
	cell_has_hover = not cell_has_hover
	ground_grid_map.set_cell_item(Vector3i(previous_cell.x,1,previous_cell.z),-1)

func start_phase(phase : int):
	if phase == 1:
		$Phase1Music.play()
	elif phase == 2:
		$Phase1Music.stop()
		$Phase2Music.play()
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property($DirectionalLight3D, "light_color", Color(0.001, 0.238, 0.825, 1.0),2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		tween.tween_property($DirectionalLight3D, "light_energy", 0.7,2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		tween.tween_property($WorldEnvironment.environment, "background_color", Color(0.2,0.2,0.4),2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		tween.tween_property($WorldEnvironment.environment, "glow_bloom", 1,2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		tween.tween_property($DirectionalLight3D, "shadow_opacity", 0,2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		building_grid_map.building_selector.inventory.add_building("Little Plant", 4)
		building_grid_map.building_selector.inventory.add_building("Big Plant", 1)
		building_grid_map.building_selector.inventory.add_building("Pink Flowers", 3)
	
func set_accept_input(val):
	accept_input = val
	building_grid_map.accept_input = val

func _input(event: InputEvent) -> void:
	if accept_input:
		if event.is_action_pressed("move_cam"):
			cam.switch_spot()
	
func _on_inventory_empty():
		end_of_phase.emit()
