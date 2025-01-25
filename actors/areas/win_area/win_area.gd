extends Node2D

@export var both = false
@onready var area = $Area2D

var entered = [];

func _ready():
	area.body_entered.connect(onEnter)
	
func onEnter(body: Node2D):
	if !multiplayer.is_server():
		return
		
	if body.is_in_group('Player') and body not in entered:
		entered.push_back(body)
		
	if both and entered.size() < 2:
		return
	
	State.nextLevel()
