extends Node

var player_list: Array = []
var socket: ENetMultiplayerPeer
const DEFAULT_PORT = 1234

func start_host():
	socket = ENetMultiplayerPeer.new()
	socket.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = socket

func connect_player(ip:String):
	socket = ENetMultiplayerPeer.new()
	socket.create_client(ip,DEFAULT_PORT)
	multiplayer.multiplayer_peer = socket

func _init():
	pass
