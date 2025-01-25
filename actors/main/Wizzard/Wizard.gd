extends MainCharacter
class_name WizardCharacter

var PULL_FORCE = 10

func _ready() -> void:
	add_to_group("Wizard")
	super._ready()

func _process(delta: float):
	queue_redraw()
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	
func updateSkill(skill: String, target: Vector2):
	match skill:
		'1':
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Pushable'):
				collisionElement.apply_central_impulse((target - getGlobalCharPos()).normalized() * -PULL_FORCE)
				
		'2':
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement:
				collisionElement.apply_central_impulse((target - getGlobalCharPos()).normalized() * PULL_FORCE)
				

func _draw() -> void:
	if multiplayer.get_unique_id() == id:
		draw_line(getGlobalCharPos(), getGlobalMousePos(), Color.AQUA)
