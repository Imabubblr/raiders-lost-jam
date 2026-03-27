extends Node2D

@export var tilemap: TileMapLayer
@export var maze_size: Vector2i = Vector2i(10, 10)


func _ready() -> void:
	if tilemap == null:
		push_warning("TestGen: tilemap is not assigned.")
		return

	tilemap.clear()

	var maze = MazeGen.new(maze_size.x, maze_size.y)
	maze.makemaze()
	for x in range(maze_size.x):
		for y in range(maze_size.y):
			var point = Vector2i(x,y)
			if !maze.grid.getpoint(point):
				tilemap.set_cell(point, 2, Vector2i(0, 0), 0)
