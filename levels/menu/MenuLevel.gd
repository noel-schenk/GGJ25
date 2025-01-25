extends Node

var args = OS.get_cmdline_args()
var clientOrServer = "client"

@export var mutliplayer_server_node: PackedScene
@export var lobbyUrl := "https://godot-multiplayer-ggj.vercel.app"
@export var projectName := "ggj25"

@onready var host_button := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/host_button
@onready var join_button := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/join_button

@onready var join_input := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/join_input
@onready var generated_join_code_input := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer3/VBoxContainer/generated_join_code_input

@onready var after_connected_animation := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer3/VBoxContainer/Control2/Connected

@onready var level_selector_menubar := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/MenuBar/level_selector
@onready var level_selection_label := $Control/CanvasLayer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/level_selection_label


var lobby_uuid = 0

# Import WebRTC objects
var peer = WebRTCMultiplayerPeer.new()
var connection := WebRTCPeerConnection.new()
var channel: WebRTCDataChannel
var signaling_data = {
	"session_description": {},
	"ice_candidates": []
}

# HTTPRequest nodes for different API calls (to be added to the scene as per requirement)
@onready var http_request_create_offer = HTTPRequest.new()
@onready var http_request_get_offer_details = HTTPRequest.new()
@onready var http_request_create_offer_request = HTTPRequest.new()
@onready var http_request_get_oldest_offer_request = HTTPRequest.new()
@onready var http_request_set_server_exchange = HTTPRequest.new()
@onready var http_request_set_client_exchange = HTTPRequest.new()

func _ready():
	add_child(http_request_create_offer)
	add_child(http_request_get_offer_details)
	add_child(http_request_create_offer_request)
	add_child(http_request_get_oldest_offer_request)
	add_child(http_request_set_server_exchange)
	add_child(http_request_set_client_exchange)

	# Connect HTTPRequest signals for callbacks
	http_request_create_offer.request_completed.connect(_on_create_offer_completed)
	http_request_get_offer_details.request_completed.connect(_on_get_offer_details_completed)
	http_request_create_offer_request.request_completed.connect(_on_create_offer_request_completed)
	http_request_get_oldest_offer_request.request_completed.connect(_on_get_oldest_offer_request_completed)
	http_request_set_server_exchange.request_completed.connect(_on_set_server_exchange_completed)
	http_request_set_client_exchange.request_completed.connect(_on_set_client_exchange_completed)

	host_button.pressed.connect(_on_pressed_host_button)
	join_button.pressed.connect(_on_pressed_join_button)
	
	_on_pressed_host_button()

	level_selector_menubar.id_pressed.connect(_on_id_pressed_level_selector)

func multiplayer_init():
	if (clientOrServer == "server"):
		var error = peer.create_server()
		if error != OK:
			Utils.better_print(["Failed to create server: %s" % str(error)])
			return

	if (clientOrServer == "client"):
		var error = peer.create_client(2)
		if error != OK:
			Utils.better_print(["Failed to create client: %s" % str(error)])
			return

	multiplayer.multiplayer_peer = peer

func multiplayer_init_after_connection_initialize():
	if (clientOrServer == "server"):
		var error = peer.add_peer(connection, 2)
		if error != OK:
			push_error("Failed to add client peer: %s" % str(error))
			return

	if (clientOrServer == "client"):
		var error = peer.add_peer(connection, 1)
		if error != OK:
			push_error("Failed to add server peer: %s" % str(error))
			return

func webRTC_init(clOrSe: String):
	clientOrServer = clOrSe
	multiplayer_init()

	connection.initialize({"iceServers" = [ {"urls": "stun:stun.l.google.com:19302"}]})
	multiplayer_init_after_connection_initialize()

	channel = connection.create_data_channel("chat", {"id": 1, "negotiated": true})

	connection.session_description_created.connect(func(type: String, sdp: String):
		signaling_data.session_description = {
			"type": type,
			"sdp": sdp
		}
	)

	connection.ice_candidate_created.connect(func(media: String, index: int, iceName: String):
		signaling_data.ice_candidates.append({
			"media": media,
			"index": index,
			"name": iceName
		})
	)

# UI Events

func _on_pressed_host_button():
	after_connected_animation.visible = true
	webRTC_init("server")
	Utils.better_print(["generated UUID", Utils.generate_uuid()])
	create_lobby({
		"name": Utils.generate_uuid(),
		"is_public": false
	})

func _on_pressed_join_button():
	lobby_uuid = join_input.text
	webRTC_init("client")
	create_lobby_offer_request({
		"uuid": lobby_uuid
	})

func _on_id_pressed_level_selector(id):
	var levelId = id
	level_selection_label.text = "Will load Level " + levelId
	State.setCurrentLevel("res://levels/level" + levelId + "/level" + levelId + ".tscn")

# Endpoint Functions

# POST /offers - Create a new offer
func create_offer(offerName: String, is_public: bool):
	var data = {"name": offerName, "isPublic": is_public}
	http_request_create_offer.request("%s/offers" % lobbyUrl, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(data))

# GET /offers/:uuid - Get details of a specific offer by UUID
func get_offer_details(offer_uuid: String):
	http_request_get_offer_details.request("%s/offers/%s" % [lobbyUrl, offer_uuid])

# POST /offers/:uuid/requests - Create a new OfferRequest for an offer
func create_offer_request(offer_uuid: String):
	http_request_create_offer_request.request("%s/offers/%s/requests" % [lobbyUrl, offer_uuid], [], HTTPClient.METHOD_POST)

# GET /offers/:uuid/requests - Get the oldest unresolved OfferRequest for an offer
func get_oldest_offer_request(offer_uuid: String):
	http_request_get_oldest_offer_request.request("%s/offers/%s/requests" % [lobbyUrl, offer_uuid])

# PUT /offers/:offerUuid/requests/:requestUuid/exchange/server - Set Server Exchange Data
func set_server_exchange(_offer_uuid: String, request_uuid: String, ice_candidates: Array, session_description: Dictionary):
	var data = {"exchange": {"iceCandidates": ice_candidates, "sessionDescription": session_description}}
	http_request_set_server_exchange.request("%s/offers/requests/%s/exchange/server" % [lobbyUrl, request_uuid], ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(data))

# PUT /offers/:offerUuid/requests/:requestUuid/exchange/client - Set Client Exchange Data
func set_client_exchange(_offer_uuid: String, request_uuid: String, ice_candidates: Array, session_description: Dictionary):
	var data = {"exchange": {"iceCandidates": ice_candidates, "sessionDescription": session_description}}
	http_request_set_client_exchange.request("%s/offers/requests/%s/exchange/client" % [lobbyUrl, request_uuid], ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(data))

func _on_create_offer_completed(_result, response_code, _headers, body):
	if response_code == 200 or response_code == 201:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.uuid:
			create_lobby({}, {"uuid": response.uuid}, true)

func _on_get_offer_details_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.uuid:
			Utils.better_print(["Offer details:", response.data])

func _on_create_offer_request_completed(_result, response_code, _headers, body):
	if response_code == 200 or response_code == 201:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.sessionDescription:
			create_lobby_offer_request({}, {
				"ice_candidates": response.iceCandidates,
				"session_description": response.sessionDescription,
				"uuid": response.uuid
			}, true)

func _on_get_oldest_offer_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var bodyString = body.get_string_from_utf8()
		if not bodyString: return
		var response = JSON.parse_string(bodyString)
		if response.uuid:
			check_for_offer_request({}, {"uuid": response.uuid}, true)

func _on_set_server_exchange_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.sessionDescription:
			set_server_signaling_data({
				"ice_candidates": response.iceCandidates,
				"session_description": response.sessionDescription
				}, {}, true)
			
func _on_set_client_exchange_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.success:
			await Utils.sleep(4) # give time to connect
			connection.poll()

### MULTIPLAYER LOGIC ###

# offer request -> pending -> returns server offer -> set remote
func create_lobby_offer_request(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return create_offer_request(requestData.uuid)
	webRTC_set_remote(responseData)

	
func check_for_offer_request(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return get_oldest_offer_request(requestData.uuid)
	webRTC_generate_offer({
		"uuid": responseData.uuid
	})

func set_server_signaling_data(requestData: Dictionary = {}, _responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return set_server_exchange(lobby_uuid, requestData.uuid, signaling_data.ice_candidates, signaling_data.session_description)
	
	connection.set_remote_description(requestData.session_description.type, requestData.session_description.sdp)
	for ice_candidate in requestData.ice_candidates:
		connection.add_ice_candidate(ice_candidate.media, ice_candidate.index, ice_candidate.name)
	
	await Utils.sleep(2) # give time to connect
	connection.poll()

func webRTC_generate_offer(requestData: Dictionary = {}):
	connection.create_offer()
	connection.poll()
	
	await Utils.sleep(0.1) # Give ice time to generate routes
	set_server_signaling_data({
		"uuid": requestData.uuid
	})

func webRTC_set_remote(requestData: Dictionary = {}):
	connection.set_remote_description(requestData.session_description.type, requestData.session_description.sdp)
	for ice_candidates in requestData.ice_candidates:
		connection.add_ice_candidate(ice_candidates.media, ice_candidates.index, ice_candidates.name)
	
	connection.poll()
	await Utils.sleep(0.1) # Give ice time to generate routes
	set_client_exchange(lobby_uuid, requestData.uuid, signaling_data.ice_candidates, signaling_data.session_description)

func create_lobby(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return create_offer(requestData.name, requestData.is_public)
	
	generated_join_code_input.text = responseData.uuid
	
	lobby_uuid = responseData.uuid
	
	Utils.set_interval(func(): check_for_offer_request({"uuid": responseData.uuid}), 4)
