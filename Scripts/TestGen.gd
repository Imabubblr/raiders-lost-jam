extends Node2D

@export var tilemap: TileMapLayer
@export var maze_size: Vector2i = Vector2i(10, 10)

@export_group("Maze Tiles")
@export var wall_source_id: int = 2
@export var wall_atlas_coords: Vector2i = Vector2i(0, 0)
@export var wall_alternative: int = 0

@export var path_source_id: int = 2
@export var path_atlas_coords: Vector2i = Vector2i(3, 0)
@export var path_alternative: int = 0

@export_group("Maze Shape")
@export_range(0.0, 1.0, 0.01) var loop_chance: float = 0.10
@export var max_loop_cells: int = -1

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
	maze.loop_chance = loop_chance
	maze.max_loops = max_loop_cells
	maze.makemaze()
	for x in range(maze_size.x):
		for y in range(maze_size.y):
			var point = Vector2i(x,y)
			if !maze.grid.getpoint(point):
				if wall_source_id >= 0:
					tilemap.set_cell(point, wall_source_id, wall_atlas_coords, wall_alternative)
				else:
					tilemap.erase_cell(point)
			else:
				if path_source_id >= 0:
					tilemap.set_cell(point, path_source_id, path_atlas_coords, path_alternative)
				else:
					tilemap.erase_cell(point)
	player.global_position = _cell_to_global(maze.start)
	exit.global_position = _cell_to_global(maze.end)
