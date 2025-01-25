extends HBoxContainer


@onready var playerName: Label = $PlayerName
@onready var readyButton: Button = $Ready
@onready var kickButton: Button = $Kick
@onready var teamSpinBox: SpinBox = $Team


func toggleReady() -> void:
	var id: int = int(String(name))
	if id < 30000 and not multiplayer.is_server():
		return
	var status = not GameMetaDataScript.client.Ready
	if not status:
		SignalBusScript.abortStartOfMatch()
	sendChangeToClients("Ready", status)
	SignalBusScript.enableDisableInfoNode(GameMetaDataScript.client.uid)


func selectPlayer(index: int) -> void:
	var oldId: String = name
	var getData: Dictionary = [GameMetaDataScript.getNoneData, GameMetaDataScript.getPlayerPlaceholderData, GameMetaDataScript.getBotData, GameMetaDataScript.getViewerData][index].call()

	sendChangeToClients("Player", index)
	for data in ["Ready", "Faction", "Team", "PlayerName"]:
		sendChangeToClients(data, getData[data])
	
	SignalBusScript.changeNodeName.rpc(oldId, str(getData.uid))
	
	if multiplayer.is_server():
		GameMetaDataScript.connectedClients.erase(oldId.to_int())
		GameMetaDataScript.connectedClients[getData.uid] = getData
	

func selectFaction(index: int) -> void:
	sendChangeToClients("Faction", index)


func setTeam(val: float) -> void:
	if val > int(GameMetaDataScript.mapInfo.meta.MaxNoTeams):
		teamSpinBox.get_line_edit().text = GameMetaDataScript.mapInfo.meta.MaxNoTeams
		teamSpinBox.apply()
		return
	sendChangeToClients("Team", int(val))


func sendChangeToClients(what: String, toWhat) -> void:
	if str(multiplayer.get_unique_id()) == name:
		GameMetaDataScript.client[what] = toWhat
	SignalBusScript.updatePlayer.rpc(str(name), what, toWhat)


func setPlayerNameColor(color: Color) -> void:
	playerName.add_theme_color_override("font_color", color)


func disableKickButton() -> void:
	kickButton.disabled = true


func getKicked() -> void:
	var id: int = int(str(name))
	if id < 50000:
		return
	multiplayer.multiplayer_peer.disconnect_peer(id)
