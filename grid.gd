@tool
extends Node3D

@export var gridWidth := 5:
	set(value):
		gridWidth = value
		_remove_grid()
		_create_grid()
@export var gridHeight := 5:
	set(value):
		gridHeight = value
		_remove_grid()
		_create_grid()
@export var cellSize:Vector2 = Vector2(1,1):
	set(value):
		cellSize = value
		_remove_grid()
		_create_grid()
@export var defaultColor:Color = Color.GRAY

const PlacementCell = preload("uid://bo06wmdhhngmd")

## Change for the index of the object used to identify obstacles.
var obstacle = 0
var child_coords := {}

## Deletes grid.
func _remove_grid():
	for node in get_children():
		node.queue_free()

## Creates grid.
func _create_grid():
	var child_pos
	for height in range(gridHeight):
		for width in range(gridWidth):
			var gridCell = PlacementCell.instantiate()
			gridCell.cellSize = cellSize
			
			add_child(gridCell)
			
			## Set coordinates of the new cell.
			child_pos = Vector2i(round(width),round(height))
			child_coords[child_pos] = gridCell
			
			var offset = Vector3(width * cellSize.x, 0, height * cellSize.y)
			
			gridCell.position = offset

func _ready() -> void:
	_obstacle_check()

func _obstacle_check():
	for height in range(gridHeight):
		for width in range(gridWidth):
			var child_pos = Vector2i(round(width),round(height))
			var gridCell = child_coords[child_pos]
			## Check if the cell is obstructed by an obstacle.
			if _search_obstacles(get_parent().obstacles, Vector3(child_pos.x, 0, child_pos.y)):
				gridCell.full = true

## Given an ObstacleGrid, and a specific cell,
## returns TRUE if the cell is ocuppied by an obstacle.
func _search_obstacles(obstacleGrid:GridMap, coords:Vector3):
	var object = obstacleGrid.get_cell_item(coords)
	## Check if cell is empty.
	if object != -1:
		## If not empty, return true if its an obstacle.
		return object == obstacle
	return false
