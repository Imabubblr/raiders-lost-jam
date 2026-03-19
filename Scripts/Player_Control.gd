extends CharacterBody2D


const SPEED = 300.0
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
		velocity.x = xdirection * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if ydirection:
		velocity.y = ydirection * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
	xdirection = 0
	ydirection = 0
