extends RigidBody2D
class_name BubbleNormal

@export var Pushable = true
@export var Breakable = true

var original_position = Vector2.ZERO
var original_collision_mask = 0
var original_collision_layer = 0

@onready var base = $BubbleBase as BubbleBase

func _ready() -> void:
	original_position = global_position
	add_to_group("Bubble")
	if Pushable:
		add_to_group("Pushable")
	if Breakable:
		add_to_group("Breakable")
	
	
func pop():
	original_collision_mask = collision_mask
	original_collision_layer = collision_layer
	collision_mask = 0
	collision_layer = 0
	if multiplayer.is_server():
		base.pop()
		Utils.set_timeout(func():
			global_position = original_position
			base.AnimatedBubble.grow = true
			collision_mask = original_collision_mask
			collision_layer = original_collision_layer
		, 7.0)
