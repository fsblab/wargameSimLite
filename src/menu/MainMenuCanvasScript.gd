extends CanvasLayer


@onready var main: Control = $MainMenu
@onready var spMenu: Control = $SinglePlayerMenu
@onready var mpMenu: Control = $MultiplayerMenu
@onready var settingsMenu: Control = $Settings
@onready var skirmishMenu: Control = $SkirmishMenu
@onready var popup: PopupPanel = $PopupPanel
@onready var popupText: Label = $PopupPanel/PopupLabel
@onready var root: Control = get_tree().get_root().get_node("Start")


func sp() -> void:
	main.visible = false
	spMenu.visible = true
	
	GameMetaDataScript.currentPlayMode = GameMetaDataScript.playMode.SINGLEPLAYER


func mp() -> void:
	main.visible = false
	mpMenu.visible = true
	
	GameMetaDataScript.currentPlayMode = GameMetaDataScript.playMode.MULTIPLAYER


func skirmish(port: int = 7000, maxPlayers: int = 1) -> void:
	spMenu.visible = false
	mpMenu.visible = false
	skirmishMenu.visible = true
	
	GameMetaDataScript.currentGameMode =  GameMetaDataScript.gameMode.SKIRMISH

	if not root.initServer(port, maxPlayers):
		goBackFromSkirmish()
	
	skirmishMenu.initSkirmishMenu()


func joinSkirmishLobby(ip: String, port: int) -> void:
	spMenu.visible = false
	mpMenu.visible = false
	skirmishMenu.visible = true
	
	GameMetaDataScript.currentGameMode =  GameMetaDataScript.gameMode.SKIRMISH

	if not root.joinServer(ip, port):
		goBackFromSkirmish()
	
	skirmishMenu.initSkirmishMenu()


func goBackFromSkirmish() -> void:
	root.closeConnection()
	skirmishMenu.visible = false
	if GameMetaDataScript.currentPlayMode == GameMetaDataScript.playMode.SINGLEPLAYER:
		spMenu.visible = true
	else:
		mpMenu.visible = true
	GameMetaDataScript.currentGameMode = GameMetaDataScript.gameMode.NONE


func startSkirmish(folder: String) -> void:
	var current: Node
	var mapDir: String = "res://scenes/maps/" + folder + "/"
	var mapName: String = getFileByExtension(mapDir, "tscn")
	
	if not mapName:
		return
	
	var map: Resource = ResourceLoader.load(mapDir + mapName)
	var cam: Resource = ResourceLoader.load("res://scenes/camera.tscn")
	var pauseMenu: Resource = ResourceLoader.load("res://scenes/pauseMenu.tscn")
	
	for child in root.get_children():
		child.queue_free()
	
	current = cam.instantiate()
	current.translate(Vector3.UP * 2 - Vector3.FORWARD * 4)
	root.add_child(current)
	
	current = pauseMenu.instantiate()
	root.add_child(current)
	current.visible = false
	
	current = map.instantiate()
	root.add_child(current)
	
	get_tree().call_group("UI", "setFPS", SettingsConfigScript.currentSettings["fps"])
	
	get_tree().set_current_scene(root)


func getFileByExtension(mapDir: String, ext: String) -> String:
	var map: RegEx = RegEx.new()
	map.compile(".+\\.(" + ext + ")$")
	
	var dir: DirAccess = DirAccess.open(mapDir)
	var mapName: String
	
	if dir.get_files().is_empty():
		popupText.text = "ERROR: The folder for this map is empty."
		popup.visible = true
		return ""
	
	#get name of first file that ends in ext
	for file in dir.get_files():
		if (map.search(file)):
			mapName = file
			break
	
	if (not map.search(mapName)):
		popupText.text = "ERROR: No map file could be found. Make sure the map file ends in '." + ext + "'."
		popup.visible = true
		return ""
	
	return mapName


func campaign() -> void:
	pass


func armory() -> void:
	pass


func goBackFromPlayerMenu() -> void:
	spMenu.visible = false
	mpMenu.visible = false
	main.visible = true
	
	GameMetaDataScript.currentPlayMode = GameMetaDataScript.playMode.NONE


func toSettings() -> void:
	main.visible = false
	settingsMenu.visible = true


func goBackFromSettings() -> void:
	main.visible = true


func quitToDesktop() -> void:
	get_tree().quit()
