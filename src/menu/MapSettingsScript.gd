extends MarginContainer


@onready var maxPlayersSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer


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
		rpc("updateMaxPlayerForEveryClient", maxPlayersSpinBox.get_line_edit().text)


@rpc("call_local", "any_peer", "reliable")
func updateMaxPlayerForEveryClient(num: String) -> void:
	if not multiplayer.is_server():
		maxPlayersSpinBox.get_line_edit().text = str(num)
		maxPlayersSpinBox.apply()
