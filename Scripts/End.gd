extends Control

@export var game_over_label: RichTextLabel


func _ready() -> void:
	GameState.submit_run_score(GameState.mazes_beat)
	game_over_label.text = "Mazes Beat: %d\nHigh Score: %d" % [GameState.mazes_beat, GameState.high_score]

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
