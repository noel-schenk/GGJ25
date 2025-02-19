extends Node2D

@export var spawn_time = 0.0;
@export var original_pos = Vector2.ZERO
@onready var foam: SingleBubble = $Foam

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
	elif spawn_time < 3.2:
		pass
	elif spawn_time < 4.1:
		var scale_change = (spawn_time - 3.2) / 0.3
		scale = Vector2(3.0 - scale_change, 1.0)
		position = original_pos + Vector2(30.0 * 3.0 + 30.0 * scale_change, 0.0)
	else:
		scale = Vector2.ZERO
		queue_free()
