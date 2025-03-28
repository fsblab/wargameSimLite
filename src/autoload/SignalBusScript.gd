extends Node

## PlayerInfoScript -> SkirmishMenuScript
## ServerScript -> SkirmishMenuScript
signal _abortStartOfMatch
## UIScript -> MapScript
signal _addUnitToMap(u: String)
## ServerScript -> SkirmishMenuScript
signal _cannotConnectToLobby(msg: String)
## ServerScript -> SkirmishMenuScript
signal _changeNodeName(id: String, newId: String)
## SkirmishMenuScript -> ServerScript
signal _changeNodeNameCompleted
## ServerScript -> SkirmishMenuScript
signal _clientDisconnected(id: int)
## ServerScript -> SkirmishMenuScript
## MapSettingsScript -> SkirmishMenuScript
signal _connectedClientsUpdated(client: Dictionary)
## SkirmishMenu -> ServerScript
## PauseMenuCanvasScript -> ServerScript
signal _disconnectPlayer
## ServerScript -> SkirmishMenuScript
signal _enableDisableInfoNode
## SkirmishLobbyScript -> UnitSelectionScript
signal _loadMaterial
## PlayerInfoScript -> ServerScript
signal _lobbyClientChangedState(client: Dictionary)
## ServerScript -> UIScript
signal _playerListReceived()
## MapSettingsScript -> SkirmishMenuScript
signal _removeClient(id: int)
## UIScript -> ServerScript
signal _requestPlayerListForUI
## UnitSelectionScript -> MapScript
signal _selectPlacedUnit(u: Unit)
## SkirmishMenuScript -> ServerScript
signal _sendChat(msg: String)
##
signal _sendChatAsServer(msg: String)
## ServerScript -> MapSettingsScript
## awaited in ServerScript
signal _setupLobbySettings
## UIScript -> Unit
signal _startBattle
## ServerScript -> MainMenuCanvasScript
## SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleBetweenMuliplayerMenuAndSkirmishMenu
## ServerScript -> MainMenuCanvasScript
## SkirmishMenuScript -> MainMenuCanvasScript
signal _toggleLoadingScreen
## SkirmishMenuScript -> MapSettingsScript
signal _updateMaxPlayers(num: int)
## ServerScript -> PlayerInfoScript
## ServerScript -> UIScript
signal _updatePing(val: int, nodepath: String)
## PlayerInfoScript -> SkirmishMenuScript
signal _updatePlayer(id: String, what: String, toWhat)


func abortStartOfMatch() -> void:
	_abortStartOfMatch.emit()


func addUnitToMap(u: GameMetaDataScript.unitName, f: GameMetaDataScript.faction) -> void:
	_addUnitToMap.emit(u, f)


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


func enableDisableInfoNode(id: int) -> void:
	_enableDisableInfoNode.emit(id)


func loadMaterial() -> void:
	_loadMaterial.emit()


func lobbyClientChangedState(id: String, what: String, toWhat) -> void:
	_lobbyClientChangedState.emit(id, what, toWhat)


func playerListReceived() -> void:
	_playerListReceived.emit()


@rpc("call_local", "any_peer", "reliable")
func removeClient(id: int) -> void:
	_removeClient.emit(id)


func requestPlayerListForUI() -> void:
	_requestPlayerListForUI.emit()


func selectPlacedUnit(u: Unit) -> void:
	_selectPlacedUnit.emit(u)


func sendChat(msg: String) -> void:
	_sendChat.emit(msg)


func sendChatAsServer(msg: String) -> void:
	_sendChatAsServer.emit(msg)


func setupLobbySettings() -> void:
	_setupLobbySettings.emit()


func startBattle() -> void:
	_startBattle.emit()


func toggleBetweenMultiplayerMenuAndSkirmishMenu() -> void:
	_toggleBetweenMuliplayerMenuAndSkirmishMenu.emit()


func toggleLoadingScreen() -> void:
	_toggleLoadingScreen.emit()


func updateMaxPlayers(num: int) -> void:
	_updateMaxPlayers.emit(num)


func updatePing(val: int, nodepath: String) -> void:
	_updatePing.emit(val, nodepath)


@rpc("any_peer", "call_local", "reliable")
func updatePlayer(id: String, what: String, toWhat) -> void:
	_updatePlayer.emit(id, what, toWhat)
	if multiplayer.is_server():
		GameMetaDataScript.connectedClients[id.to_int()][what] = toWhat
