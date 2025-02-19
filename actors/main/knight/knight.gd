extends MainCharacter
class_name KnightCharacter

var FOAM_BUBBLE = preload('res://actors/bubbles/bubble_foam/bubble_foam.tscn')
var ziel = preload('res://assets/sprites/Fadenkreuz.png')

@onready var spriteAnimation: AnimatedSprite2D = $Sprite2D

var KnightAttackHitRange = 75
var KnightBounceHitRange = 100
var KnightbounceVelocity = 750

func _ready() -> void:
	super._ready()
	add_to_group("Knight")
	super._ready()

func _process(delta: float):
	queue_redraw()
	super._process(delta)
	
	if !multiplayer.is_server():
		return
	if is_on_floor():
		spriteAnimation.set_animation('default')
	else:
		spriteAnimation.set_animation('jump')
	
func _physics_process(delta: float) -> void:
	var direction: float = remoteDirection
	if (direction > 0):
		sprite.scale.x = -abs(sprite.scale.x)
	if (direction < 0):
		sprite.scale.x = abs(sprite.scale.x)
	
	if !multiplayer.is_server():
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if remoteJumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction && floor_snap_length != 0.0:
		velocity.x = direction * SPEED
	else:
		if floor_snap_length != 0.0:
			velocity.x = move_toward(velocity.x, 0, SPEED * (1.0 if is_on_floor() else 0.5))
	
	# Handle bouncing.
	if shouldBounce:
		velocity = shouldBounce
		shouldBounce = Vector2.ZERO
		floor_snap_length = 0
		Utils.set_timeout(func():
			floor_snap_length = 1.0
		, 0.5)
		
		
	move_and_slide()
		
	
func startSkill(skill: String, target: Vector2):
	match skill:
		'1':
			if State.getKnightSkillLevel() < 1:
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), target, 1 | 2 | 4 | 8, KnightAttackHitRange)
			if collisionElement is Area2D:
				collisionElement = collisionElement.get_parent()
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Breakable'):
				#var bubble = collisionElement as BubbleNormal
				collisionElement.pop()
		'2':
			if State.getKnightSkillLevel() < 2 and !is_on_floor():
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), getGlobalCharPos() + Vector2(0, 100), 1 | 2 | 4 | 8, KnightBounceHitRange)
			if collisionElement is Area2D:
				collisionElement = collisionElement.get_parent()
			if collisionElement and collisionElement.is_in_group('Bubble'):
				shouldBounce = getNormalizedDirection() * KnightbounceVelocity
		'3':
			if State.getKnightSkillLevel() < 3:
				return
			var container = Game.getGame().getBubbleContainer()
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement is Area2D:
				collisionElement = collisionElement.get_parent()
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Breakable'):
				var bubble = collisionElement as BubbleNormal
				if bubble:
					bubble.pop()
					var foam_bubble = FOAM_BUBBLE.instantiate()
					container.add_child(foam_bubble, true)
					foam_bubble.set_global_position(bubble.global_position)
					foam_bubble.spawn()

func getNormalizedDirection():
	return (getGlobalMousePos() - getGlobalCharPos()).normalized()

func _draw() -> void:
	if multiplayer.get_unique_id() == id:
		var size = 24
		var target = getNormalizedDirection() * KnightAttackHitRange + getGlobalCharPos()
		draw_texture_rect_region(ziel, Rect2(target - Vector2(size / 2, size / 2), Vector2(size, size)), Rect2(Vector2(0, 0), Vector2(64, 64)))
