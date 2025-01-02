extends Control


signal startSkirmish(folder: String)
signal goBack

@onready var mapFolder: DirAccess = DirAccess.open("res://scenes/maps")
@onready var defaultMaps: PackedStringArray = mapFolder.get_directories()
@onready var mapAndSettingsSplittingPoint: HBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer
@onready var mapNameOptionButton: OptionButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer2/MapNameOptionButton
@onready var mpClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/MultiplayerScrollContainer/Multiplayer
@onready var spClientContainer: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/PlayerInfoContainer/MarginContainer/SingleplayerScrollContainer/Singleplayer
@onready var message: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var chatBox: TextEdit = $CenterContainer/MarginContainer/VBoxContainer/PlayerInfoChatContainer/ChatContainer/MarginContainer/VBoxContainer/TextEdit
@onready var mapImageButton: TextureButton = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/mapImage
@onready var maxPlayerBox: SpinBox = $CenterContainer/MarginContainer/VBoxContainer/MapSettingsContainer/HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer
@onready var readyButton: Button = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/ReadyButton
@onready var timer: Timer = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/Timer
@onready var goButton: Button = $CenterContainer/MarginContainer/VBoxContainer/BottomButtonsContainer/ReadyButton

@onready var defaultMapImage: Resource = ResourceLoader.load("res://assets/sprites/imageNotFound.png")
@onready var mpInfoNode: Resource = ResourceLoader.load("res://scenes/multiplayerPlayerInfo.tscn")
@onready var spInfoNode: Resource = ResourceLoader.load("res://scenes/singleplayerPlayerInfo.tscn")

var clientContainer: VBoxContainer
var timerCounter: int

func _ready():
	SignalBusScript._abortStartOfMatch.connect(stopCountdown)
	SignalBusScript._cannotConnectToLobby.connect(back)
	SignalBusScript._changeNodeName.connect(changeId)
	SignalBusScript._clientDisconnected.connect(clientDC)
	SignalBusScript._connectedClientsUpdated.connect(addPlayer)
	SignalBusScript._enableDisableInfoNode.connect(enableDisableInfoNode)
	SignalBusScript._removeClient.connect(removePlayer)
	SignalBusScript._updatePlayer.connect(updatePlayer)
	
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
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		mpClientContainer.visible = true
		spClientContainer.visible = false
		clientContainer = mpClientContainer
	else:
		back()
		return
	if multiplayer.get_unique_id() == 1:
		addPlayer(GameMetaDataScript.client)
		maxPlayerBox.get_line_edit().text = str(GameMetaDataScript.lobby.maxClients)
		GameMetaDataScript.lobby.maxClients = 1 #HACK: might require rework
		maxPlayerBox.apply()
	goButton.disabled = multiplayer.get_unique_id() != 1


func addPlayer(client: Dictionary) -> void:
	var infoNode: HBoxContainer

	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		infoNode = spInfoNode.instantiate()
		infoNode.get_node("PlayerName").text = client.PlayerName
		infoNode.get_node("Faction").select(client.Faction)
		infoNode.get_node("Player").select(1 if client.uid > 30000 or client.uid == 1 else 2 if client.uid > 20000 else 0)
		infoNode.get_node("Player").set_item_disabled(2, true)
		infoNode.get_node("Player").set_item_disabled(0, true)
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		infoNode = mpInfoNode.instantiate()
		infoNode.get_node("PlayerName").text = client.PlayerName
		infoNode.get_node("Faction").select(client.Faction)
		infoNode.get_node("Player").select(1 if client.uid > 30000 or client.uid == 1 else 2 if client.uid > 20000 else 0)
		infoNode.get_node("Player").set_item_disabled(2, true)
		infoNode.get_node("Player").set_item_disabled(0, true)
		infoNode.get_node("Ready").text = "✔️" if client.Ready else "❌"
		infoNode.get_node("Ping").text = str(client.Ping)
		
		if client.uid == 1:
			infoNode.get_node("PlayerName").add_theme_color_override("font_color", Color("gold"))
			infoNode.get_node("Kick").disabled = true
	
		if client.uid != multiplayer.get_unique_id():
			infoNode.get_node("Faction").disabled = true
			infoNode.get_node("Ready").disabled = true
			infoNode.get_node("Player").disabled = true
			infoNode.get_node("Team").get_line_edit().editable = false
		
		if multiplayer.get_unique_id() != 1:
			infoNode.get_node("Kick").disabled = true
	
	if multiplayer.is_server() and client.uid < 40000 and not client.uid == 1:
		infoNode.get_node("Player").disabled = false
		infoNode.get_node("Player").set_item_disabled(2, false)
		infoNode.get_node("Player").set_item_disabled(0, false)


	infoNode.name = str(client.uid)
	StdScript.enableDisableLeaves(mapAndSettingsSplittingPoint, multiplayer.get_unique_id())
	clientContainer.add_child(infoNode)

	if client.uid < 30000 or client.uid > 40000:
		GameMetaDataScript.lobby.totalClients += 1


func updatePlayer(id: String, what: String, toWhat) -> void:
	var node: Control = clientContainer.get_node(str(id, "/", what))
	if what == "Ready":
		node.text = "✔️" if toWhat else "❌"
	elif what == "Team":
		node.get_line_edit().text = str(toWhat)
		node.apply()
	elif what in ["Faction", "Player"]:
		node.select(toWhat)
	elif what in ["PlayerName", "Ping"]:
		node.text = toWhat


func changeId(id: String, newId: String) -> void:
	clientContainer.get_node(id).name = newId

	var n_id: int = id.to_int()
	var n_newid: int = newId.to_int()

	if (n_id < 30000 or n_id > 40000) and (n_newid > 30000 or n_newid < 40000):
		GameMetaDataScript.lobby.totalClients -= 1
	elif (n_id > 30000 or n_id < 40000) and (n_newid < 30000 or n_newid > 40000):
		GameMetaDataScript.lobby.totalClients += 1

	SignalBusScript.changeNodeNameCompleted()


func enableDisableInfoNode(id: int) -> void:
	var infoNode: HBoxContainer = clientContainer.get_node(str(id))

	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		pass # TODO
	elif GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
		infoNode.get_node("Player").set_item_disabled(0, true)
		infoNode.get_node("Player").set_item_disabled(2, true)
		
		if id == 1:
			infoNode.get_node("PlayerName").add_theme_color_override("font_color", Color("gold"))
			infoNode.get_node("Kick").disabled = true
	
		if id != multiplayer.get_unique_id() or (id == multiplayer.get_unique_id() and GameMetaDataScript.client.Ready):
			infoNode.get_node("Ready").disabled = false if id == multiplayer.get_unique_id() and GameMetaDataScript.client.Ready else true
			infoNode.get_node("Faction").disabled = true
			infoNode.get_node("Player").disabled = true
			infoNode.get_node("Team").get_line_edit().editable = false
		else:
			infoNode.get_node("Ready").disabled = false
			infoNode.get_node("Faction").disabled = false
			infoNode.get_node("Player").disabled = false
			infoNode.get_node("Team").get_line_edit().editable = true
		
		if multiplayer.get_unique_id() != 1:
			infoNode.get_node("Kick").disabled = true
	
	if multiplayer.is_server() and id < 40000 and not id == 1:
		infoNode.get_node("Player").disabled = false
		infoNode.get_node("Player").set_item_disabled(2, false)
		infoNode.get_node("Player").set_item_disabled(0, false)

	StdScript.enableDisableLeaves(mapAndSettingsSplittingPoint, multiplayer.get_unique_id())


func removePlayer(id: int) -> void:
	if str(id) in StdScript.map(clientContainer.get_children(), func(n): return n.name):
		clientContainer.get_node(str(id)).queue_free()
		GameMetaDataScript.connectedClients.erase(id)
		if id < 30000 or id > 50000:
			GameMetaDataScript.lobby.totalClients -= 1


func clientDC(id: int) -> void:
	var data = GameMetaDataScript.getPlayerPlaceholderData()
	changeId(str(id), str(data.uid))

	if multiplayer.is_server():
		GameMetaDataScript.connectedClients.erase(id)
		GameMetaDataScript.connectedClients[data.uid] = data

	for d in ["Ready", "Faction", "Team", "PlayerName"]:
		updatePlayer(str(data.uid), d, data[d])
	enableDisableInfoNode(data.uid)


func resetClientContainer(disconnecting = true) -> void:
	for index in range(2, clientContainer.get_child_count()):
		clientContainer.get_child(index).queue_free()
	if disconnecting:
		GameMetaDataScript.resetClient()
		GameMetaDataScript.lobby.maxClients = 0
		GameMetaDataScript.lobby.totalClients = 0


func go() -> void:
	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOADING
	resetClientContainer(false)
	timerCounter = 5
	message.text = ""
	chatBox.text = ""
	readyButton.text = "GO"
	startSkirmish.emit(mapNameOptionButton.get_item_text(mapNameOptionButton.selected))


func back(msg: String = '') -> void:
	SignalBusScript.toggleLoadingScreen()
	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOADING
	if msg:
		#TODO: small info box/ popup displaying message
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
	if multiplayer.get_unique_id() == 1:
		if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.MULTIPLAYER:
			for client in GameMetaDataScript.connectedClients:
				if GameMetaDataScript.connectedClients[client].Ready == false:
					chatMessage('', "EVERYONE IS REQUIRED TO BE READY FOR THE GAME TO START")
					return
		StdScript.enableDisableLeaves(mapAndSettingsSplittingPoint, 0)
		rpc("_toggleCountdown")


@rpc("any_peer", "call_local", "reliable")
func _toggleCountdown() -> void:
	if timer.is_stopped():
		readyButton.text = "CANCEL"
		timer.start()
	else:
		if multiplayer.is_server():
			StdScript.enableDisableLeaves(mapAndSettingsSplittingPoint, 1)
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
