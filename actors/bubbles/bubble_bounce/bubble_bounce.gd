@tool
extends RigidBody2D
class_name BubbleBounce

@export var base: BubbleBase
@export var Pushable = true
@export var Breakable = true
@export var grow_origin: Vector3 = Vector3(0.0, 1.0, 0.0):
	set(value):
		grow_origin = value
		if base:
			base.grow_origin = grow_origin

var COLOR_PUSHABLE = Color('#00690a')
var COLOR_POPABLE = Color('#00690a')
var COLOR_BOTH = Color('#00690a')

var original_position = Vector2.ZERO
var original_collision_mask = 0
var original_collision_layer = 0
var touching_player: Node2D = null

@onready var area = $Area2D


func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)
	base.grow_origin = grow_origin
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
		
	var buble = (base.animated_bubble as SingleBubble)
	buble.min_transparency += 0.1
	
	
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
		
		
func explode():
	original_collision_mask = collision_mask
	original_collision_layer = collision_layer
	collision_mask = 0
	collision_layer = 0
	if multiplayer.is_server():
		base.explode()
		Utils.set_timeout(func():
			respawn.rpc()
		, 2.0)
		
	
@rpc('authority', 'call_local', 'reliable')
func respawn():
	base.stay_small = true
	base.grow_origin = grow_origin
	global_position = original_position
	base.animated_bubble.grow_status = 0.7
	base.animated_bubble.pop_status = 0.0
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		var player = body as MainCharacter
		player.trigger_push((body.global_position - global_position).normalized())
		explode()
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		touching_player = null
		base.animated_bubble.squish_status = 0.0

func _process(_delta: float) -> void:
	if (touching_player):
		var direction = (touching_player.global_position - global_position).normalized()
		base.animated_bubble.squish_origin = Vector3(direction.x, direction.y, 0)
		base.animated_bubble.squish_status = 0.5
