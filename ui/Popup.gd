extends Node2D
class_name TutorialPopup

@onready var container = $MarginContainer
@onready var label = $MarginContainer/MarginContainer/Label
@onready var trigger = $Area2D

@export_multiline var text = ''

func _ready():
	container.visible = false
	label.text = text
	trigger.body_entered.connect(onEntered)
	trigger.body_exited.connect(onExited)
	
func onEntered(body):
	if isPlayerInArea():
		container.visible = true
	
func onExited(_body):
	if !isPlayerInArea():
		container.visible = false

func isPlayerInArea():
	var bodies = trigger.get_overlapping_bodies()
	var found = false
	for body in bodies:
		found = found or body.is_in_group('Player')
	return found
