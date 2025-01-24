extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func getSpawnPoints():
	return get_node('Map').find_children("SpawnPoint")

func getPlayers():
	return get_node('"Player"').get_children()

func getPlayer(i: int):
	return get_node('"Player"').get_child(i)

func getMap():
	return get_node('Map')