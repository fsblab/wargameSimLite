extends Control


signal startSkirmish(folder: String)
signal goBack()

@onready var mapFolder: DirAccess = DirAccess.open("res://scenes/maps")
@onready var defaultMaps: PackedStringArray = mapFolder.get_directories()
@onready var mapNameOptionButton: OptionButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer2/MapNameOptionButton
@onready var lobbyLeader: HBoxContainer
@onready var clientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer
@onready var message: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var chatBox: TextEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit
@onready var mapImageButton: TextureButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/mapImage
@onready var server: Control = get_tree().get_root().get_node("Start")
@onready var defaultmapImage: Resource = ResourceLoader.load("res://assets/sprites/imageNotFound.png")


func _ready():
	multiplayer.peer_connected.connect(addPlayer)
	
	for mapName in defaultMaps:
		mapNameOptionButton.add_item(mapName)
	mapNameOptionButton.select(0)
	
	setMapImage(0)


func _process(_delta):
	if Input.is_key_pressed(KEY_ENTER) and message.text:
		server.sendChat(message.text)
		message.text = ""


func initSkirmishMenu() -> void:
	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		$CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer.visible = false
		$CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Singleplayer.visible = true
		lobbyLeader = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Singleplayer/SingleplayerPlayerInfo
		lobbyLeader.get_node("OptionButton").select(1)
		lobbyLeader.get_node("OptionButton").disabled = true
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		$CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer.visible = true
		$CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Singleplayer.visible = false
		lobbyLeader = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer/MultiplayerPlayerInfo
		lobbyLeader.setPlayerNameColor(Color("gold"))
		lobbyLeader.disableKickButton()
		lobbyLeader.get_node("OptionButton").select(1)
		lobbyLeader.get_node("OptionButton").disabled = true
	else:
		back()
		return
	lobbyLeader.visible = true


func addPlayer(_id: int):
	var client: Resource = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn")
	clientContainer.add_child(client.instantiate())


func go() -> void:
	startSkirmish.emit(mapNameOptionButton.get_item_text(mapNameOptionButton.selected))


func back() -> void:
	chatBox.text = ""
	message.text = ""
	goBack.emit()


func setMapImage(_index: int) -> void:
	var dir: String = mapFolder.get_current_dir() + "/" + mapNameOptionButton.get_item_text(mapNameOptionButton.selected)
	var imgName: String = getFileByExtension(dir, "jpg|jpeg|png|svg|webp")
	
	if imgName:
		mapImageButton.texture_normal = ResourceLoader.load(dir + imgName)
	else:
		mapImageButton.texture_normal = defaultmapImage


func getFileByExtension(mapDir: String, ext: String) -> String:
	var map: RegEx = RegEx.new()
	map.compile(".+\\.(" + ext + ")$")
	
	var dir: DirAccess = DirAccess.open(mapDir)
	var mapName: String
	
	if dir.get_files().is_empty():
		return ""
	
	#get name of first file that ends in ext
	for file in dir.get_files():
		if (map.search(file)):
			mapName = file
			break
	
	return mapName
