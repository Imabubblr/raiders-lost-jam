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


@export var player: CharacterBody2D
@export var enemy: Node2D
@export var wait_time: float
@export var exit: Node2D

var mazes_solved: int = 0
var is_transitioning: bool = false


func _cell_to_global(cell: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(cell))


func _ready() -> void:
	create_maze()

func create_maze():

	if enemy != null:
		enemy.visible = false
		enemy.set_physics_process(false)
	
	tilemap.clear()

	var maze = MazeGen.new(maze_size.x, maze_size.y)
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
	
	# Reposition existing enemy at entrance after 1.5 second
	var spawn_position := _cell_to_global(maze.start)
	await get_tree().create_timer(wait_time).timeout
	enemy.global_position = spawn_position
	enemy.visible = true
	enemy.set_physics_process(true)


func _on_exit_body_entered(_body: Node2D) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	mazes_solved += 1
	GameState.mazes_beat = mazes_solved
	maze_size += Vector2i(5, 5)
	create_maze()

	player.set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	player.set_physics_process(true)
	
	is_transitioning = false
