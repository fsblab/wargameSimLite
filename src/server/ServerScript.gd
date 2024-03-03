extends Control


@onready var chatBox: TextEdit = $MainMenu/CanvasLayer/SkirmishMenu/CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit

var clientId: int
var peer: ENetMultiplayerPeer
const localhost: String = "127.0.0.1"


func _ready():
	multiplayer.peer_connected.connect(playerJoined)
	multiplayer.peer_disconnected.connect(playerLeft)
	multiplayer.connected_to_server.connect(clientConnectedToServer)
	
	GameMetaDataScript.reset()


func initServer(port: int = 7000, maxClients: int = 1) -> bool:
	if not port:
		port = 7000
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, maxClients)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Server failed to start.")
		return false
	
	multiplayer.multiplayer_peer = peer
	GameMetaDataScript.client.uid = multiplayer.get_unique_id()
	GameMetaDataScript.connectedClients[GameMetaDataScript.client.uid] = GameMetaDataScript.client
	set_multiplayer_authority(GameMetaDataScript.client.uid)
	sendChat("Lobby created")
	return true


func joinServer(ip: String, port: int) -> bool:
	if not ip:
		ip = localhost
	if not port:
		port = 7000
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	
	if error:
		OS.alert("ERROR: " + error)
		return false
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to server.")
		return false
	
	multiplayer.multiplayer_peer = peer
	return true


func sendChat(msg: String) -> void:
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], msg)


@rpc("any_peer", "call_local", "reliable")
func _sendChat(pName: String, msg: String) -> void:
	chatBox.text = chatBox.text + str("[", Time.get_time_string_from_system(), "] " , pName, ": ", msg, "\n")
	chatBox.scroll_vertical = INF


func clientConnectedToServer():
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], "joined")


func kickPlayer(id: int) -> void:
	rpc("_kickPlayer", id)


@rpc("authority", "call_remote", "reliable")
func _kickPlayer(id: int) -> void:
	multiplayer.disconnect_peer(id)
	GameMetaDataScript.connectedClients.erase(id)


func closeConnection() -> void:
	multiplayer.multiplayer_peer = null
	GameMetaDataScript.connectedClients.clear()


func playerJoined(id: int) -> void:
	if multiplayer.is_server():
		rpc_id(id, "_requestPlayerData", id, GameMetaDataScript.connectedClients)


@rpc("any_peer", "call_local", "reliable")
func _requestPlayerData(id: int, clients: Dictionary) -> void:
	GameMetaDataScript.client.uid = id
	clients[id] = GameMetaDataScript.client
	GameMetaDataScript.connectedClients.merge(clients)
	rpc("_updateConnectedClients", GameMetaDataScript.client)


@rpc("any_peer", "call_local", "reliable")
func _updateConnectedClients(client: Dictionary) -> void:
	GameMetaDataScript.connectedClients[client.uid] = client


func playerLeft(id) -> void:
	GameMetaDataScript.connectedClients.erase(id)