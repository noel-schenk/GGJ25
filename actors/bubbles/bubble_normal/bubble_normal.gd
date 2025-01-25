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
	
	
