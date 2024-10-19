extends Control


signal goBack
signal openSkirmishLobby
signal joinSkirmishLobby

@onready var joinContainer: CenterContainer = $JoinContainer
@onready var hostContainer: CenterContainer = $hostContainer
@onready var ip: LineEdit = $JoinContainer/MarginContainer/VBoxContainer/IpAndPort/Ip
@onready var joinPort: LineEdit = $JoinContainer/MarginContainer/VBoxContainer/IpAndPort/Port
@onready var maxPlayers: LineEdit = $hostContainer/MarginContainer/VBoxContainer/IpAndPort/MaxPlayers
@onready var hostPort: LineEdit = $hostContainer/MarginContainer/VBoxContainer/IpAndPort/Port
@onready var popupPanel: PopupPanel = $PopupPanel
@onready var popupText: Label = $PopupPanel/PopupLabel


func _ready() -> void:
	SignalBusScript._cannotConnectToLobby.connect(cancelJoin)


func back() -> void:
	goBack.emit()


func hostInput() -> void:
	hostContainer.visible = true


func cancelHost() -> void:
	hostContainer.visible = false


func hostServer() -> void:
	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOADING

	hostContainer.visible = false
	
	if not maxPlayers.text:
		maxPlayers.text = maxPlayers.placeholder_text
	if not hostPort.text:
		hostPort.text = "7000"
	
	GameMetaDataScript.lobby.maxClients = maxPlayers.text.to_int()
	GameMetaDataScript.lobby.maxClients = 1 if GameMetaDataScript.lobby.maxClients < 1 else 4095 if GameMetaDataScript.lobby.maxClients > 4095 else GameMetaDataScript.lobby.maxClients
	openSkirmishLobby.emit(hostPort.text.to_int(), 4095)

	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOBBY


func joinInput() -> void:
	joinContainer.visible = true


func cancelJoin(msg = '') -> void:
	if msg:
		popupPanel.show()
		popupText.text = msg
	joinContainer.visible = false


func joinServer() -> void:
	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOADING

	joinContainer.visible = false
	joinSkirmishLobby.emit(ip.text, joinPort.text.to_int())

	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOBBY
