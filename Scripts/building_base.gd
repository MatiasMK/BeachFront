extends StaticBody3D

## Cells that each object ocuppies.
@export var cells: Array[Vector2i]
## Ofset to center the object.
@export var offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	for child in get_children():
		child.position -= offset

func get_cell_offsets(rotation_index : int) -> Array[Vector2i]:
	var result : Array[Vector2i]
	if rotation_index == 0:
		result = cells
	if rotation_index == 1:
		for cell in cells:
			result.append(Vector2i(-cell.y,cell.x))
	if rotation_index == 2:
		for cell in cells:
			result.append(Vector2i(-cell.x,-cell.y))
	if rotation_index == 3:
		for cell in cells:
			result.append(Vector2i(cell.y,-cell.x))
	return result
