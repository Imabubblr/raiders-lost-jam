extends Node
class_name MazeGen

var width: int
var height: int
var start: Vector2i
var end: Vector2i
var grid: grid2

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
		
func makemaze():
	if !grid: grid = grid2.new(width, height)
	else: grid.recycle(width, height)
	
	var card_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	
	start = Vector2i(randi_range(1, width - 2), randi_range(1, height - 2))
	end = start
	
	grid.setpoint(start,1)
	
	var points: Array[Vector2i] = []
	var queue : Array[Vector2i] = []
	queue.append(start)
	
	while(queue.size()>0):
		card_directions.shuffle()
		
		var current = queue.back()
		var added = false
		
		for direction in card_directions:
			var next: Vector2i = current + direction
			if next.x <= 0 or next.x >= width-1 or next.y <= 0 or next.y >= height-1: continue
			if grid.getpoint(next) : continue
			var orth = Vector2i(direction.y, direction.x)
			var addnext = true
			for nei in [next+orth, next+orth+direction, next+direction, next-orth+direction, next - orth]:
				if nei.x < 0 or nei.x >= width or nei.y < 0 or nei.y >= height: continue
				if grid.getpoint(nei):
					addnext = false
					break
			
			if addnext:
				points.append(next)
				queue.append(next)
				grid.setpoint(next, grid.getpoint(current)+1)
				added = true
				if grid.getpoint(queue.back()) > grid.getpoint(end):
					end = next
				break
		if !added:
			queue.pop_back()
	
	
