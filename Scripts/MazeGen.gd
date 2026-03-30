extends Node
class_name MazeGen

var width: int
var height: int
var start: Vector2i
var end: Vector2i
var grid: grid2
var loop_chance: float = 0.3
var max_loops: int = -1
var mid_loop_chance: float = 0.20
var max_mid_loops: int = -1

class grid2:
	var width
	var height
	var list

	func clear():
		for i in range(list.size()):
			list[i] = 0
	
	func _init(new_wid: int, new_hei: int):
		width = new_wid
		height = new_hei
		list = []
		list.resize(width*height)
		clear()
		
	func setpoint(point: Vector2i, val: int):
		list[point.x + width*point.y] = val
		
	func getpoint(point: Vector2i):
		if point.x < 0 or point.x >= width or point.y < 0 or point.y >= height:
			return 0
		return list[point.x + width*point.y]
		
	func recycle(wid: int, hei: int):
		list.resize(wid*hei)
		width = wid
		height = hei
		clear()
		
func _init(wid: int, hei: int):
	width = wid
	height = hei
	grid = grid2.new(width, height)

func _count_open_neighbors(point: Vector2i, card_directions: Array[Vector2i]) -> int:
	var open_neighbors := 0
	for direction in card_directions:
		if grid.getpoint(point + direction):
			open_neighbors += 1
	return open_neighbors

func _remove_floating_single_walls(card_directions: Array[Vector2i]) -> void:
	var isolated_walls: Array[Vector2i] = []
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			var point := Vector2i(x, y)
			if grid.getpoint(point):
				continue

			# Remove only walls that are completely surrounded by open floor.
			if _count_open_neighbors(point, card_directions) == 4:
				isolated_walls.append(point)

	for point in isolated_walls:
		grid.setpoint(point, 1)

func _fill_three_walled_floor_holes(card_directions: Array[Vector2i], passes: int = 2) -> void:
	for _pass in range(passes):
		var cells_to_fill: Array[Vector2i] = []
		for x in range(1, width - 1):
			for y in range(1, height - 1):
				var point := Vector2i(x, y)
				if !grid.getpoint(point):
					continue
				if point == start or point == end:
					continue

				if _count_open_neighbors(point, card_directions) != 1:
					continue

				# Keep start/end reachable by not filling their only connecting neighbor.
				var single_open_neighbor := Vector2i(-1, -1)
				for direction in card_directions:
					var neighbor := point + direction
					if grid.getpoint(neighbor):
						single_open_neighbor = neighbor
						break

				if single_open_neighbor == start or single_open_neighbor == end:
					continue

				cells_to_fill.append(point)

		if cells_to_fill.size() == 0:
			break

		for point in cells_to_fill:
			grid.setpoint(point, 0)

func _is_inner_cell(point: Vector2i) -> bool:
	return point.x > 0 and point.x < width - 1 and point.y > 0 and point.y < height - 1

func _braid_dead_ends(card_directions: Array[Vector2i]) -> void:
	var dead_ends: Array[Vector2i] = []
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			var point := Vector2i(x, y)
			if !grid.getpoint(point):
				continue
			if _count_open_neighbors(point, card_directions) == 1:
				dead_ends.append(point)

	dead_ends.shuffle()
	var braided := 0

	for dead_end in dead_ends:
		if max_loops >= 0 and braided >= max_loops:
			return
		if randf() > loop_chance:
			continue
		if !grid.getpoint(dead_end):
			continue
		if _count_open_neighbors(dead_end, card_directions) != 1:
			continue

		var reconnect_candidates: Array[Vector2i] = []
		var fallback_candidates: Array[Vector2i] = []
		for direction in card_directions:
			var candidate := dead_end + direction
			if !_is_inner_cell(candidate):
				continue
			if grid.getpoint(candidate):
				continue

			var candidate_open_neighbors := _count_open_neighbors(candidate, card_directions)
			if candidate_open_neighbors >= 2:
				reconnect_candidates.append(candidate)
			elif candidate_open_neighbors >= 1:
				fallback_candidates.append(candidate)

		var chosen_list := reconnect_candidates if reconnect_candidates.size() > 0 else fallback_candidates
		if chosen_list.size() == 0:
			continue

		chosen_list.shuffle()
		grid.setpoint(chosen_list[0], 1)
		braided += 1

func _carve_mid_path_loops() -> void:
	if mid_loop_chance <= 0.0:
		return

	var candidates: Array[Vector2i] = []
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			var point := Vector2i(x, y)
			if grid.getpoint(point):
				continue

			var up_open = grid.getpoint(point + Vector2i.UP)
			var down_open = grid.getpoint(point + Vector2i.DOWN)
			var left_open = grid.getpoint(point + Vector2i.LEFT)
			var right_open = grid.getpoint(point + Vector2i.RIGHT)

			# Carve walls that bridge two opposite corridors.
			var vertical_bridge = up_open and down_open and !left_open and !right_open
			var horizontal_bridge = left_open and right_open and !up_open and !down_open
			if vertical_bridge or horizontal_bridge:
				candidates.append(point)

	candidates.shuffle()
	var carved := 0

	for point in candidates:
		if max_mid_loops >= 0 and carved >= max_mid_loops:
			break
		if randf() > mid_loop_chance:
			continue

		grid.setpoint(point, 1)
		carved += 1

func _set_end_to_farthest_reachable(card_directions: Array[Vector2i]) -> void:
	if !grid.getpoint(start):
		end = start
		return

	var dist: Array[int] = []
	dist.resize(width * height)
	for i in range(dist.size()):
		dist[i] = -1

	var queue: Array[Vector2i] = [start]
	var head := 0

	var start_idx := start.x + width * start.y
	dist[start_idx] = 0

	var farthest := start
	var farthest_dist := 0

	while head < queue.size():
		var current := queue[head]
		head += 1

		var current_idx := current.x + width * current.y
		var current_dist := dist[current_idx]
		if current_dist > farthest_dist:
			farthest_dist = current_dist
			farthest = current

		for direction in card_directions:
			var next := current + direction
			if next.x < 0 or next.x >= width or next.y < 0 or next.y >= height:
				continue
			if !grid.getpoint(next):
				continue

			var next_idx := next.x + width * next.y
			if dist[next_idx] >= 0:
				continue

			dist[next_idx] = current_dist + 1
			queue.append(next)

	end = farthest
		
func makemaze():
	if !grid: grid = grid2.new(width, height)
	else: grid.recycle(width, height)
	
	var card_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]

	# Pick an odd-cell start so 2-step carving creates a clean maze lattice.
	var valid_x: Array[int] = []
	for x in range(1, width - 1, 2):
		valid_x.append(x)
	if valid_x.size() == 0:
		valid_x.append(1)

	var valid_y: Array[int] = []
	for y in range(1, height - 1, 2):
		valid_y.append(y)
	if valid_y.size() == 0:
		valid_y.append(1)

	start = Vector2i(valid_x[randi() % valid_x.size()], valid_y[randi() % valid_y.size()])
	end = start
	grid.setpoint(start, 1)

	var stack: Array[Vector2i] = [start]
	var depth_map := {start: 1}
	var max_depth := 1

	while stack.size() > 0:
		var current: Vector2i = stack.back()
		var directions := card_directions.duplicate()
		directions.shuffle()

		var carved := false
		for direction in directions:
			var next: Vector2i = current + direction * 2
			if next.x <= 0 or next.x >= width - 1 or next.y <= 0 or next.y >= height - 1:
				continue
			if grid.getpoint(next):
				continue

			var between = current + direction
			grid.setpoint(between, 1)
			grid.setpoint(next, 1)

			stack.append(next)
			var next_depth: int = depth_map[current] + 1
			depth_map[next] = next_depth
			if next_depth > max_depth:
				max_depth = next_depth
				end = next
			carved = true
			break

		if !carved:
			stack.pop_back()

	if loop_chance > 0.0:
		_braid_dead_ends(card_directions)

	_carve_mid_path_loops()

	_remove_floating_single_walls(card_directions)
	_set_end_to_farthest_reachable(card_directions)
	
	
