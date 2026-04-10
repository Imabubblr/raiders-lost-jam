extends CharacterBody2D


@export var SPEED = 300.0
var xdirection
var ydirection

func read_input():
	if Input.is_action_pressed("Up"):
		ydirection = -1
	if Input.is_action_pressed("Down"):
		ydirection = 1
	if Input.is_action_pressed("Left"):
		xdirection = -1
	if Input.is_action_pressed("Right"):
		xdirection = 1

func _physics_process(_delta: float) -> void:
	read_input()
	
	if xdirection:
		velocity.x = xdirection * (SPEED + GameState.mazes_beat*5)
	else:
		velocity.x = move_toward(velocity.x, 0, (SPEED + GameState.mazes_beat*5))
		
	if ydirection:
		velocity.y = ydirection * (SPEED + GameState.mazes_beat*5)
	else:
		velocity.y = move_toward(velocity.y, 0, (SPEED + GameState.mazes_beat*5))
	
	move_and_slide()
	xdirection = 0
	ydirection = 0
