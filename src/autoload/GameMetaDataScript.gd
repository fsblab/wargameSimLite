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
var playerData: Dictionary


func reset():
	playerData = {
		faction = SettingsConfigScript.currentPlayerInfo["faction"],
		isReady = false,
		playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate(),
		playerName = SettingsConfigScript.currentPlayerInfo["name"],
		team = 1,
		uid = 0
	}
	
	client.merge(playerData, true)
	currentPlayMode = playMode.NONE
	currentGameMode = gameMode.NONE
	currentFaction = faction.NONE


func setupPlayerInfoNode(data: Dictionary) -> void:
	data.playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate()
	data.playerInfoNode.get_node("PlayerNameLabel").text = data.playerName
	data.playerInfoNode.get_node("Faction").select(data.faction)
