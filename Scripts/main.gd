extends Node2D


func _on_button_pressed() -> void:
	GameState.reset_progress()
	get_tree().change_scene_to_file("res://Scenes/Maze1.tscn")
