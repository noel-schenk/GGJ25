extends Node2D

@onready var area = $Area2D as Area2D
@onready var base = $BubbleBase as BubbleBase
@onready var innerParticles = $InnerParticles as GPUParticles2D
@onready var borderParticles = $BorderParticles as GPUParticles2D

func _ready() -> void:
	add_to_group("Bubble")
	area.body_entered.connect(onEntered)
	
func teleported():
	area.collision_mask = 0
	innerParticles.emitting = false
	borderParticles.emitting = false
	if multiplayer.is_server():
		base.pop()
		Utils.set_timeout(func():
			queue_free()
		, 1.0)

func onEntered(body):
	if body.is_in_group('Player'):
		# teleport the player to the other bubble if exists
		var bubbles = Game.getGame().find_children('Bubble Teleport*', '', true, false)
		if (bubbles.size() == 2):
			var bubble = bubbles[0] if bubbles[0] != self else bubbles[1]
			body.set_global_position(bubble.get_global_position())
			bubbles[0].teleported()
			bubbles[1].teleported()
		else:
			print_debug('no bubble to teleport to')
