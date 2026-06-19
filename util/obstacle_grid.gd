extends GridMap
@onready var cam: Camera3D = $"../Camera3D"
@onready var obstacle_grid: GridMap = $"."
var current_cell: Vector3i = Vector3i.ZERO
func _physics_process(delta: float) -> void:
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
			var local_pos = obstacle_grid.to_local(result.position)
			# Convert local space to specific GridMap Cell coordinates
			current_cell = obstacle_grid.local_to_map(local_pos)
			#print(current_cell)
