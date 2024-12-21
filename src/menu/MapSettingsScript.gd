extends MarginContainer


@onready var maxPlayersSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer


func updateMaxPlayers(num: float) -> void:
	while GameMetaDataScript.lobby.maxClients != num:
		if num < GameMetaDataScript.lobby.maxClients:
			var filtered = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x < 50000 and x > 1: return x)
			var id: int
			if filtered:
				id = filtered[-1]
			else:
				maxPlayersSpinBox.get_line_edit().text = str(GameMetaDataScript.lobby.maxClients)
				maxPlayersSpinBox.apply()
				return
			SignalBusScript.removeClient(id)
			GameMetaDataScript.lobby.maxClients -= 1
		else:
			var noneClient: Dictionary = GameMetaDataScript.getNoneData()
			if multiplayer.is_server():
				GameMetaDataScript.connectedClients[noneClient.uid] = noneClient
			SignalBusScript.connectedClientsUpdated(noneClient)
			GameMetaDataScript.lobby.maxClients += 1
