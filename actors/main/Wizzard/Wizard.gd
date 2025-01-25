extends MainCharacter
class_name WizardCharacter

var collisionElement = null
@onready var rayCaster = $RayCast2D

func _ready() -> void:
	#if multiplayer.get_unique_id() == id:
		#rayCaster.enabled = true
	add_to_group("Wizard")
	super._ready()

func _process(delta: float):
	rayCaster.target_position = getGlobalMousePos() - getGlobalCharPos()
	if rayCaster.is_colliding():
		collisionElement = rayCaster.get_collider()
		print_debug(collisionElement)
	queue_redraw()
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	
func updateSkill(skill: String, target: Vector2):
	match skill:
		'1':
			var rayDirection = target - getGlobalCharPos()
			rayCaster.target_position = rayDirection
			rayCaster.force_raycast_update()
			collisionElement = rayCaster.get_collider()
			
			if collisionElement:
				collisionElement.apply_central_impulse((rayDirection).normalized() * -10)
				

func _draw() -> void:
	if multiplayer.get_unique_id() == id:
		draw_line(getGlobalCharPos(), getGlobalMousePos(), Color.AQUA)
