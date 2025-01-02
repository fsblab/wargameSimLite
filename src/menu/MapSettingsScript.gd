extends MarginContainer


@onready var maxPlayersSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer
@onready var timeLimitToggle: CheckButton = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/InfTime
@onready var matchTimeSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/Time


func _ready() -> void:
	SignalBusScript._setupLobbySettings.connect(setupLobbySettings)


func setupLobbySettings() -> void:
	_updateFogOfWar(GameMetaDataScript.lobby.fogOfWar)
	if GameMetaDataScript.lobby.matchTime:
		_updateTimeLimitToggle(true)
		_updateMatchTime(GameMetaDataScript.lobby.matchTime)
	else:
		_updateTimeLimitToggle(false)
		_updateMatchTime(0)


func updateMaxPlayers(num: float) -> void:
	while GameMetaDataScript.lobby.maxClients != num and multiplayer.is_server():
		if num < GameMetaDataScript.lobby.maxClients:
			var filtered = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x < 50000 and x > 1: return x)
			var id: int
			if filtered:
				id = filtered[-1]
			else:
				maxPlayersSpinBox.get_line_edit().text = str(GameMetaDataScript.lobby.maxClients)
				maxPlayersSpinBox.apply()
				return
			SignalBusScript.removeClient.rpc(id)
			GameMetaDataScript.lobby.maxClients -= 1
		else:
			var noneClient: Dictionary = GameMetaDataScript.getNoneData()
			if multiplayer.is_server():
				GameMetaDataScript.connectedClients[noneClient.uid] = noneClient
			SignalBusScript.connectedClientsUpdated.rpc(noneClient)
			GameMetaDataScript.lobby.maxClients += 1
		rpc("_updateMaxPlayerForEveryClient", maxPlayersSpinBox.get_line_edit().text)


@rpc("call_local", "any_peer", "reliable")
func _updateMaxPlayerForEveryClient(num: String) -> void:
	if not multiplayer.is_server():
		maxPlayersSpinBox.get_line_edit().text = str(num)
		maxPlayersSpinBox.apply()


func fogOfWarSelected(index: int):
	rpc("_updateFogOfWar", index)


@rpc("call_local", "any_peer", "reliable")
func _updateFogOfWar(index: int):
	GameMetaDataScript.lobby.fogOfWar = index


func toggleMatchTimeLimited(on: bool):
	if multiplayer.is_server():
		matchTimeSpinBox.get_line_edit().editable = on
		rpc("_updateTimeLimitToggle", on)
		if on:
			GameMetaDataScript.lobby.matchTime = int(matchTimeSpinBox.get_line_edit().text)
			rpc("_updateMatchTime", GameMetaDataScript.lobby.matchTime)
		else:
			GameMetaDataScript.lobby.matchTime = 0


@rpc("call_local", "any_peer", "reliable")
func _updateTimeLimitToggle(on: bool):
	timeLimitToggle.set_pressed(on)


func setMatchTime(val: float):
	rpc("_updateMatchTime", int(val))


@rpc("call_local", "authority", "reliable")
func _updateMatchTime(num: int):
	if not multiplayer.is_server():
		matchTimeSpinBox.get_line_edit().text = str(num if num != 0 else GameMetaDataScript.lobby.matchTime)
		matchTimeSpinBox.apply()
		GameMetaDataScript.lobby.matchTime = num
