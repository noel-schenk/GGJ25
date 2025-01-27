extends Node

@export var start_popup: TutorialPopup
@export var hint_arrow_one: Node2D
@export var hint_arrow_two: Node2D
@export var hint_arrow_three: Node2D

@export var trigger_button: ButtonActor


func _ready() -> void:
	trigger_button.open.connect(change_text)

func change_text():
	if !trigger_button.isPlayerInArea():
		return
	start_popup.visible = false
	hint_arrow_one.rotation = 0.0
	hint_arrow_two.visible = false
	hint_arrow_three.visible = true
