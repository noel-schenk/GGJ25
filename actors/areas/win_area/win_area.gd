extends Node2D

@export var both = false
@onready var area = $Area2D
@onready var particles: GPUParticles2D = $GPUParticles2D

@export_multiline var HeadlineText: String = ''
@export_multiline var BodyText: String = ''

var Message = preload("res://ui/Message.tscn")

var entered = [];

func _ready():
	var material = particles.process_material as ParticleProcessMaterial
	var scale = global_scale.x / log(global_scale.x)
	
	material.scale_min = material.scale_min * scale
	material.scale_max = material.scale_max * scale
	material.initial_velocity_max = material.initial_velocity_max * scale
	material.initial_velocity_min = material.initial_velocity_min * scale
	
	area.body_entered.connect(onEnter)
	
func onEnter(body: Node2D):
	if !multiplayer.is_server():
		return
		
	if body.is_in_group('Player') and body not in entered:
		entered.push_back(body)
	else:
		return
		
	if both and entered.size() >= 2:
		# Game.getGame().nextLevel()
		if multiplayer.is_server():
			showWin.rpc()
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
