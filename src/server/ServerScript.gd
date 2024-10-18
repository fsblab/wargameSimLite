extends Control


@onready var chatBox: TextEdit = $MainMenu/CanvasLayer/SkirmishMenu/CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit

var peer: ENetMultiplayerPeer
const localhost: String = "127.0.0.1"
var tickStamp: int
var tickCurrent: int


func _ready():
	tickStamp = Time.get_ticks_usec()

	multiplayer.peer_connected.connect(playerJoined)
	multiplayer.peer_disconnected.connect(playerLeft)
#	multiplayer.connected_to_server.connect(clientConnectedToServer)
	multiplayer.connection_failed.connect(connectionFailed)
	multiplayer.server_disconnected.connect(connectionFailed)
	
	SignalBusScript._disconnectPlayer.connect(disconnectPlayer)
	SignalBusScript._lobbyClientChangedState.connect(lobbyClientChangedState)
#	SignalBusScript._requestLobbyInfo.connect()
	SignalBusScript._sendChat.connect(sendChat)
	SignalBusScript._sendChatAsServer.connect(sendChatAsServer)
	
	GameMetaDataScript.reset()


func _process(_delta: float) -> void:
	tickCurrent = Time.get_ticks_usec()
	if multiplayer.is_server() and not GameMetaDataScript.connectedClients.is_empty() and tickCurrent - tickStamp > 2000000 and not GameMetaDataScript.currentGameState in [GameMetaDataScript.gameState.LOADING, GameMetaDataScript.gameState.MENUS]:
		tickStamp = tickCurrent
		pingEveryone()


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

	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		peer.refuse_new_connections = true
	else:
		peer.refuse_new_connections = false
	
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

	rpc("_requestLobbyInfo")
	
	if GameMetaDataScript.lobby.maxClients == -1:
		multiplayer.multiplayer_peer = null
		peer = null
		return false

	return true


@rpc("any_peer", "call_local", "reliable")
func _requestLobbyInfo(id) -> void:
	if multiplayer.is_server():
		if GameMetaDataScript.lobby.maxClients == GameMetaDataScript.connectedClients.size():
			rpc_id(id, "_sendLobbyInfo", GameMetaDataScript.lobby, -1)
			return
		rpc_id(id, "_sendLobbyInfo", GameMetaDataScript.lobby, GameMetaDataScript.maxClients)


@rpc("authority", "call_remote", "reliable")
func _sendLobbyInfo(lobbyInfo: Dictionary, maxClients: int) -> void:
	GameMetaDataScript.lobby.maxClients = maxClients
	GameMetaDataScript.lobby.merge(lobbyInfo)


func sendChat(msg: String) -> void:
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], msg)


@rpc("any_peer", "call_local", "reliable")
func _sendChat(pName: String, msg: String) -> void:
	chatBox.text = chatBox.text + str("[", Time.get_time_string_from_system(), "] " , pName, ": ", msg, "\n")
	chatBox.scroll_vertical = INF


func sendChatAsServer(msg: String) -> void:
	rpc("_sendChat", "SERVER", msg)


## @deprecated
func clientConnectedToServer() -> void:
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], "joined")


func kickPlayer(id: int) -> void:
	rpc("_kickPlayer", id)


@rpc("authority", "call_remote", "reliable")
func _kickPlayer(id: int) -> void:
	multiplayer.multiplayer_peer = null
	#multiplayer.disconnect_peer(id)
	if GameMetaDataScript.connectedClients.has(id):
		GameMetaDataScript.connectedClients.erase(id)
	if GameMetaDataScript.currentGameMode == GameMetaDataScript.gameMode.SKIRMISH:
		SignalBusScript.cannotConnectToLobby("lobby is full. Max Clients: " + str(GameMetaDataScript.lobby.maxClients))


func closeConnection() -> void:
	multiplayer.multiplayer_peer = null
	GameMetaDataScript.connectedClients.clear()


func playerJoined(id: int) -> void:
	#host sends list of clients in lobby to newly connected client
	if multiplayer.is_server():
		if GameMetaDataScript.lobby.maxClients == GameMetaDataScript.connectedClients.size():
			rpc_id(id, "_kickPlayer", id)
			return
		rpc_id(id, "_requestPlayerData", GameMetaDataScript.connectedClients, GameMetaDataScript.lobby)


#only newly connected client executes this
#sets up lobby with data of players currently in lobby
@rpc("any_peer", "call_local", "reliable")
func _requestPlayerData(clients: Dictionary, _lobbyInfo: Dictionary) -> void:
	var id: int = multiplayer.get_unique_id()
	
	GameMetaDataScript.client.uid = id
	clients[id] = GameMetaDataScript.client
	
	for player in clients.values():
		GameMetaDataScript.setupPlayerInfoNode(player)
	
	#GameMetaDataScript.lobby.mayClients = lobbyInfo.maxClients
	GameMetaDataScript.connectedClients.merge(clients)
	#GameMetaDataScript.lobby.merge(lobbyInfo)
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], "joined")
	rpc("_updateConnectedClients", GameMetaDataScript.client)


@rpc("any_peer", "call_local", "reliable")
func _updateConnectedClients(client: Dictionary) -> void:
	GameMetaDataScript.connectedClients[client.uid] = client
	GameMetaDataScript.setupPlayerInfoNode(client)
	SignalBusScript.connectedClientsUpdated(client.uid)


func lobbyClientChangedState() -> void:
	rpc("_changeDataOnConnectedClient", GameMetaDataScript.client)


@rpc("any_peer", "call_local", "reliable")
func _changeDataOnConnectedClient(client: Dictionary) -> void:
	GameMetaDataScript.updatePlayerInfoNode(client)


func disconnectPlayer() -> void:
	multiplayer.multiplayer_peer = null
	peer = null


@rpc("any_peer", "call_local", "reliable")
func _disconnectPlayer(id: int) -> void:
	multiplayer.disconnect_peer(id)


func playerLeft(id: int) -> void:
	if multiplayer.is_server() and GameMetaDataScript.connectedClients.has(id):
		rpc("_sendChat", GameMetaDataScript.connectedClients[id].playerName, "left")
	
	SignalBusScript.clientDisconnected(id)
	GameMetaDataScript.connectedClients.erase(id)


func connectionFailed() -> void:
	closeConnection()
	SignalBusScript.cannotConnectToLobby("Connection could not be established.")


func pingEveryone() -> void:
	for id in GameMetaDataScript.connectedClients:
		if id < 1:
			continue
		rpc_id(id, "_ping", Time.get_ticks_usec(), id)


#actually half a ping
@warning_ignore("integer_division")
@rpc("any_peer", "call_local", "reliable")
func _ping(timestamp: int, id: int) -> void:
	var ping = (Time.get_ticks_usec() - timestamp) / 1000
	GameMetaDataScript.client["ping"] = ping
	
	if GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.LOBBY:
		rpc("_updateConnectedClients", GameMetaDataScript.client)
	elif GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.MATCH:
		rpc("_updatePing", ping, id)


@rpc("any_peer", "call_local", "reliable")
func _updatePing(ping: int, id: int) -> void:
	SignalBusScript.updatePing(ping, id)
