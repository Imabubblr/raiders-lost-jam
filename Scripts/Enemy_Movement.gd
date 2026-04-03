extends CharacterBody2D

var speed = 950

@export var player: CharacterBody2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

func _physics_process(_delta: float) -> void:
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * (speed + GameState.mazes_beat*20)
	
	move_and_slide()

func findpath() -> void:
	nav.target_position = player.global_position


func _on_timer_timeout() -> void:
	findpath()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		call_deferred("_go_to_end_scene")


func _go_to_end_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/End.tscn")
