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
var PushVelocity = 750

var shouldBounce = Vector2.ZERO

@onready var characterAnimationSprite := $Sprite2D

func _ready() -> void:
	add_to_group("Player")


func _process(_delta: float) -> void:
	if remoteDirection == 0:
		characterAnimationSprite.pause()
	else:
		characterAnimationSprite.play()

	if id == multiplayer.get_unique_id():
		if Input.is_action_just_pressed('skill1'):
			activeAction = '1'
			callAction.rpc('startSkill', ['1', getGlobalMousePos(), id])
		if Input.is_action_just_pressed('skill2'):
			activeAction = '2'
			callAction.rpc('startSkill', ['2', getGlobalMousePos(), id])
		if Input.is_action_just_pressed('skill3'):
			activeAction = '3'
			callAction.rpc('startSkill', ['3', getGlobalMousePos(), id])
		if Input.is_action_just_released('skill1'):
			activeAction = null
			callAction.rpc('endSkill', ['1', getGlobalMousePos(), id])
		if Input.is_action_just_released('skill2'):
			activeAction = null
			callAction.rpc('endSkill', ['2', getGlobalMousePos(), id])
		if Input.is_action_just_released('skill3'):
			activeAction = null
			callAction.rpc('endSkill', ['3', getGlobalMousePos(), id])

		if (activeAction != null):
			callAction.rpc('updateSkill', [activeAction, getGlobalMousePos(), id])
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

func trigger_push(direction: Vector2):
	if id == multiplayer.get_unique_id():
		callAction.rpc('pushed', ['1', direction, id])
		

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		currentMousePosition = event.position
	

@rpc('any_peer', 'call_local', 'unreliable')
func setRemoteDirection(direction):
	if multiplayer && multiplayer.is_server():
		remoteDirection = direction


@rpc('any_peer', 'call_local', 'reliable')
func callAction(action: String, parameters):
	# check if parameters is type bool
	if typeof(parameters) == TYPE_BOOL or (parameters[2] == id and multiplayer.is_server()):
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
		'pushed':
			remotePush(parameters[0], parameters[1])


func doTheRayCast(origin: Vector2, target: Vector2, _mask = 1 | 2 | 4 | 8, length = 0.0):
	if (!rayCaster):
		return null
	var rayDirection = target - origin
	if length > 0.0:
		rayDirection = rayDirection.normalized() * length
	# rayCaster.collision_mask = mask
	rayCaster.target_position = rayDirection
	rayCaster.force_raycast_update()
	return rayCaster.get_collider()

func remotePush(_skill: String, _target: Vector2):
	shouldBounce = _target * PushVelocity

func startSkill(_skill: String, _target: Vector2):
	pass
	
func endSkill(_skill: String, _target: Vector2):
	pass
	
func updateSkill(_skill: String, _target: Vector2):
	pass
	
func getGlobalMousePos(pos = currentMousePosition):
	return get_global_transform_with_canvas().affine_inverse() * pos

func getGlobalCharPos():
	return get_global_transform().affine_inverse() * global_position
