extends Node2D
class_name ButtonActor

signal open
signal close
@onready var trigger: Area2D = $Trigger

func _ready():
	trigger.body_entered.connect(onEntered)
	trigger.body_exited.connect(onExited)

func onEntered(body):
	open.emit()
	
func onExited(_body):
	close.emit()

func isPlayerInArea():
	var bodies = trigger.get_overlapping_bodies()
	var found = false
	for body in bodies:
		found = found or body.is_in_group('Player')
	return found
