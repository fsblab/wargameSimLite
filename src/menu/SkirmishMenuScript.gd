extends Control


signal startSkirmish(folder: String)
signal goBack()

@onready var mapFolder: DirAccess = DirAccess.open("res://scenes/maps")
@onready var defaultMaps: PackedStringArray = mapFolder.get_directories()
@onready var mapAndSettingsSplittingPoint: HBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer
@onready var mapNameOptionButton: OptionButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer2/MapNameOptionButton
@onready var mpClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Multiplayer
@onready var spClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/Singleplayer
@onready var message: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var chatBox: TextEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit
@onready var mapImageButton: TextureButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/mapImage
@onready var maxPlayerBox: SpinBox = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer
@onready var readyButton: Button = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/ReadyButton
@onready var timer: Timer = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/Timer
@onready var goButton: Button = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/ReadyButton
@onready var defaultMapImage: Resource = ResourceLoader.load("res://assets/sprites/imageNotFound.png")

var clientContainer: VBoxContainer
var timerCounter: int

func _ready():
	SignalBusScript._connectedClientsUpdated.connect(addPlayer)
	SignalBusScript._clientDisconnected.connect(removePlayer)
	SignalBusScript._abortStartOfMatch.connect(stopCountdown)
	SignalBusScript._cannotConnectToLobby.connect(back)
	
	for mapName in defaultMaps:
		mapNameOptionButton.add_item(mapName)
	
	timerCounter = 5
	
	mapNameOptionButton.select(0)
	setMapImage(0)


func _process(_delta):
	if Input.is_key_pressed(KEY_ENTER) and message.text:
		SignalBusScript.sendChat(message.text)
		message.text = ""


func initSkirmishMenu() -> void:
	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		mpClientContainer.visible = false
		spClientContainer.visible = true
		clientContainer = spClientContainer
		GameMetaDataScript.setupSPInfoNode()
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		mpClientContainer.visible = true
		spClientContainer.visible = false
		clientContainer = mpClientContainer
		GameMetaDataScript.setupPlayerInfoNode(GameMetaDataScript.client)
		maxPlayerBox.value = GameMetaDataScript.lobby.maxClients
		maxPlayerBox.apply()
	else:
		back()
		return
	if multiplayer.get_unique_id() == 1:
		clientContainer.add_child(GameMetaDataScript.client.playerInfoNode)
	goButton.disabled = multiplayer.get_unique_id() != 1


func addPlayer(id: int) -> void:
	StdScript.enableDisableLeaves(mapAndSettingsSplittingPoint, multiplayer.get_unique_id())
	if multiplayer.get_unique_id() == id:
		for player in GameMetaDataScript.connectedClients.values():
			clientContainer.add_child(player.playerInfoNode)
	else:
		clientContainer.add_child(GameMetaDataScript.connectedClients[id].playerInfoNode)


func removePlayer(id: int) -> void:
	if GameMetaDataScript.connectedClients.has(id):
		GameMetaDataScript.connectedClients[id].playerInfoNode.queue_free()


func resetClientContainer() -> void:
	for index in range(2, clientContainer.get_child_count()):
		clientContainer.get_child(index).queue_free()
	GameMetaDataScript.connectedClients.clear()


func go() -> void:
	resetClientContainer()
	timerCounter = 5
	message.text = ""
	chatBox.text = ""
	readyButton.text = "GO"
	startSkirmish.emit(mapNameOptionButton.get_item_text(mapNameOptionButton.selected))


func back(msg: String = '') -> void:
	if not msg == '':
		#TODO: small info box displaying message
		pass
	resetClientContainer()
	chatBox.text = ""
	message.text = ""
	SignalBusScript.disconnectPlayer()
	goBack.emit()


func setMapImage(_index: int) -> void:
	var dir: String = mapFolder.get_current_dir() + "/" + mapNameOptionButton.get_item_text(mapNameOptionButton.selected)
	var imgName: String = StdScript.getFileNameByExtension(dir, "jpg|jpeg|png|svg|webp")
	
	if imgName:
		mapImageButton.texture_normal = ResourceLoader.load(dir + imgName)
	else:
		mapImageButton.texture_normal = defaultMapImage


func chatMessage(pName: String, msg: String) -> void:
	chatBox.text = chatBox.text + str("[", Time.get_time_string_from_system(), "] " , pName, ": ", msg, "\n")
	chatBox.scroll_vertical = INF


func countdown() -> void:
	if timerCounter <= 0:
		go()
		return
	chatMessage("SERVER", "THE MATCH STARTS IN " + str(timerCounter))
	timerCounter = timerCounter - 1


func toggleCountdown() -> void:
	rpc("_toggleCountdown")


@rpc("any_peer", "call_local", "reliable")
func _toggleCountdown() -> void:
	if timer.is_stopped():
		if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
			for client in GameMetaDataScript.connectedClients:
				if GameMetaDataScript.connectedClients[client].isReady == false:
					if multiplayer.get_unique_id() == 1:
						chatMessage('', "EVERYONE IS REQUIRED TO BE READY FOR THE GAME TO START")
					return
		readyButton.text = "CANCEL"
		timer.start()
	else:
		rpc("_stopCountdown")


func stopCountdown() -> void:
	rpc("_stopCountdown")


@rpc("any_peer", "call_local", "reliable")
func _stopCountdown() -> void:
	if not timer.is_stopped():
		chatMessage("SERVER", "MATCH START ABORTED")
	readyButton.text = "GO"
	timer.stop()
	timerCounter = 5
