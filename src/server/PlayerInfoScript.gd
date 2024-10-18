extends HBoxContainer


@onready var playerName: Label = $PlayerNameLabel
@onready var readyButton: Button = $Ready
@onready var kickButton: Button = $Kick


func toggleReady() -> void:
	var status = not GameMetaDataScript.client.isReady
	if not status:
		SignalBusScript.abortStartOfMatch()
	sendChangeToClients("isReady", status)


func selectFaction(index: int) -> void:
	sendChangeToClients("faction", index)


func setTeam(val: float) -> void:
	sendChangeToClients("team", int(val))


func sendChangeToClients(what: String, toWhat) -> void:
	GameMetaDataScript.client[what] = toWhat
	SignalBusScript.lobbyClientChangedState()


func setPlayerNameColor(color: Color) -> void:
	playerName.add_theme_color_override("font_color", color)


func disableKickButton() -> void:
	kickButton.disabled = true
