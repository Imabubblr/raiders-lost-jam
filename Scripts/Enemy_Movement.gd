extends CharacterBody2D

@onready var player: CharacterBody2D = $"../../Player"

const SPEED = 150.0

func _physics_process(_delta: float) -> void:
	
	var direction = (player.global_position-global_position).normalized()
	velocity = direction * SPEED
	look_at(player.global_position)
	
	move_and_slide()
