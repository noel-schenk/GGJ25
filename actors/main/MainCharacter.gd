extends CharacterBody2D
class_name MainCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@export var id: int = 0
@export var remoteDirection = 0.0
@export var remoteJumping = false
@onready var camera = $Camera2D
@onready var sprite = $Sprite2D

var currentCamera = null;

func _ready() -> void:
	add_to_group("Player")

func _process(_delta: float) -> void:
	if id == multiplayer.get_unique_id():
		callAction.rpc('jump', Input.is_action_just_pressed("ui_accept"))
		setRemoteDirection.rpc(Input.get_axis("ui_left", "ui_right"))
		if(currentCamera != camera):
			camera.enabled = true
			currentCamera = camera;
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var isJumping = remoteJumping
	if isJumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = remoteDirection
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if (direction > 0):
		sprite.scale.x = -abs(sprite.scale.x)
	if (direction < 0):
		sprite.scale.x = abs(sprite.scale.x)
	
	move_and_slide()
	

@rpc('any_peer', 'call_local', 'unreliable')
func setRemoteDirection(direction):
	if multiplayer.is_server():
		remoteDirection = direction

@rpc('any_peer', 'call_local', 'reliable')
func callAction(action: String, parameters):
	if multiplayer.is_server():
		performAction(action, parameters)

func performAction(action: String, parameters):
	match action:
		'jump':
			remoteJumping = bool(parameters)
