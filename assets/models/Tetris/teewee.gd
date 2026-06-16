extends StaticBody3D

@export var cells: Array[Vector2i] = [Vector2i(0,1), Vector2i(-1,1), Vector2i(1,1), Vector2i(0,0)]
@export var offset:Vector3 = Vector3(0.5, 0, 0.5)

func _ready() -> void:
	for child in get_children():
		child.position -= offset

func get_cell_offsets() -> Array[Vector2i]:
	return cells
