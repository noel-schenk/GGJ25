@tool
extends RigidBody2D
class_name BubbleNormal

@export var base: BubbleBase
@export var area: Area2D:
	set(value):
		area = value
		if Pushable:
			area.add_to_group("Pushable")
		else:
			area.remove_from_group("Pushable")
		if Breakable:
			area.add_to_group("Breakable")
		else:
			area.remove_from_group("Breakable")
@export var Pushable = true:
	set(value):
		Pushable = value
		if value:
			add_to_group("Pushable")
			if area:
				area.add_to_group("Pushable")
		else:
			remove_from_group("Pushable")
			if area:
				area.remove_from_group("Pushable")
		if base and base.animated_bubble:
			if Pushable and Breakable:
				(base.animated_bubble as SingleBubble).color = COLOR_BOTH
			elif Breakable:
				(base.animated_bubble as SingleBubble).color = COLOR_POPABLE
			elif Pushable:
				(base.animated_bubble as SingleBubble).color = COLOR_PUSHABLE
			else:
				(base.animated_bubble as SingleBubble).color = Color.WHITE
			
@export var Breakable = true:
	set(value):
		Breakable = value
		if value:
			add_to_group("Breakable")
			if area:
				area.add_to_group("Breakable")
		else:
			remove_from_group("Breakable")
			if area:
				area.remove_from_group("Breakable")
		if base and base.animated_bubble:
			if Pushable and Breakable:
				(base.animated_bubble as SingleBubble).color = COLOR_BOTH
			elif Breakable:
				(base.animated_bubble as SingleBubble).color = COLOR_POPABLE
			elif Pushable:
				(base.animated_bubble as SingleBubble).color = COLOR_PUSHABLE
			else:
				(base.animated_bubble as SingleBubble).color = Color.WHITE


var COLOR_PUSHABLE = Color.BLUE
var COLOR_POPABLE = Color.RED
var COLOR_BOTH = Color.BLUE_VIOLET

var original_position = Vector2.ZERO
var original_collision_mask = 0
var original_collision_layer = 0
var touching_player: Node2D = null

func _ready() -> void:
	original_collision_mask = collision_mask
	original_collision_layer = collision_layer
	original_position = global_position
	add_to_group("Bubble")
	area.add_to_group("Bubble")
	
	if Pushable:
		add_to_group("Pushable")
		area.add_to_group("Pushable")
		(base.animated_bubble as SingleBubble).color = COLOR_PUSHABLE
	if Breakable:
		add_to_group("Breakable")
		area.add_to_group("Breakable")
		(base.animated_bubble as SingleBubble).color = COLOR_POPABLE
	
	if Pushable and Breakable:
		(base.animated_bubble as SingleBubble).color = COLOR_BOTH
		
	
func pop():
	collision_mask = 0
	collision_layer = 0
	area.collision_mask = 0
	area.collision_layer = 0
	if multiplayer.is_server():
		if base.popped:
			return
		base.pop()
		Utils.set_timeout(func():
			respawn.rpc()
		, 7.0)

@rpc('authority', 'call_local', 'reliable')
func respawn():
	global_position = original_position
	base.respawn()
	base.animated_bubble.grow = true
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer
	area.collision_mask = original_collision_mask
	area.collision_layer = original_collision_layer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		touching_player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		touching_player = null
		base.animated_bubble.squish_status = 0.0
		if base.popped:
			return
		var animation_payer = base.animated_bubble.get_child(0) as AnimationPlayer
		if (animation_payer):
			animation_payer.stop()
			animation_payer.play("bounce")
			animation_payer.seek(0.2393, true)

func _process(_delta: float) -> void:
	if touching_player and !base.popped:
		var direction = (touching_player.global_position - global_position).normalized()
		base.animated_bubble.squish_origin = Vector3(direction.x, direction.y, 0)
		base.animated_bubble.squish_status = 0.5
