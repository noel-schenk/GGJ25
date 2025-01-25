extends Node2D
class_name BubbleBase

@onready var AnimatedBubble = $AnimatedBubble
@onready var Prewiew = $Preview as Sprite2D

func _ready() -> void:
	AnimatedBubble.pop_status = 0.0
	AnimatedBubble.grow = true
	AnimatedBubble.grow_origin = Vector3.ZERO
	Prewiew.visible = false

func pop():
	if !multiplayer.is_server():
		return
	playAnimation.rpc('pop')
	
func bounce(direction: Vector2, speed = 1.0):
	if !multiplayer.is_server():
		return
	var dir = Vector3(direction.x, direction.y, 0)
	AnimatedBubble.squish_origin = dir.normalized()
	playAnimation.rpc('bounce')
	pass
	
func squish(direction: Vector2, speed = 1.0):
	if !multiplayer.is_server():
		return
	var dir = Vector3(direction.x, direction.y, 0)
	AnimatedBubble.squish_origin = dir.normalized()
	playAnimation.rpc('move', dir.normalized())
	

@rpc("authority", "call_local", "reliable")
func playAnimation(animation: String, origin: Vector3 = Vector3.ZERO):
	var ap = AnimatedBubble.get_child(0) as AnimationPlayer
	if (animation == 'move'):
		AnimatedBubble.squish_origin = origin
	ap.play(animation)
