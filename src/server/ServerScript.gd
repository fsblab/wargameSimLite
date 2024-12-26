extends Control


@onready var chatBox: TextEdit = $MainMenu/CanvasLayer/SkirmishMenu/CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit

signal _lobbyInfoFinished

var peer: ENetMultiplayerPeer
const localhost: String = "127.0.0.1"
var tickStamp: int
var tickCurrent: int
const deltaTick: int = 2000000


func _ready():
	tickStamp = Time.get_ticks_usec()

#	multiplayer.peer_connected.connect(playerJoined)	#called on all clients
	multiplayer.peer_disconnected.connect(playerLeft)	#called on all clients
	multiplayer.connected_to_server.connect(connectionEstablished)	#called only on newly connecting client
	multiplayer.connection_failed.connect(connectionFailed)			#called only on newly connecting client
#	multiplayer.server_disconnected.connect(connectionFailed)
	
	SignalBusScript._disconnectPlayer.connect(disconnectPlayer)
	SignalBusScript._lobbyClientChangedState.connect(lobbyClientChangedState)
	SignalBusScript._requestPlayerListForUI.connect(requestPlayerListForUI)
	SignalBusScript._sendChat.connect(sendChat)
	SignalBusScript._sendChatAsServer.connect(sendChatAsServer)
	
	GameMetaDataScript.reset()


func _process(_delta: float) -> void:
	if multiplayer.is_server():
		tickCurrent = Time.get_ticks_usec()
		if tickCurrent - tickStamp > deltaTick:
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
	var error: int = peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

	if error:
		OS.alert("ERROR: " + str(error))
		return false
	
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to server.")
		return false
	
	GameMetaDataScript.client.uid = multiplayer.get_unique_id()

	return true


@rpc("any_peer", "call_local", "reliable")
func _requestLobbyInfo(id: int) -> void:
	rpc_id(id, "_sendLobbyInfo", GameMetaDataScript.lobby)


@rpc("authority", "call_remote", "reliable")
func _sendLobbyInfo(lobbyInfo: Dictionary) -> void:
	GameMetaDataScript.lobby.merge(lobbyInfo, true)
	_lobbyInfoFinished.emit()


func sendChat(msg: String) -> void:
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], msg)


@rpc("any_peer", "call_local", "reliable")
func _sendChat(pName: String, msg: String) -> void:
	chatBox.text = chatBox.text + str("[", Time.get_time_string_from_system(), "] " , pName, ": ", msg, "\n")
	chatBox.scroll_vertical = INF


func sendChatAsServer(msg: String) -> void:
	rpc("_sendChat", "SERVER", msg)


func connectionEstablished() -> void:
	SignalBusScript.abortStartOfMatch()
	SignalBusScript.toggleLoadingScreen()
	SignalBusScript.toggleBetweenMultiplayerMenuAndSkirmishMenu()

	rpc_id(1, "_requestLobbyInfo", multiplayer.get_unique_id())

	#awaiting signal just to be safe, likely works without signal too
	await _lobbyInfoFinished

	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOBBY

	rpc("playerJoined", multiplayer.get_unique_id())


func kickPlayer() -> void:
	rpc("_kickPlayer")


@rpc("any_peer", "call_remote", "reliable")
func _kickPlayer() -> void:
	if GameMetaDataScript.currentGameMode == GameMetaDataScript.gameMode.SKIRMISH:
		SignalBusScript.cannotConnectToLobby("lobby is full. Max Clients: " + str(GameMetaDataScript.lobby.maxClients))
	closeConnection()


func closeConnection() -> void:
	multiplayer.multiplayer_peer.close()
	GameMetaDataScript.resetClient()
	GameMetaDataScript.resetLobby()


#host sends list of clients in lobby to newly connected client
@rpc("any_peer", "call_local", "reliable")
func playerJoined(id: int) -> void:
	if GameMetaDataScript.lobby.maxClients == GameMetaDataScript.lobby.totalClients and multiplayer.get_unique_id() != id:
		if multiplayer.is_server():
			rpc_id(id, "_kickPlayer")
		return
	if multiplayer.is_server():
		rpc_id(id, "_requestPlayerData", GameMetaDataScript.connectedClients)


#only newly connected client executes this
#sets up lobby with data of players currently in lobby
@rpc("authority", "call_local", "reliable")
func _requestPlayerData(clients: Dictionary) -> void:
	for player in clients.values():
		SignalBusScript.connectedClientsUpdated(player)
		
	rpc("_sendChat", SettingsConfigScript.currentPlayerInfo["name"], "joined")
	rpc("_updateConnectedClients", GameMetaDataScript.client)


@rpc("any_peer", "call_local", "reliable")
func _updateConnectedClients(client: Dictionary) -> void:
	if multiplayer.is_server():
		var oldId: int = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x > 30000: return x)[0]
		GameMetaDataScript.connectedClients.erase(oldId)
		GameMetaDataScript.connectedClients[client.uid] = client

		rpc("_changeNodeName", str(oldId), str(client.uid))
	
	# why is this necessary??? BUG in the engine???
	# without the if statement the server and only the server first sends the signal and only afterwards awaits it
	if not multiplayer.is_server():
		await SignalBusScript._changeNodeNameCompleted

	for data in ["Ready", "Faction", "Team", "PlayerName"]:
		_changeDataOnConnectedClient(str(client.uid), data, client[data])
	
	SignalBusScript.enableDisableInfoNode(client.uid)


@rpc("any_peer", "call_local", "reliable")
func _changeNodeName(oldId: String, id: String) -> void:
	SignalBusScript.changeNodeName(str(oldId), str(id))


func lobbyClientChangedState(id: String, what: String, toWhat) -> void:
	rpc("_changeDataOnConnectedClient", id, what, toWhat)


@rpc("any_peer", "call_local", "reliable")
func _changeDataOnConnectedClient(id: String, what: String, toWhat) -> void:
	SignalBusScript.updatePlayer(id, what, toWhat)


func disconnectPlayer() -> void:
	if GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.MATCH:
		rpc("_updatePing", -1, GameMetaDataScript.client.uid)

	multiplayer.multiplayer_peer.close()


@rpc("any_peer", "call_local", "reliable")
func _disconnectPlayer(id: int) -> void:
	rpc_id(id, "_kickPlayer")


func playerLeft(id: int) -> void:
	if multiplayer.is_server() and GameMetaDataScript.connectedClients.has(id):
		rpc("_sendChat", GameMetaDataScript.connectedClients[id].PlayerName, "left")
		if GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.MATCH:
			rpc("_updatePing", -1, id)
	
	SignalBusScript.clientDisconnected(id)


func connectionFailed() -> void:
	closeConnection()
	SignalBusScript.cannotConnectToLobby("Connection could not be established.")


func requestPlayerListForUI() -> void:
	rpc_id(1, "_requestPlayerList")


@rpc("any_peer", "call_local", "reliable")
func _requestPlayerList() -> void:
	var clients: Dictionary =  StdScript.dmap(GameMetaDataScript.connectedClients, func(client): return {"Faction": client.Faction, "PlayerName": client.PlayerName, "Team": client.Team, "uid": client.uid})
	rpc("_sendPlayerList", clients)


@rpc("any_peer", "call_local", "reliable")
func _sendPlayerList(clients: Dictionary) -> void:
	GameMetaDataScript.connectedClients = clients
	SignalBusScript.playerListReceived()


func pingEveryone() -> void:
	for id in multiplayer.get_peers():
		if id < 1:
			continue
		rpc_id(id, "_ping", Time.get_ticks_usec(), id)


#actually half a ping
@warning_ignore("integer_division")
@rpc("any_peer", "call_local", "unreliable")
func _ping(timestamp: int, id: int) -> void:
	var nodepath: String = str(GameMetaDataScript.client.Team, '/', GameMetaDataScript.client.uid)
	var ping = (Time.get_ticks_usec() - timestamp) / 1000
	GameMetaDataScript.client["Ping"] = ping
	
	if GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.LOBBY:
		rpc("_changeDataOnConnectedClient", str(id), "Ping", str(ping))
	elif GameMetaDataScript.currentGameState == GameMetaDataScript.gameState.MATCH:
		rpc("_updatePing", ping, nodepath)


@rpc("any_peer", "call_local", "unreliable")
func _updatePing(ping: int, nodepath: String) -> void:
	SignalBusScript.updatePing(ping, nodepath)
