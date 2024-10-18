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
enum gameState {
	MENUS,
	LOBBY,
	LOADING,
	MATCH
}
enum faction {
	NONE,
	BLACK,
	BLUE,
	GREEN,
	RED,
	YELLOW
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

var currentPlayMode: playMode
var currentGameMode: gameMode
var currentSkirmishMode: skirmishMode
var currentGameState: gameState
var connectedClients: Dictionary
var client: Dictionary
var lobby: Dictionary


func reset() -> void:
	client = {
		faction = SettingsConfigScript.currentPlayerInfo["faction"],
		isReady = false,
		ping = 0,
		playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate(1),
		playerName = SettingsConfigScript.currentPlayerInfo["name"],
		team = 1,
		uid = 1
	}
	
	lobby = {
		checksum = 0,
		selectedMap = "",
		maxClients = 2
	}
	
	currentPlayMode = playMode.NONE
	currentGameMode = gameMode.NONE
	currentGameState = gameState.MENUS



func setupPlayerInfoNode(data: Dictionary) -> void:
	data.playerInfoNode = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn").instantiate()
	data.playerInfoNode.get_node("PlayerNameLabel").text = data.playerName
	data.playerInfoNode.get_node("Faction").select(data.faction)
	data.playerInfoNode.get_node("OptionButton").select(1)
	data.playerInfoNode.get_node("OptionButton").set_item_disabled(2, true)
	data.playerInfoNode.get_node("Ready").text = "✔️" if data.isReady else "❌"
	data.playerInfoNode.get_node("Ping").text = str(data.ping)
	
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


func updatePlayerInfoNode(data: Dictionary) -> void:
	connectedClients[data.uid].isReady = data.isReady
	connectedClients[data.uid].faction = data.faction
	connectedClients[data.uid].team = data.team
	connectedClients[data.uid].ping = data.ping
	
	var obj = instance_from_id(connectedClients[data.uid].playerInfoNode.get_instance_id())
	
	obj.get_node("Ready").text = "✔️" if data.isReady else "❌"
	obj.get_node("Faction").select(data.faction)
	obj.get_node("Team").get_line_edit().text = str(data.team)
	obj.get_node("Ping").text = str(data.ping)

	for ping in pingRating:
		if ping >= data.ping:
			break
		obj.get_node("Ping").add_theme_color_override("font_color", pingRating[ping])


func setupBotInfoNode() -> void:
	pass
