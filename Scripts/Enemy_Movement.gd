extends CharacterBody2D

var speed = 800

@export var player: CharacterBody2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

func _physics_process(_delta: float) -> void:
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed
	
	move_and_slide()

func findpath() -> void:
	nav.target_position = player.global_position


func _on_timer_timeout() -> void:
	findpath()
