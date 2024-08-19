extends HBoxContainer


@onready var playerName: Label = $PlayerNameLabel
@onready var readyButton: Button = $Ready
@onready var kickButton: Button = $Kick
@onready var server: Control = get_tree().get_root().get_node("Start")


func toggleReady() -> void:
	var status = not GameMetaDataScript.client.isReady
	if not status:
		SignalBusScript.readySetFalse()
	sendChangeToClients("isReady", status)


func selectFaction(index: int) -> void:
	sendChangeToClients("faction", index)


func setTeam(val: float) -> void:
	sendChangeToClients("team", int(val))


func sendChangeToClients(what: String, toWhat) -> void:
	GameMetaDataScript.client[what] = toWhat
	server.lobbyClientChangedState()


func setPlayerNameColor(color: Color) -> void:
	playerName.add_theme_color_override("font_color", color)


func disableKickButton() -> void:
	kickButton.disabled = true
