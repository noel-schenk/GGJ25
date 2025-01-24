extends Node2D
class_name Game

var PlayerClass = preload('res://actors/main/MainCharacter.tscn')

static var instance: Game
static func getGame():
	return instance
	
@export var currentLevel: String = ''

@onready var replicator = $MultiplayerSynchronizer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func getSpawnPoints():
	return get_node('Map').find_children("SpawnPoint")

func getPlayers():
	return get_node('"Player"').get_children()

func getPlayer(i: int):
	return get_node('"Player"').get_child(i)

func getMap():
	return get_node('Map')

func getPlayerId():
	return multiplayer.get_unique_id()

func getLocalPlayer():
	return getPlayer(getPlayerId())

func loadLevel(_currentLevel: String):
	if !multiplayer.is_server():
		return
	if currentLevel == _currentLevel:
		return
	if not _currentLevel or _currentLevel != '':
		return
	currentLevel = _currentLevel

	#load level
	var level = load('res://levels/' + currentLevel + '.tscn')
	
	#remove old map
	var children = get_node('Map').get_children()
	for child in children:
		child.queue_free()
	var newLevel = level.instance()
	get_node('Map').add_child.call_deferred(newLevel)

func spawnPlayers():
	var spawnPoints = getSpawnPoints()
	var peers = multiplayer.get_peers()
	for peer in peers:
		var id = peer.get_id()
		#spawn player
		var player = PlayerClass.instance()
		player.id = id
		player.position = spawnPoints[id].position
		get_node('Player').add_child(player)
