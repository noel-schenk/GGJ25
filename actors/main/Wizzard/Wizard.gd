extends MainCharacter
class_name WizardCharacter

func _ready() -> void:
	add_to_group("Wizard")
	super._ready()

func _process(delta: float):
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func performAction(action: String, parameters):
	super.performAction(action, parameters)
	match action:
		'push':
			pass
		_:
			pass
