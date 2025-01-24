extends Node

func _ready() -> void:
	initWindow()

func initWindow():
	var screen_size = DisplayServer.screen_get_size()
	var window_size = Vector2i(screen_size.x / 2, screen_size.y / 2)
	get_viewport().size = window_size
	get_window().position = get_window().position - Vector2i(0, -120)
	#get_window().position = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
