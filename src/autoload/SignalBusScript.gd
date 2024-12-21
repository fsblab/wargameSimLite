extends Node

#PlayerInfoScript -> SkirmishMenuScript
#ServerScript -> SkirmishMenuScript
signal _abortStartOfMatch
#ServerScript -> SkirmishMenuScript
signal _cannotConnectToLobby(msg: String)
#ServerScript -> SkirmishMenuScript
signal _changeNodeName(id: String, newId: String)
#SkirmishMenuScript -> ServerScript
signal _changeNodeNameCompleted
#ServerScript -> SkirmishMenuScript
signal _clientDisconnected(id: int)
#ServerScript -> SkirmishMenuScript
#MapSettingsScript -> SkirmishMenuScript
signal _connectedClientsUpdated(client: Dictionary)
#SkirmishMenu -> ServerScript
#PauseMenuCanvasScript -> ServerScript
signal _disconnectPlayer
#PlayerInfoScript -> ServerScript
signal _lobbyClientChangedState(client: Dictionary)
#MapSettingsScript -> SkirmishMenuScript
signal _removeClient(id: int)
#SkirmishMenuScript -> ServerScript
signal _sendChat(msg: String)
signal _sendChatAsServer(msg: String)
#ServerScript -> MainMenuCanvasScript
#SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleBetweenMuliplayerMenuAndSkirmishMenu
#ServerScript -> MainMenuCanvasScript
#SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleLoadingScreen
#Severscript -> SkirmishMenuScript
signal _enableDisableInfoNode
#ServerScript -> PlayerInfoScript
#ServerScript -> UIScript
signal _updatePing(val: int, uid: int)
#PlayerInfoScript -> SkirmishMenu
signal _updatePlayer(id: String, what: String, toWhat)


func abortStartOfMatch() -> void:
	_abortStartOfMatch.emit()


func cannotConnectToLobby(msg: String) -> void:
	_cannotConnectToLobby.emit(msg)


@rpc("call_local", "any_peer", "reliable")
func changeNodeName(id: String, newId: String) -> void:
	_changeNodeName.emit(id, newId)


func changeNodeNameCompleted() -> void:
	_changeNodeNameCompleted.emit()


func clientDisconnected(id: int) -> void:
	_clientDisconnected.emit(id)


@rpc("call_local", "any_peer", "reliable")
func connectedClientsUpdated(client: Dictionary) -> void:
	_connectedClientsUpdated.emit(client)


func disconnectPlayer() -> void:
	_disconnectPlayer.emit()


func lobbyClientChangedState(id: String, what: String, toWhat) -> void:
	_lobbyClientChangedState.emit(id, what, toWhat)


@rpc("call_local", "any_peer", "reliable")
func removeClient(id: int) -> void:
	_removeClient.emit(id)


func sendChat(msg: String) -> void:
	_sendChat.emit(msg)


func sendChatAsServer(msg: String) -> void:
	_sendChatAsServer.emit(msg)


func toggleBetweenMultiplayerMenuAndSkirmishMenu() -> void:
	_toggleBetweenMuliplayerMenuAndSkirmishMenu.emit()


func toggleLoadingScreen() -> void:
	_toggleLoadingScreen.emit()


func enableDisableInfoNode(id: int) -> void:
	_enableDisableInfoNode.emit(id)


func updatePing(val: int, uid: int) -> void:
	_updatePing.emit(val, uid)


@rpc("any_peer", "call_local", "reliable")
func updatePlayer(id: String, what: String, toWhat) -> void:
	_updatePlayer.emit(id, what, toWhat)
	if multiplayer.is_server():
		GameMetaDataScript.connectedClients[id.to_int()][what] = toWhat
