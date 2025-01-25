extends Node2D

@onready var area = $Area2D

func _ready() -> void:
	add_to_group("Bubble")
	area.body_entered.connect(onEntered)
	

func onEntered(body):
	if body.is_in_group('Player'):
		# teleport the player to the other bubble if exists
		var bubbles = Game.getGame().getBubbleContainer().find_children('Bubble Teleport*', '', false, false)
		if (bubbles.size() == 2):
			var bubble = bubbles[0] if bubbles[0] != self else bubbles[1]
			body.set_global_position(bubble.get_global_position())
			bubbles[0].queue_free()
			bubbles[1].queue_free()
		else:
			print_debug('no bubble to teleport to')
