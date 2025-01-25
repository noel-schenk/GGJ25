extends CharacterBody2D
class_name MainCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@export var id: int = 0
@export var remoteDirection = 0.0
@export var remoteJumping = false
@onready var camera = $Camera2D
@onready var sprite = $Sprite2D
@onready var rayCaster = $RayCast2D

var activeAction = null
var currentCamera = null;
var currentMousePosition = Vector2.ZERO

@onready var characterAnimationSprite := $Sprite2D

func _ready() -> void:
	add_to_group("Player")


func _process(_delta: float) -> void:
	if remoteDirection == 0:
		characterAnimationSprite.pause()
	else:
		characterAnimationSprite.play()

	if id == multiplayer.get_unique_id():
		if (activeAction != null):
			callAction.rpc('updateSkill', [activeAction, getGlobalMousePos()])
		callAction.rpc('jump', Input.is_action_pressed("ui_accept"))
		setRemoteDirection.rpc(Input.get_axis("ui_left", "ui_right"))

		if (currentCamera != camera):
			camera.enabled = true
			currentCamera = camera
	

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
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * (1.0 if is_on_floor() else 0.5))
		
	move_and_slide()
	

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		currentMousePosition = event.position
	elif event is InputEventKey:
		var code = event.as_text_keycode()
		if code in ['1', '2', '3', '4', '5']:
			if code == activeAction and event.is_released():
				activeAction = null
				callAction.rpc('endSkill', [code, getGlobalMousePos()])
			elif code != activeAction and event.is_pressed():
				activeAction = code
				callAction.rpc('startSkill', [code, getGlobalMousePos()])


@rpc('any_peer', 'call_local', 'unreliable')
func setRemoteDirection(direction):
	if multiplayer && multiplayer.is_server():
		remoteDirection = direction


@rpc('any_peer', 'call_local', 'reliable')
func callAction(action: String, parameters):
	if multiplayer.is_server():
		performAction(action, parameters)


func performAction(action: String, parameters):
	match action:
		'jump':
			remoteJumping = bool(parameters)
		'startSkill':
			startSkill(parameters[0], parameters[1])
		'endSkill':
			endSkill(parameters[0], parameters[1])
		'updateSkill':
			updateSkill(parameters[0], parameters[1])


func doTheRayCast(origin: Vector2, target: Vector2, mask = 1 | 2 | 4 | 8, length = 0.0):
	if (!rayCaster):
		return null
	var rayDirection = target - origin
	if length > 0.0:
		rayDirection = rayDirection.normalized() * length
	# rayCaster.collision_mask = mask
	rayCaster.target_position = rayDirection
	rayCaster.force_raycast_update()
	return rayCaster.get_collider()

func startSkill(skill: String, target: Vector2):
	pass
	
func endSkill(skill: String, target: Vector2):
	pass
	
func updateSkill(skill: String, target: Vector2):
	pass
	
func getGlobalMousePos(pos = currentMousePosition):
	return get_global_transform_with_canvas().affine_inverse() * pos

func getGlobalCharPos():
	return get_global_transform().affine_inverse() * global_position
