extends CanvasLayer

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7001
const DEFAULT_SERVER_IP = "localhost" # IPv4 localhost
const MAX_CONNECTIONS = 20
var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if address == "":
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print(str(multiplayer.get_unique_id()) + ": Connecting To Server")


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	send_player_information($TextEdit.text, multiplayer.get_unique_id())
	print(str(multiplayer.get_unique_id()) + ": Succesfully Started Server")
	
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://Levels/MainScreen.tscn").instantiate()
	load_game("res://Levels/MainScreen.tscn")
	#Add asteroids here I think

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

# When the server decides to start the game from a UI scene, do Lobby.load_game.rpc(filepath)
@rpc("call_local", "unreliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)
	
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("Peer Connected " + str(id))
	
func _on_player_disconnected(id):
	player_disconnected.emit(id)
	print("Peer Disconnected " + str(id))

#More secure way to transfer information
func _on_connected_ok():
	send_player_information.rpc_id(1, $TextEdit.text, multiplayer.get_unique_id())

func _on_connected_fail():
	print("Peer failed to connect")	
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	server_disconnected.emit()
	multiplayer.multiplayer_peer = null
	print("Server Disconnected")
	
@rpc("any_peer")
func send_player_information(name, id):
	#If player not in Players dict, add them
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" = name,
			"id" = id,
			"score" = 0
		}
		
	#Send that information to everyone else whos connected
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

func _on_start_pressed():
	start_game.rpc()
