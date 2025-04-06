extends Control


@onready var canvasLayer = $CanvasLayer

@onready var fps: CenterContainer = $CanvasLayer/FPS
@onready var fpsLabel: Label = $CanvasLayer/FPS/PanelContainer/FPSLabel

@onready var units: CenterContainer = $CanvasLayer/Units
@onready var timeReference: CenterContainer = $CanvasLayer/TimeReference
@onready var readyCountdown: CenterContainer = $CanvasLayer/ReadyCountdown
@onready var miniMap: CenterContainer = $CanvasLayer/MiniMap
@onready var players: CenterContainer = $CanvasLayer/Players
@onready var unitButtons: CenterContainer = $CanvasLayer/UnitButtons
@onready var selectedUnits: CenterContainer = $CanvasLayer/SelectedUnitsInfo

@onready var logUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Logistics/LogisticsUnits
@onready var infUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Infantry/InfantryUnits
@onready var aaUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/AntiAir/AntiAirUnits
@onready var artUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Artillery/ArtilleryUnits
@onready var tnkUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Tank/TankUnits
@onready var rcnUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Reconnaissance/ReconnaissanceUnits
@onready var engUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Engineer/EngineerUnits
@onready var helUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Helicopter/HelicopterUnits
@onready var plnUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Plane/PlaneUnits

@onready var openUnitGroup: CenterContainer = logUnits

@onready var minutesLabel: Label = $CanvasLayer/TimeReference/PanelContainer/MarginContainer/MinutesLabel
@onready var secondsLabel: Label = $CanvasLayer/TimeReference/PanelContainer/MarginContainer/SecondsLabel
@onready var minutesCountdown: Label = $CanvasLayer/ReadyCountdown/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MinutesLabel
@onready var secondsCountdown: Label = $CanvasLayer/ReadyCountdown/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SecondsLabel
@onready var readyPlayersLabel: Label = $CanvasLayer/ReadyCountdown/PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer2/HowManyLabel
@onready var totalPlayersLabel: Label = $CanvasLayer/ReadyCountdown/PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer2/TotalNumberLabel
@onready var readyButtonLabel: Label = $CanvasLayer/ReadyCountdown/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ReadyButton/ReadyLabel
@onready var countdownTimer: Timer = $Countdown

@onready var playerList: VBoxContainer = $CanvasLayer/Players/PanelContainer/MarginContainer/ScrollContainer/PlayerList

@onready var connectedIcon: Texture2D = ResourceLoader.load("res://assets/sprites/connection/connected.png", "Texture2D")
@onready var disconnectedIcon: Texture2D = ResourceLoader.load("res://assets/sprites/connection/disconnected.png", "Texture2D")

@onready var audioPlayer: AudioStreamPlayer = $AudioStreamPlayer
@onready var hornSound: AudioStreamMP3 = ResourceLoader.load("res://assets/sounds/misc/relaxing-music-original-viking-attacking-battle-horn-116623.mp3", "AudioStreamMP3")
@onready var mainBattleMusic: AudioStreamMP3 = ResourceLoader.load("res://assets/sounds/music/80s-retro-beat-001-17882.mp3", "AudioStreamMP3")

var readyPlayers: int = 0

var unitGroups: Dictionary
var minutes: int
var seconds: int

func _ready() -> void:
	unitGroups = {
		"log": logUnits,
		"inf": infUnits,
		"aa": aaUnits,
		"art": artUnits,
		"tnk": tnkUnits,
		"rcn": rcnUnits,
		"eng": engUnits,
		"hel": helUnits,
		"pln": plnUnits
	}

	if not multiplayer.is_server():
		requestPlayerList()
	
	if len(multiplayer.get_peers()):
		await SignalBusScript._playerListReceived

	for container: CenterContainer in [units, timeReference, readyCountdown, miniMap, unitButtons, selectedUnits]:
		if not GameMetaDataScript.client.Faction == GameMetaDataScript.faction.GREY:
			container.modulate = GameMetaDataScript.factionColor.get(int(GameMetaDataScript.client.Faction))

	setupPlayerList()
	setupMatchTime()
	setupCountdown()

	SignalBusScript._selectedUnitChanged.connect(changeUnitInfo)
	SignalBusScript._unitReceivedDamaged.connect(changeUnitHealthpoints)
	SignalBusScript._unitSelected.connect(changeSelectedUnits)
	SignalBusScript._updatePing.connect(updatePing)
	audioPlayer.finished.connect(playMainMusic)

	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.MATCH


func _process(_delta) -> void:
	if Input.is_action_just_released("TAB"):
		openUnitGroup.visible = not openUnitGroup.visible
	
	if UnitSelectionScript.selectedUnits.isEmpty():
		unitButtons.visible = false
	else:
		unitButtons.visible = true


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F11):
		canvasLayer.visible = not canvasLayer.visible


func playMainMusic() -> void:
	audioPlayer.stream = mainBattleMusic
	audioPlayer.play()


func setFPS(pressed: int) -> void:
	fps.visible = pressed


func requestPlayerList() ->  void:
	SignalBusScript.requestPlayerListForUI()


func setupMatchTime() -> void:
	minutes = GameMetaDataScript.lobby.matchTime
	seconds = 0

	minutesLabel.text = str(minutes) if minutes > 9 else str('0', minutes)
	secondsLabel.text = "00"


func setupCountdown() -> void:
	minutes = 1
	seconds = 30

	readyPlayersLabel.text = "0"
	totalPlayersLabel.text = str(len(multiplayer.get_peers()) + 1)


func updateCountdown() -> void:
	var mm: String
	var ss: String

	mm = str(minutes) if minutes > 9 else str('0', minutes)
	ss = "00" if seconds == 60 else str(seconds) if seconds > 9 else str('0', seconds)

	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.BATTLE:
		minutesLabel.text = mm
		secondsLabel.text = ss
	elif GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT:
		minutesCountdown.text = mm
		secondsCountdown.text = ss


func countdownTriggered() -> void:
	if readyPlayers == len(multiplayer.get_peers()) + 1 and multiplayer.is_server() and GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT:
		rpc("_startBattle")

	if seconds == 0:
		if minutes == 0:
			if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.BATTLE and multiplayer.is_server():
				rpc("_endBattle")
			elif GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT and multiplayer.is_server():
				rpc("_startBattle")
			return
		minutes -= 1
		seconds = 60

	seconds -= 1
	updateCountdown()


func readyButtonPressed() -> void:
	if readyButtonLabel.text == "READY":
		readyButtonLabel.text = "CANCEL"
		readyPlayers += 1
	else:
		readyButtonLabel.text = "READY"
		readyPlayers -= 1

	rpc("_toggleCountdown", readyPlayers)


@rpc("any_peer", "call_local", "reliable")
func _toggleCountdown(rdyp: int) -> void:
	readyPlayers = rdyp
	readyPlayersLabel.text = str(rdyp)

	if readyPlayers == 0 and minutes == 0 and seconds < 30:
		seconds = 30
		updateCountdown()

	if readyPlayers > 0:
		countdownTimer.start()
	else:
		countdownTimer.stop()


@rpc("any_peer", "call_local", "reliable")
func _startBattle() -> void:
	GameMetaDataScript.currentBattlePhase = GameMetaDataScript.battlePhase.BATTLE
	readyCountdown.visible = false

	SignalBusScript.startBattle()
	audioPlayer.stream = hornSound
	audioPlayer.play()
	setupMatchTime()


@rpc("any_peer", "call_local", "reliable")
func _endBattle() -> void:
	countdownTimer.stop()
	GameMetaDataScript.currentBattlePhase = GameMetaDataScript.battlePhase.END


func setupPlayerList() -> void:
	var _clients: Array = StdScript.map(GameMetaDataScript.connectedClients.values(), func(client): return {"Faction": client.Faction, "PlayerName": client.PlayerName, "Team": client.Team, "uid": client.uid})
	var clients: Array = StdScript.filter(_clients, func(client): if client.uid == 1 or client.uid >= 40000 or client.uid in range(20000, 30000): return client)
	GameMetaDataScript.connectedClients.clear()

	for player in clients:
		var infoNode: HBoxContainer = ResourceLoader.load("res://scenes/ui/uiPlayerInfoNode.tscn").instantiate()
		var lSettings: LabelSettings = LabelSettings.new()
		
		lSettings.font_color = GameMetaDataScript.factionColor.get(int(player.Faction))
		lSettings.outline_color = Color(0, 0, 0, 1)
		lSettings.outline_size = 4
		lSettings.font_size = 16

		infoNode.name = str(player.uid)
		infoNode.get_node("PlayerName").label_settings = lSettings
		infoNode.get_node("PlayerName").text = player.PlayerName

		if not playerList.has_node(str(player.Team)):
			var teamLabel: Label = Label.new()
			var teamSeperator: HSeparator = HSeparator.new()
			var teamBox: VBoxContainer = VBoxContainer.new()

			teamLabel.name = str("Team", player.Team)
			teamLabel.text = str("Team ", str(player.Team))
			teamBox.name = str(player.Team)

			teamBox.add_child(teamLabel)
			teamBox.add_child(teamSeperator)
			playerList.add_child(teamBox)
		
		playerList.get_node(str(player.Team)).add_child(infoNode)


func changeUnitInfo(unit: Unit, v: bool) -> void:
	selectedUnits.visible = v

	if not v:
		deselectAllUnits()
		return
			
	var ap: Weapon = unit.weapons[UnitAttributesScript.weaponTypes.ARMORPENETRATION]
	var heat: Weapon = unit.weapons[UnitAttributesScript.weaponTypes.HIGHEXPLOSIVE]
	var small: Weapon = unit.weapons[UnitAttributesScript.weaponTypes.SMALLCALIBER]

	var apVbox: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/AP")
	var heatVbox: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/HEAT")
	var smallVbox: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/SMALLARMS")

	for index in range(3):
		if [ap, heat, small][index]:
			[apVbox, heatVbox, smallVbox][index].get_node("TextureButton").texture_normal = [ap, heat, small][index].weaponTexture
			[apVbox, heatVbox, smallVbox][index].get_node("Label").text = [ap, heat, small][index].name + " - " + str([ap, heat, small][index].ammoCapacity)


## changes the health
func changeUnitHealthpoints(unit: Unit) -> void:
	var buttonContainer: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer")

	for button: Button in buttonContainer.get_children():
		if button.name == unit.name:
			button.text = str(GameMetaDataScript.unitString[unit.unitName]) + " | " + str(unit.healthpoints)
			return


## either adds or removes units, nothing else
func changeSelectedUnits(unit: Unit, remove = false) -> void:
	var root: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer")

	if remove:
		if root.has_node(NodePath(unit.name)):
			root.remove_child(root.get_node(NodePath(unit.name)))
			
			if not root.get_child_count():
				selectedUnits.visible = false
	else:
		if root.has_node(NodePath(unit.name)):
			return
		
		var unitButton: Button = Button.new()
		unitButton.name = unit.name
		unitButton.text = str(GameMetaDataScript.unitString[unit.unitName]) + " | " + str(unit.healthpoints)

		#unitButton.pressed.emit(changeUnitInfo, unit, true)

		root.add_child(unitButton)


func deselectAllUnits() -> void:
	var root: VBoxContainer = selectedUnits.get_node("PanelContainer/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer")

	for node: Node in root.get_children():
		root.remove_child(node)


func updatePing(ping: int, nodepath: String) -> void:
	if ping == -1:
		playerList.get_node(nodepath + "/Ping").text = ""
		playerList.get_node(nodepath + "/Connection").set_texture(disconnectedIcon)
		return
	
	ping = ping if GameMetaDataScript.connectedClients.has(nodepath) else 0
	playerList.get_node(nodepath + "/Ping").text = str(ping)

	for ratings in GameMetaDataScript.pingRating:
		if ratings >= ping:
			break
		playerList.get_node(nodepath + "/Ping").add_theme_color_override("font_color", GameMetaDataScript.pingRating[ratings])


func drawFPS() -> void:
	fpsLabel.text = str(Engine.get_frames_per_second())


func toggleLogUnits() -> void:
	toggleShowUnits("log")


func toggleInfUnits() -> void:
	toggleShowUnits("inf")


func toggleAAUnits() -> void:
	toggleShowUnits("aa")


func toggleArtUnits() -> void:
	toggleShowUnits("art")


func toggleTnkUnits() -> void:
	toggleShowUnits("tnk")


func toggleRcnUnits() -> void:
	toggleShowUnits("rcn")


func toggleEngUnits() -> void:
	toggleShowUnits("eng")


func toggleHelUnits() -> void:
	toggleShowUnits("hel")


func togglePlnUnits() -> void:
	toggleShowUnits("pln")


func toggleShowUnits(ug: String) -> void:
	var currentUnitGroup: CenterContainer = unitGroups[ug]
	
	if currentUnitGroup.visible:
		currentUnitGroup.visible = false
	else:
		openUnitGroup.visible = false
		currentUnitGroup.visible = true
		openUnitGroup = currentUnitGroup


func placeMbt() -> void:
	placeUnit(GameMetaDataScript.unitName.MBT)


func placeUnit(unitName: GameMetaDataScript.unitName) -> void:
	SignalBusScript.addUnitToMap(unitName, GameMetaDataScript.client.Faction)
	UnitSelectionScript.deselectAll()
