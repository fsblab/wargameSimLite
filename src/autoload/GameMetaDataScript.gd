extends Node


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
var playerData = {
	faction = SettingsConfigScript.currentPlayerInfo["faction"],
	isReady = false,
	playerName = SettingsConfigScript.currentPlayerInfo["name"],
	team = 1,
	uid = 0
}

var currentPlayMode: playMode
var currentGameMode: gameMode
var currentFaction: faction
var currentSkirmishMode: skirmishMode
var connectedClients: Dictionary
var client: Dictionary


func reset():
	client.merge(playerData, true)
	currentPlayMode = playMode.NONE
	currentGameMode = gameMode.NONE
	currentFaction = faction.NONE
