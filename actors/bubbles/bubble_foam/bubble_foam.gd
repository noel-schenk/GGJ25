extends Node2D

var spawn_time = 0.0;
var original_pos = Vector2.ZERO

func _ready() -> void:
	add_to_group("Bubble")

func spawn() -> void:
	spawn_time = 0.0;

func _process(delta: float) -> void:
	spawn_time += delta
	if spawn_time < 1.0:
		scale = Vector2(spawn_time, spawn_time)
	elif spawn_time < 5.0:
		scale = Vector2(spawn_time, 1.0)
		position = original_pos + Vector2(0, 30.0 * (spawn_time - 1.0))
