extends Node2D


@export var KillGroup = ''
@export var RespawnPlace: Node2D = null
@onready var area = $Area2D

func _ready():
	area.body_entered.connect(onEnter)
	
func onEnter(body: Node2D):
	if body.is_in_group(KillGroup):
		body.global_position = RespawnPlace.global_position
