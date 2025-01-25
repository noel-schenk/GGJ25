extends MainCharacter
class_name WizardCharacter

var PULL_FORCE = 15
var TELEPORT_BUBBLE = preload('res://actors/bubbles/bubble_teleport/bubble_teleport.tscn')
@onready var pullParticles = $GPUParticles2D
@onready var staff = $Sprite2D/staff

func _ready() -> void:
	super._ready()
	add_to_group("Wizard")
	super._ready()


func _process(delta: float):
	queue_redraw()
	updateWand()
	super._process(delta)
	
func updateWand():
	if State.getWizardSkillLevel() >= 1:
		staff.visible = true
	else:
		staff.visible = false
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	
func updateSkill(skill: String, target: Vector2):
	match skill:
		'1':
			if State.getWizardSkillLevel() < 0:
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Pushable'):
				collisionElement.apply_central_impulse((target - getGlobalCharPos()).normalized() * -PULL_FORCE)
				placePullParticle(target)
				var base = collisionElement.base as BubbleBase
				base.squish((target - getGlobalCharPos()))
		'2':
			if State.getWizardSkillLevel() < 0:
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Pushable'):
				collisionElement.apply_central_impulse((target - getGlobalCharPos()).normalized() * PULL_FORCE)
				placePullParticle(target, true)
				var base = collisionElement.base as BubbleBase
				base.squish(-(target - getGlobalCharPos()))


func placePullParticle(target: Vector2, flip = false):
	pullParticles.emitting = true
	var pos = global_position + (target - getGlobalCharPos())
	pullParticles.global_position = pos
	pullParticles.look_at(global_position)
	if (flip):
		pullParticles.rotation = pullParticles.rotation + PI
	Utils.set_timeout(func():
		pullParticles.emitting = false
	, 0.2)


func startSkill(skill: String, target: Vector2):
	match skill:
		'3':
			if State.getWizardSkillLevel() > 1:
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement:
				return;
			var container = Game.getGame().getBubbleContainer()
			var teleportBubbles = container.find_children('Bubble Teleport*', '', false, false)
			if (teleportBubbles.size() > 1):
				print_debug('remove teleport bubble')
				teleportBubbles[0].queue_free()
			var bubble = TELEPORT_BUBBLE.instantiate()
			container.add_child(bubble, true)
			bubble.set_global_position(global_position + target - getGlobalCharPos())
			print_debug('spawned', bubble)


func _draw() -> void:
	if multiplayer.get_unique_id() == id:
		draw_line(getGlobalCharPos(), getGlobalMousePos(), Color.AQUA)
