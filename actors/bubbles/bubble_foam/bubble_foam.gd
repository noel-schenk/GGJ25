extends Node2D

var spawn_time = 0.0;
var original_pos = Vector2.ZERO

func _ready() -> void:
	add_to_group("Bubble")

func spawn() -> void:
	original_pos = global_position
	spawn_time = 0.0

func _process(delta: float) -> void:
	spawn_time += delta
	if spawn_time < 0.3:
		scale = Vector2(spawn_time / 0.3, spawn_time / 0.3)
	elif spawn_time < 1.2:
		scale = Vector2(spawn_time / 0.3, 1.0)
		position = original_pos + Vector2(30.0 * (spawn_time / 0.3 - 1.0), 0.0)
	elif spawn_time < 1.5:
		var scale_change = (spawn_time - 1.2) / 0.3
		scale = Vector2(3.0 - scale_change * 3.0, 1.0)
		position = original_pos + Vector2(30.0 * 3.0 + 30.0 * scale_change * 3.0, 0.0)
	else:
		scale = Vector2.ZERO
		queue_free()
