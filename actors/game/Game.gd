extends Node2D
class_name Game

var PlayerClass = preload('res://actors/main/MainCharacter.tscn')
var KnightClass = preload('res://actors/main/knight/Knight.tscn')
var WizardClass = preload('res://actors/main/Wizzard/Wizard.tscn')

static var instance: Game
static func getGame():
	return instance as Game
	
@export var currentLevel: String = ''

@onready var mapSpawner = $MapSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance = self
	multiplayer.peer_connected.connect(_on_connected)
	multiplayer.server_disconnected.connect(_on_disconnected)
	multiplayer.peer_disconnected.connect(_on_server_disconnected)
	
func _on_disconnected():
	endGame();
	
func _on_server_disconnected(_id):
	if not multiplayer.is_server():
		return
	if multiplayer.get_peers().size() == 1:
		return ;
	reset();
	endGame();
	

func _on_connected(_peerInfo):
	if not multiplayer.is_server():
		return
	
	if multiplayer.get_peers().size() > 1:
		multiplayer.multiplayer_peer.disconnect_peer(_peerInfo)
	
	print_debug('connected')
	startGame.rpc()
	startGame()
	# loadLevel('res://levels/level1/Level1.tscn')
	# loadLevel('res://levels/level4/level4.tscn')
	# loadLevel('res://levels/level0/level0.tscn')
	loadLevel(State.getCurrentLevel())
	spawnPlayers.call_deferred()

@rpc
func startGame():
	get_node('../MenuLevel/Control/CanvasLayer').visible = false

func endGame():
	get_node('../MenuLevel/Control/CanvasLayer').visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func getSpawnPoints():
	return get_node('Map').find_children('SpawnPoint*', '', true, false)

func getPlayers():
	return get_node('Player').get_children()

func getPlayer(i: int):
	return get_node('Player').get_child(i)

func getMap():
	return get_node('Map')
	
func getBubbleContainer():
	return get_node('Bubbles')

func getPlayerId():
	return multiplayer.get_unique_id()

func getLocalPlayer():
	return getPlayer(getPlayerId())

func reset():
	# clear players and map
	var players = getPlayers()
	for player in players:
		player.queue_free()
	var map = getMap()
	var children = map.get_children()
	for child in children:
		child.queue_free()
	pass

func loadLevel(_currentLevel: String):
	print_debug(_currentLevel)
	if !multiplayer.is_server():
		return
	if currentLevel == _currentLevel:
		return
	var level = load(_currentLevel)
	if not level:
		return
	currentLevel = _currentLevel

	var newLevel = level.instantiate()
	get_node('Map').add_child.call_deferred(newLevel)

func spawnPlayers():
	var spawnPoints = getSpawnPoints()
	var i = 0
	var peers = multiplayer.get_peers()
	peers.push_back(multiplayer.get_unique_id())
	for peer in peers:
		var id = peer
		var player = KnightClass.instantiate() if spawnPoints[i].isKnight else WizardClass.instantiate()
		player.id = id
		player.position = spawnPoints[i].position
		i += 1
		player.name = player.name + '_' + str(id)
		get_node('Player').add_child(player)

@rpc("authority", "call_local", "reliable")
func cleanup():
	#remove bubbles
	var bubbles = getBubbleContainer().get_children()
	for bubble in bubbles:
		bubble.queue_free()

	#remove old players
	var players = getPlayers()
	for player in players:
		player.queue_free()

	#remove old map
	var children = get_node('Map').get_children()
	for child in children:
		child.queue_free()

	#reset current level
	currentLevel = ''
