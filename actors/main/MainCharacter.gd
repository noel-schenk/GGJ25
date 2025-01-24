extends CharacterBody2D
class_name MainCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@export var id: int = 0
@export var remoteDirection: float = 0

func _ready() -> void:
	add_to_group("Player")

func _process(delta: float) -> void:
	if multiplayer.is_server():
		return
	if id == multiplayer.get_unique_id():
		var direction := Input.get_axis("ui_left", "ui_right")
		setRemoteDirection.rpc(direction)
		return

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if id == multiplayer.get_unique_id():
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if remoteDirection:
			velocity.x = remoteDirection * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()

@rpc('any_peer', 'call_remote', 'unreliable')
func setRemoteDirection(direction):
	if multiplayer.is_server():
		remoteDirection = direction
	pass
