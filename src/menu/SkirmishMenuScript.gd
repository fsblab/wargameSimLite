extends Control


signal startSkirmish(folder: String)
signal goBack()

@onready var mapFolder: DirAccess = DirAccess.open("res://scenes/maps")
@onready var defaultMaps: PackedStringArray = mapFolder.get_directories()
@onready var mapNameOptionButton: OptionButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer2/MapNameOptionButton
@onready var lobbyLeader: HBoxContainer
@onready var mpClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer
@onready var spClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Singleplayer
@onready var clientContainer: VBoxContainer
@onready var message: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var chatBox: TextEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit
@onready var mapImageButton: TextureButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/mapImage
@onready var server: Control = get_tree().get_root().get_node("Start")
@onready var defaultmapImage: Resource = ResourceLoader.load("res://assets/sprites/imageNotFound.png")


func _ready():
	GameMetaDataScript.connectedClientsUpdated.connect(addPlayer)
	GameMetaDataScript.clientDisconnected.connect(removePlayer)
	
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
		mpClientContainer.visible = false
		spClientContainer.visible = true
		clientContainer = spClientContainer
		lobbyLeader = ResourceLoader.load("res://scenes/singleplayerPlayerInfo.tscn").instantiate()
		lobbyLeader.get_node("OptionButton").select(1)
		lobbyLeader.get_node("OptionButton").disabled = true
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		mpClientContainer.visible = true
		spClientContainer.visible = false
		clientContainer = mpClientContainer
		GameMetaDataScript.setupPlayerInfoNode(GameMetaDataScript.client)
	else:
		back()
		return
	if multiplayer.get_unique_id() == 1:
		clientContainer.add_child(GameMetaDataScript.client.playerInfoNode)


func addPlayer(id: int) -> void:
	if multiplayer.get_unique_id() == id:
		for player in GameMetaDataScript.connectedClients.values():
			print(multiplayer.get_unique_id(), " added ", player.playerInfoNode.get_node("PlayerNameLabel").text)
			clientContainer.add_child(player.playerInfoNode)
	else:
		print(multiplayer.get_unique_id(), " added ", GameMetaDataScript.connectedClients[id].playerInfoNode.get_node("PlayerNameLabel").text)
		clientContainer.add_child(GameMetaDataScript.connectedClients[id].playerInfoNode)


func removePlayer(id: int) -> void:
	GameMetaDataScript.connectedClients[id].playerInfoNode.queue_free()


func resetClientContainer() -> void:
	for player in clientContainer.get_children():
		player.queue_free()
	print(GameMetaDataScript.connectedClients)
	GameMetaDataScript.connectedClients.clear()


func go() -> void:
	startSkirmish.emit(mapNameOptionButton.get_item_text(mapNameOptionButton.selected))
	#get_tree().force_update_transform()


func back() -> void:
	resetClientContainer()
	chatBox.text = ""
	message.text = ""
	server.disconnectPlayer()
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
	
	if dir.get_files().is_empty():
		return ""
	
	#get name of first file that ends in ext
	for file in dir.get_files():
		if (map.search(file)):
			return file
	
	return ""
