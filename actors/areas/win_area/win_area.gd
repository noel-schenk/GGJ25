extends Node2D

@export var both = false
@onready var area = $Area2D

@export_multiline var HeadlineText: String = ''
@export_multiline var BodyText: String = ''

var Message = preload("res://ui/Message.tscn")

var entered = [];

func _ready():
	area.body_entered.connect(onEnter)
	
func onEnter(body: Node2D):
	if !multiplayer.is_server():
		return
		
	if body.is_in_group('Player') and body not in entered:
		entered.push_back(body)
	else:
		return
		
	if both and entered.size() >= 2:
		Game.getGame().nextLevel()
		return
		
	if !both and entered.size() >= 1:
		# Game.getGame().nextLevel()
		if multiplayer.is_server():
			showWin.rpc()
		return

@rpc('authority', 'call_local', 'reliable')
func showWin():
	if (!HeadlineText or !BodyText):
		Game.getGame().nextLevel()
		return
		
	var message = Message.instantiate()
	message.HeadlineText = HeadlineText
	message.BodyText = BodyText
	add_child(message)

	if multiplayer.is_server():
		Utils.set_timeout(func():
			Game.getGame().nextLevel()
		, 2.0)
