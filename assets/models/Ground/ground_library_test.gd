
extends Area3D

@onready var sand: MeshInstance3D = $Sand
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var cellSize:Vector2 = Vector2(1,1)
var full = false

func _ready() -> void:
	sand.mesh.size = cellSize
	collision_shape_3d.shape.size = Vector3(cellSize.x, 0.01, cellSize.y)
	
	change_color(get_parent().defaultColor)
	
func change_color(newColor: Color):
	if sand.mesh.material == null:
		sand.mesh.material = StandardMaterial3D.new()
	sand.mesh.material.albedo_color = newColor

func get_rect():
	return Rect2(Vector2(global_position.x, global_position.z), cellSize)
