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


func back() -> void:
	goBack.emit()


func hostInput() -> void:
	hostContainer.visible = true


func cancelHost() -> void:
	hostContainer.visible = false


func hostServer() -> void:
	hostContainer.visible = false
	if not maxPlayers.text:
		maxPlayers.text = maxPlayers.placeholder_text
	if not hostPort.text:
		hostPort.text = "7000"
	openSkirmishLobby.emit(hostPort.text.to_int(), maxPlayers.text.to_int())


func joinInput() -> void:
	joinContainer.visible = true


func cancelJoin() -> void:
	joinContainer.visible = false


func joinServer() -> void:
	joinContainer.visible = false
	joinSkirmishLobby.emit(ip.text, joinPort.text.to_int())
