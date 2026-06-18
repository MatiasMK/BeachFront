
extends Area3D

@onready var cell: MeshInstance3D = $Cell
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var cellSize:Vector2 = Vector2(1,1)
var full = false

func _ready() -> void:
	cell.mesh.size = cellSize
	collision_shape_3d.shape.size = Vector3(cellSize.x, 0.01, cellSize.y)

func get_rect():
	return Rect2(Vector2(global_position.x, global_position.z), cellSize)
