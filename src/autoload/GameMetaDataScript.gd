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
	GREY,
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
enum unitName {
	NONE,
	INF,
	SPAAG,
	MBT,
	ASF
}

const unitString: Dictionary = {
	unitName.NONE: "",
	unitName.INF: "Infantry",
	unitName.SPAAG: "SPAAG",
	unitName.MBT: "Main Battle Tank",
	unitName.ASF: "AS Fighter",
}

const unitDirectories: Dictionary = {
	unitName.MBT: "res://scenes/units/tank_unit.tscn",
}

const teamMaterials: Dictionary = {
	faction.NONE: ["res://assets/materials/noneUnit.tres", "res://assets/materials/noneUnit.tres", "res://assets/materials/noneUnit.tres"],
	faction.GREY: ["res://assets/materials/greyUnitPlacement.tres", "res://assets/materials/greyUnitNotSelected.tres", "res://assets/materials/greyUnitSelected.tres"],
	faction.BLUE: ["res://assets/materials/blueUnitPlacement.tres", "res://assets/materials/blueUnitNotSelected.tres", "res://assets/materials/blueUnitSelected.tres"],
	faction.GREEN: ["res://assets/materials/greenUnitPlacement.tres", "res://assets/materials/greenUnitNotSelected.tres", "res://assets/materials/greenUnitSelected.tres"],
	faction.RED: ["res://assets/materials/redUnitPlacement.tres", "res://assets/materials/redUnitNotSelected.tres", "res://assets/materials/redUnitSelected.tres"],
	faction.YELLOW: ["res://assets/materials/yellowUnitPlacement.tres", "res://assets/materials/yellowUnitNotSelected.tres", "res://assets/materials/yellowUnitSelected.tres"]
}

const factionColor: Dictionary = {
	faction.NONE: Color8(255, 255, 255),
	faction.GREY: Color8(80, 80, 80),
	faction.BLUE: Color8(0, 255, 255),
	faction.GREEN: Color8(0, 255, 0),
	faction.RED: Color8(255, 0, 0),
	faction.YELLOW: Color8(255, 255, 0)
}

const pingRating: Dictionary = {
	0: Color8(0, 255, 0),
	100: Color8(255, 255, 0),
	400: Color8(255, 0, 0)
}

const aiNames: Dictionary = {
	aiType.NONE: "",
	aiType.EASY: "EASY AI"
}

var currentPlayMode: playMode
var currentGameMode: gameMode
var currentSkirmishMode: skirmishMode
var currentGameState: gameState
var currentBattlePhase: battlePhase
var connectedClients: Dictionary
var mapInfo: Dictionary
var client: Dictionary
var lobby: Dictionary
var botId: int
var noneId: int
var playerPlaceholderId: int


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
		Faction = SettingsConfigScript.currentPlayerInfo["Faction"] if SettingsConfigScript.currentPlayerInfo.has("Faction") else 0,
		Ready = false,
		Ping = 0,
		PlayerName = SettingsConfigScript.currentPlayerInfo["PlayerName"] if SettingsConfigScript.currentPlayerInfo.has("PlayerName") else "",
		Team = 1,
		uid = 0
	}


func resetLobby() -> void:
	lobby = {
		checksum = 0,
		selectedMap = 0,
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
		Faction = SettingsConfigScript.currentPlayerInfo["Faction"],
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
