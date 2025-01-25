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

func performSkill(skill: String, target: Vector2):
	match skill:
		'1':
			if State.getKnightSkillLevel() < 1:
				return
			
