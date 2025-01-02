extends Node


@onready var mpInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn")
@onready var spInfoNode = ResourceLoader.load("res://scenes/singleplayerPlayerInfo.tscn")

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
enum gameState {
	MENUS,
	LOBBY,
	LOADING,
	MATCH
}
enum battlePhase {
	UNITPLACEMENT,
	BATTLE,
	END
}
enum faction {
	NONE,
	BLACK,
	BLUE,
	GREEN,
	RED,
	YELLOW
}
enum playerType {
	NONE,
	PLAYER,
	AI,
	VIEWER
}
enum aiType {
	NONE,
	EASY
}
enum fogOfWar {
	NONE,
	SOLO,
	TEAM
}

const factionColor = {
	faction.NONE: Color8(255, 255, 255),
	faction.BLACK: Color8(0, 0, 0),
	faction.BLUE: Color8(0, 255, 255),
	faction.GREEN: Color8(0, 255, 0),
	faction.RED: Color8(255, 0, 0),
	faction.YELLOW: Color8(255, 255, 0)
}

const pingRating = {
	0: Color8(0, 255, 0),
	100: Color8(255, 255, 0),
	400: Color8(255, 0, 0)
}

const aiNames = {
	aiType.NONE: "",
	aiType.EASY: "EASY AI"
}

var currentPlayMode: playMode
var currentGameMode: gameMode
var currentSkirmishMode: skirmishMode
var currentGameState: gameState
var currentBattlePhase: battlePhase
var connectedClients: Dictionary
var client: Dictionary
var lobby: Dictionary
var botId: int
var noneId: int
var playerPlaceholderId: int
var tmpMatchTimeStorage: int


func reset() -> void:
	resetClient()
	
	resetLobby()

	noneId = 10000
	botId = 20000
	playerPlaceholderId = 30000
	
	currentPlayMode = playMode.NONE
	currentGameMode = gameMode.NONE
	currentGameState = gameState.MENUS
	currentBattlePhase = battlePhase.UNITPLACEMENT


func resetClient() -> void:
	client = {
		Faction = SettingsConfigScript.currentPlayerInfo["faction"],
		Ready = false,
		Ping = 0,
		PlayerName = SettingsConfigScript.currentPlayerInfo["name"],
		Team = 1,
		uid = 0
	}


func resetLobby() -> void:
	lobby = {
		checksum = 0,
		selectedMap = "",
		maxClients = 0,
		totalClients = 0,
		fogOfWar = fogOfWar.TEAM,
		matchTime = 40
	}


func setupSPInfoNode() -> void:
	client.playerInfoNode = spInfoNode.instantiate()
	client.playerInfoNode.get_node("PlayerName").text = client.playerName
	client.playerInfoNode.get_node("Faction").select(client.faction)
	client.playerInfoNode.get_node("OptionButton").select(1)


#TODO
func getViewerData() -> Dictionary:
	return {}


func getPlayerPlaceholderData() -> Dictionary:
	playerPlaceholderId = playerPlaceholderId + 1 if playerPlaceholderId < 40000 else 30000
	while playerPlaceholderId in connectedClients:
		playerPlaceholderId = playerPlaceholderId + 1 if playerPlaceholderId < 40000 else 30000
	var data = {
		Faction = faction.NONE,
		Ready = false,
		Ping = 0,
		PlayerName = "PLAYER",
		Team = 1,
		uid = playerPlaceholderId
	}
	return data


func getBotData() -> Dictionary:
	botId = botId + 1 if botId < 30000 else 20000
	while botId in connectedClients:
		botId = botId + 1 if botId < 30000 else 20000
	var data = {
		Faction = SettingsConfigScript.currentPlayerInfo["faction"],
		Ready = true,
		Ping = 0,
		PlayerName = aiNames[aiType.EASY],
		Team = 1,
		uid = botId
	}
	return data


func getNoneData() -> Dictionary:
	noneId = noneId + 1 if noneId < 20000 else 10000
	while noneId in connectedClients:
		noneId = noneId + 1 if noneId < 20000 else 10000
	var data = {
		Faction = faction.NONE,
		Ready = true,
		Ping = 0,
		PlayerName = "NONE",
		Team = 1,
		uid = noneId
	}
	return data
