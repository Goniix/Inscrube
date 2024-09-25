extends Node

var player_list: Array = []
var socket: ENetMultiplayerPeer
const DEFAULT_PORT = 1234
const LOOPBACK = "127.0.0.1"

func slog(text:String):
	if multiplayer.is_server():
		print("[SERVER]: "+text)
	else:
		print("["+str(multiplayer.get_unique_id())+"]: "+text)

func start_host():
	socket = ENetMultiplayerPeer.new()
	socket.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = socket
	slog("Started on port: "+str(DEFAULT_PORT))

func connect_player(ip:String = LOOPBACK):
	socket = ENetMultiplayerPeer.new()
	socket.create_client(ip,DEFAULT_PORT)
	multiplayer.multiplayer_peer = socket

#CLIENT SIDE
func _on_successful_server_connection():
	slog("Connected to server")

func _on_failed_server_connection():
	slog("Failed connection to server")

func _on_server_disconnected():
	slog("Lost connection to server")


#SERVER SIDE

func _on_new_peer_connection(id:int):
	if multiplayer.is_server():
		slog("New client connected with ID:"+str(id))
		slog("Peer count is now "+str(multiplayer.get_peers().size()))

	else: #is client
		pass

func _on_peer_disconnection(id:int):
	if multiplayer.is_server():
		slog("Client disconnected with ID:"+str(id))
		slog("Peer count is now "+str(multiplayer.get_peers().size()))
	else: #is client
		pass
		


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_successful_server_connection)
	multiplayer.connection_failed.connect(_on_failed_server_connection)
	multiplayer.peer_connected.connect(_on_new_peer_connection)
	multiplayer.peer_disconnected.connect(_on_peer_disconnection)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if OS.get_cmdline_args().has("host"): #is server
		start_host()
	else:
		connect_player()
