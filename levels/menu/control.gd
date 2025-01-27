extends Control

@export var foam_bubbles: SingleBubble

var _animation_bubbles: bool = false
var _animation_bubbles_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animation_bubbles = true
	_animation_bubbles_time = 0.0
	foam_bubbles.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _animation_bubbles:
		_animation_bubbles_time += delta
		if _animation_bubbles_time < 1.5:
			if _animation_bubbles_time > 0.5:
				foam_bubbles.grow_status = 1.5 - _animation_bubbles_time
		else:
			_animation_bubbles = false
