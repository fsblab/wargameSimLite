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
signal _disconnectPlayer
#PlayerInfoScript -> ServerScript
signal _lobbyClientChangedState
#MainMenuCanvasScript -> ServerScript
signal _requestLobbyInfo
#SkirmishMenuScript -> ServerScript
signal _sendChat(msg: String)
signal _sendChatAsServer(msg: String)


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


func requestLobbyInfo() -> void:
	_requestLobbyInfo.emit()


func sendChat(msg: String) -> void:
	_sendChat.emit(msg)


func sendChatAsServer(msg: String) -> void:
	_sendChatAsServer.emit(msg)
