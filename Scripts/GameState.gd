extends Node

var mazes_beat: int = 0
var high_score: int = 0

func reset_progress() -> void:
	mazes_beat = 0


func submit_run_score(score: int) -> void:
	if score > high_score:
		high_score = score
