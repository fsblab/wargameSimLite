extends MarginContainer


@onready var maxPlayersSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer


func updateMaxPlayers(num: float) -> void:
	if num < GameMetaDataScript.connectedClients.size():
		maxPlayersSpinBox.get_line_edit().text = str(GameMetaDataScript.connectedClients.size())
		maxPlayersSpinBox.apply()
		GameMetaDataScript.lobby.maxClients = GameMetaDataScript.connectedClients.size()
		return
	GameMetaDataScript.lobby.maxClients = num
