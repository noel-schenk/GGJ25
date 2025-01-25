extends MainCharacter
class_name KnightCharacter

func _ready() -> void:
	super._ready()
	add_to_group("Knight")
	super._ready()

func _process(delta: float):
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func startSkill(skill: String, target: Vector2):
	match skill:
		'1':
			if State.getKnightSkillLevel() < 1:
				return
			var collisionElement = doTheRayCast(getGlobalCharPos(), target)
			if collisionElement and collisionElement.is_in_group('Bubble') and collisionElement.is_in_group('Breakable'):
				var bubble = collisionElement as BubbleNormal
				bubble.pop()



func _draw() -> void:
	if multiplayer.get_unique_id() == id:
		draw_line(getGlobalCharPos(), getGlobalMousePos(), Color.AQUA)
