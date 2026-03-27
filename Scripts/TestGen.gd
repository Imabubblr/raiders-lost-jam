extends Node2D

@export var tilemap: TileMapLayer
@export var maze_size: Vector2i = Vector2i(10, 10)

@export var player: CharacterBody2D
@export var exit: Node2D


func _cell_to_global(cell: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(cell))


func _ready() -> void:
	create_maze()

func create_maze():
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
	player.global_position = _cell_to_global(maze.start)
	exit.global_position = _cell_to_global(maze.end)
