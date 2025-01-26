extends Node2D
class_name BubbleBase

@export var grow_origin: Vector3 = Vector3(0.0, 1.0, 0.0):
	set(value):
		grow_origin = value
		if AnimatedBubble:
			AnimatedBubble.grow_origin = grow_origin
@export var stay_small: bool = false

var playing_move = false
var playing_move_time = 0.0
var reset_move = false
var reset_squish_status = 0.0

@onready var AnimatedBubble = $AnimatedBubble

func _ready() -> void:
	AnimatedBubble.pop_status = 0.0
	if stay_small:
		AnimatedBubble.grow = false
		AnimatedBubble.grow_origin = grow_origin
		AnimatedBubble.grow_status = 0.7
	else:
		AnimatedBubble.grow = true
		AnimatedBubble.grow_origin = Vector3.ZERO

func pop():
	if !multiplayer.is_server():
		return
	playAnimation.rpc('pop')
	
func explode():
	if !multiplayer.is_server():
		return
	#var dir = Vector3(direction.x, direction.y, 0)
	#AnimatedBubble.squish_origin = dir.normalized()
	playAnimation.rpc('explode')
	pass
	
func bounce(direction: Vector2, _speed = 1.0):
	if !multiplayer.is_server():
		return
	var dir = Vector3(direction.x, direction.y, 0)
	AnimatedBubble.squish_origin = dir.normalized()
	playAnimation.rpc('bounce')
	pass
	
func squish(direction: Vector2, _speed = 1.0):
	if !multiplayer.is_server():
		return
	var dir = Vector3(direction.x, direction.y, 0)
	playAnimation.rpc('move', dir.normalized())
	

@rpc("authority", "call_local", "reliable")
func playAnimation(animation: String, origin: Vector3 = Vector3.ZERO):
	var ap = AnimatedBubble.get_child(0) as AnimationPlayer
	if (animation == 'move'):
		AnimatedBubble.squish_origin = origin
		playing_move = true
		playing_move_time = 0.0
	ap.play(animation)

func _process(delta: float) -> void:
	if playing_move:
		playing_move_time += delta
		if playing_move_time > 0.3:
			playing_move = false
			playing_move_time = 0.0
			reset_move = true
			reset_squish_status = AnimatedBubble.squish_status
			var ap = AnimatedBubble.get_child(0) as AnimationPlayer
			ap.stop()
			AnimatedBubble.squish_status = reset_squish_status
	if reset_move:
		playing_move_time += delta
		AnimatedBubble.squish_status = lerp(reset_squish_status, 0.0, playing_move_time / 0.2)
		if playing_move_time > 0.2:
			reset_move = false
