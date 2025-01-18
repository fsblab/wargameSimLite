extends MarginContainer


@onready var maxPlayersSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxPlayer
@onready var timeLimitToggle: CheckButton = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/InfTime
@onready var matchTimeSpinBox: SpinBox = $HBoxContainer/SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/Time

@onready var mapFolder: DirAccess = DirAccess.open("res://scenes/maps")
@onready var defaultMapImage: Resource = ResourceLoader.load("res://assets/sprites/imageNotFound.png")
@onready var mapImageButton: TextureButton = $HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/mapImage
@onready var mapNameOptionButton: OptionButton = $HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer2/MapNameOptionButton

@onready var mapSize: Label = $HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MapSize
@onready var maxNoTeams: Label = $HBoxContainer/MapContainer/MarginContainer/VBoxContainer/HBoxContainer/GridContainer/MaxNoTeams


func _ready() -> void:
	SignalBusScript._setupLobbySettings.connect(setupLobbySettings)
	SignalBusScript._updateMaxPlayers.connect(updateMaxPlayers)

	for mapName in mapFolder.get_directories():
		mapNameOptionButton.add_item(mapName)
		
	mapNameOptionButton.select(0)
	selectMap(0)


func setupLobbySettings() -> void:
	_updateFogOfWar(GameMetaDataScript.lobby.fogOfWar)
	if GameMetaDataScript.lobby.matchTime:
		_updateTimeLimitToggle(true)
		_updateMatchTime(GameMetaDataScript.lobby.matchTime)
	else:
		_updateTimeLimitToggle(false)
		_updateMatchTime(0)
	selectMapLobbySetup()


func updateMaxPlayers(num: float) -> void:
	while GameMetaDataScript.lobby.maxClients != num and multiplayer.is_server():
		if num < GameMetaDataScript.lobby.maxClients:
			#prioritize removing NONE clients
			var filtered = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x < 20000 and x > 1: return x)
			var id: int
			#if there is no NONE client remove PLAYERPLACEHOLDER instead
			if not filtered:
				filtered = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x < 50000 and x > 30000: return x)
			#at last remove AI
			if not filtered:
				filtered = StdScript.filter(GameMetaDataScript.connectedClients.keys(), func(x): if x < 50000 and x > 1: return x)
			if filtered:
				id = filtered[-1]
			else:
				maxPlayersSpinBox.get_line_edit().text = str(GameMetaDataScript.lobby.maxClients)
				maxPlayersSpinBox.apply()
				return
			SignalBusScript.removeClient.rpc(id)
			GameMetaDataScript.lobby.maxClients -= 1
		else:
			var noneClient: Dictionary = GameMetaDataScript.getNoneData()
			if multiplayer.is_server():
				GameMetaDataScript.connectedClients[noneClient.uid] = noneClient
			SignalBusScript.connectedClientsUpdated.rpc(noneClient)
			GameMetaDataScript.lobby.maxClients += 1
		rpc("_updateMaxPlayerForEveryClient", maxPlayersSpinBox.get_line_edit().text)


@rpc("call_local", "any_peer", "reliable")
func _updateMaxPlayerForEveryClient(num: String) -> void:
	if not multiplayer.is_server():
		maxPlayersSpinBox.get_line_edit().text = str(num)
		maxPlayersSpinBox.apply()


func fogOfWarSelected(index: int) -> void:
	rpc("_updateFogOfWar", index)


@rpc("call_local", "any_peer", "reliable")
func _updateFogOfWar(index: int) -> void:
	GameMetaDataScript.lobby.fogOfWar = index


func toggleMatchTimeLimited(on: bool) -> void:
	if multiplayer.is_server():
		matchTimeSpinBox.get_line_edit().editable = on
		rpc("_updateTimeLimitToggle", on)
		if on:
			GameMetaDataScript.lobby.matchTime = int(matchTimeSpinBox.get_line_edit().text)
			rpc("_updateMatchTime", GameMetaDataScript.lobby.matchTime)
		else:
			GameMetaDataScript.lobby.matchTime = 0


@rpc("call_local", "any_peer", "reliable")
func _updateTimeLimitToggle(on: bool) -> void:
	timeLimitToggle.set_pressed(on)


func setMatchTime(val: float) -> void:
	rpc("_updateMatchTime", int(val))


@rpc("call_local", "authority", "reliable")
func _updateMatchTime(num: int) -> void:
	if not multiplayer.is_server():
		matchTimeSpinBox.get_line_edit().text = str(num if num != 0 else GameMetaDataScript.lobby.matchTime)
		matchTimeSpinBox.apply()
	GameMetaDataScript.lobby.matchTime = num


#executed when joining a lobby as client
func selectMapLobbySetup() -> void:
	_selectMap(GameMetaDataScript.lobby.selectedMap)
	var mapname: String = mapNameOptionButton.get_item_text(mapNameOptionButton.selected)
	var dir: String = mapFolder.get_current_dir() + "/" + mapname + "/"
	readMapInfo(dir)
	setMapImage(dir)


#executed before main menu is loaded and when new map is loaded
func selectMap(index: int) -> void:
	if not multiplayer.get_unique_id() == 1:
		return
	rpc("_selectMap", index)


@rpc("call_local", "any_peer", "reliable")
func _selectMap(index: int) -> void:
	mapNameOptionButton.select(index)
	GameMetaDataScript.lobby.selectedMap = index

	var mapname: String = mapNameOptionButton.get_item_text(mapNameOptionButton.selected)
	var dir: String = mapFolder.get_current_dir() + "/" + mapname + "/"

	readMapInfo(dir)
	setMapImage(dir)


func readMapInfo(dir: String) -> void:
	var mapInfoFile: String = StdScript.getFileNameByExtension(dir, "info|json|txt")
	var jsonString = FileAccess.get_file_as_string(dir + mapInfoFile)
	GameMetaDataScript.mapInfo = JSON.parse_string(jsonString)

	for label in [mapSize, maxNoTeams]:
		if GameMetaDataScript.mapInfo.has(label.name):
			label.text = str(GameMetaDataScript.mapInfo[label.name])
		else:
			label.text = "ಠ╭╮ಠ"


func setMapImage(dir: String) -> void:
	var imgName: String = StdScript.getFileNameByExtension(dir, "jpg|jpeg|png|svg|webp")
	
	if imgName:
		mapImageButton.texture_normal = ResourceLoader.load(dir + imgName)
	else:
		mapImageButton.texture_normal = defaultMapImage
