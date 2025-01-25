extends Node2D

@onready var area = $Area2D

func _ready():
	area.body_entered.connect(onEnter)
	
func onEnter(body: Node2D):
	State.nextLevel()
