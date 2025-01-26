extends RigidBody2D
class_name BubbleNormal

@export var Pushable = true
@export var Breakable = true

var COLOR_PUSHABLE = Color.BLUE
var COLOR_POPABLE = Color.RED
var COLOR_BOTH = Color.BLUE_VIOLET

var original_position = Vector2.ZERO
var original_collision_mask = 0
var original_collision_layer = 0
var touching_player: Node2D = null

@onready var area = $Area2D
@onready var base = $BubbleBase as BubbleBase

func _ready() -> void:
	original_position = global_position
	add_to_group("Bubble")
	area.add_to_group("Bubble")
	
	if Pushable:
		add_to_group("Pushable")
		area.add_to_group("Pushable")
		(base.AnimatedBubble as SingleBubble).color = COLOR_PUSHABLE
	if Breakable:
		add_to_group("Breakable")
		area.add_to_group("Breakable")
		(base.AnimatedBubble as SingleBubble).color = COLOR_POPABLE
	
	if Pushable and Breakable:
		(base.AnimatedBubble as SingleBubble).color = COLOR_BOTH
		
	
	
func pop():
	original_collision_mask = collision_mask
	original_collision_layer = collision_layer
	collision_mask = 0
	collision_layer = 0
	if multiplayer.is_server():
		base.pop()
		Utils.set_timeout(func():
			respawn.rpc()
		, 7.0)

@rpc('authority', 'call_local', 'reliable')
func respawn():
	global_position = original_position
	base.AnimatedBubble.grow = true
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		touching_player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		touching_player = null
		base.AnimatedBubble.squish_status = 0.0

func _process(_delta: float) -> void:
	if (touching_player):
		var direction = (touching_player.global_position - global_position).normalized()
		base.AnimatedBubble.squish_origin = Vector3(direction.x, direction.y, 0)
		base.AnimatedBubble.squish_status = 0.5
