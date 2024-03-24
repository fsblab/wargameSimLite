extends Node


signal connectedClientsUpdated
signal clientDisconnected

enum playMode {
	NONE,
	SINGLEPLAYER,
	MULTIPLAYER
}
enum gameMode {
	NONE,
	SKIRMISH,
	CAMPAIGN
}
enum skirmishMode {
	NONE,
	CONQUEST,
	DESTRUCTION,
	KINGOFTHEHILL
}
enum faction {
	NONE,
	BLACK,
	BLUE,
	GREEN,
	RED,
	YELLOW
}

var currentPlayMode: playMode
var currentGameMode: gameMode
var currentFaction: faction
var currentSkirmishMode: skirmishMode
var connectedClients: Dictionary
var client: Dictionary


func reset():
	client = {
		faction = SettingsConfigScript.currentPlayerInfo["faction"],
		isReady = false,
		playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate(),
		playerName = SettingsConfigScript.currentPlayerInfo["name"],
		team = 1,
		uid = 1
	}
	
	currentPlayMode = playMode.NONE
	currentGameMode = gameMode.NONE
	currentFaction = faction.NONE


func setupPlayerInfoNode(data: Dictionary) -> void:
	data.playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate()
	data.playerInfoNode.get_node("PlayerNameLabel").text = data.playerName
	data.playerInfoNode.get_node("Faction").select(data.faction)
	data.playerInfoNode.get_node("OptionButton").select(1)
	
	if data.uid == 1:
		data.playerInfoNode.get_node("PlayerNameLabel").add_theme_color_override("font_color", Color("gold"))
		data.playerInfoNode.get_node("Kick").disabled = true
	
	if data.uid != multiplayer.get_unique_id():
		data.playerInfoNode.get_node("Faction").disabled = true
		data.playerInfoNode.get_node("Ready").disabled = true
		data.playerInfoNode.get_node("OptionButton").disabled = true
		data.playerInfoNode.get_node("Team").get_line_edit().editable = false
	
	if multiplayer.get_unique_id() != 1:
		data.playerInfoNode.get_node("Kick").disabled = true


func setupSPInfoNode() -> void:
	client.playerInfoNode = ResourceLoader.load("res://scenes/singleplayerPlayerInfo.tscn").instantiate()
	client.playerInfoNode.get_node("PlayerNameLabel").text = client.playerName
	client.playerInfoNode.get_node("Faction").select(client.faction)
	client.playerInfoNode.get_node("OptionButton").select(1)


func setupBotInfoNode() -> void:
	pass
