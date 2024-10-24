extends Node

#PlayerInfoScript -> SkirmishMenuScript
signal _abortStartOfMatch
#ServerScript -> SkirmishMenuScript
signal _cannotConnectToLobby(msg: String)
#ServerScript -> SkirmishMenuScript
signal _clientDisconnected(id: int)
#ServerScript -> SkirmishMenuScript
signal _connectedClientsUpdated(id: int)
#SkirmishMenu -> ServerScript
#PauseMenuCanvasScript -> ServerScript
signal _disconnectPlayer
#PlayerInfoScript -> ServerScript
signal _lobbyClientChangedState
#SkirmishMenuScript -> ServerScript
signal _sendChat(msg: String)
signal _sendChatAsServer(msg: String)
#ServerScript -> MainMenuCanvasScript
#SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleBetweenMuliplayerMenuAndSkirmishMenu()
#ServerScript -> MainMenuCanvasScript
#SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleLoadingScreen()
#ServerScript -> PlayerInfoScript
#ServerScript -> UIScript
signal _updatePing(val: int, uid: int)


func abortStartOfMatch() -> void:
	_abortStartOfMatch.emit()


func cannotConnectToLobby(msg: String) -> void:
	_cannotConnectToLobby.emit(msg)


func clientDisconnected(id: int) -> void:
	_clientDisconnected.emit(id)


func connectedClientsUpdated(id: int) -> void:
	_connectedClientsUpdated.emit(id)


func disconnectPlayer() -> void:
	_disconnectPlayer.emit()


func lobbyClientChangedState() -> void:
	_lobbyClientChangedState.emit()


func sendChat(msg: String) -> void:
	_sendChat.emit(msg)


func sendChatAsServer(msg: String) -> void:
	_sendChatAsServer.emit(msg)


func toggleBetweenMultiplayerMenuAndSkirmishMenu() -> void:
	_toggleBetweenMuliplayerMenuAndSkirmishMenu.emit()


func toggleLoadingScreen() -> void:
	_toggleLoadingScreen.emit()


func updatePing(val: int, uid: int) -> void:
	_updatePing.emit(val, uid)
