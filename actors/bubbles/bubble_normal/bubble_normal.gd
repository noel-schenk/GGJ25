extends RigidBody2D
class_name BubbleNormal

@export var Pushable = true
@export var Breakable = true

@onready var base = $BubbleBase as BubbleBase

func _ready() -> void:
	add_to_group("Bubble")
	if Pushable:
		add_to_group("Pushable")
	if Breakable:
		add_to_group("Breakable")
	
	
func pop():
	collision_mask = 0
	collision_layer = 0
	if multiplayer.is_server():
		base.pop()
		Utils.set_timeout(func():
			queue_free()
		, 1.0)

func foamify():
	collision_mask = 0
	collision_layer = 0
	if multiplayer.is_server():
		base.pop()
	
