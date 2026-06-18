extends StaticBody3D

## Cells that each object ocuppies.
@export var cells: Array[Vector2i]
## Ofset to center the object.
@export var offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	for child in get_children():
		child.position -= offset

func get_cell_offsets() -> Array[Vector2i]:
	return cells
