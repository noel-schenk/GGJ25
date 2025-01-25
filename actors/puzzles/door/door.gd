extends Node2D

@export var buttons: Array[ButtonActor] = []

@onready var mesh = $Mesh
@onready var animationPlayer = $AnimationPlayer

var opened = false

func _ready():
	for button in buttons:
		if button:
			button.open.connect(openDoor)
			button.close.connect(closeDoor)

func openDoor():
	if hasPlayers() && !opened:
		opened = true
		animationPlayer.play("openDoor")

func	 closeDoor():
	if !hasPlayers() && opened:
		opened = false
		animationPlayer.play_backwards('openDoor')

func hasPlayers():
	var found = false
	for button in buttons:
		if button:
			found = found or button.isPlayerInArea()
	return found
