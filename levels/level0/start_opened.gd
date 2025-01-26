extends Node

const activated_text = "Something opened at the start of the level, check it out on the right!"

@export var popup: TutorialPopup
@export var start_popup: TutorialPopup
@export var hint_arrow_one: Node2D
@export var hint_arrow_two: Node2D

@export var trigger_button: ButtonActor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_button.open.connect(change_text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func change_text():
	if !trigger_button.isPlayerInArea():
		return
	popup.text = activated_text
	start_popup.visible = false
	hint_arrow_one.rotation = 0.0
	hint_arrow_two.visible = false
