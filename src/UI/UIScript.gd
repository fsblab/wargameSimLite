extends Control


@onready var fps: CenterContainer = $CanvasLayer/FPS
@onready var fpsLabel: Label = $CanvasLayer/FPS/PanelContainer/FPSLabel

@onready var unitButtons: CenterContainer = $CanvasLayer/UnitButtons

@onready var logUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Logistics/LogisticsUnits
@onready var infUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Infantry/InfantryUnits
@onready var aaUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/AntiAir/AntiAirUnits
@onready var artUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Artillery/ArtilleryUnits
@onready var tnkUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Tank/TankUnits
@onready var rcnUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Reconnaissance/ReconnaissanceUnits
@onready var engUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Engineer/EngineerUnits
@onready var helUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Helicopter/HelicopterUnits
@onready var plnUnits: CenterContainer = $CanvasLayer/Units/PanelContainer/MarginContainer/HBoxContainer/Plane/PlaneUnits

@onready var playerList: VBoxContainer = $CanvasLayer/Players/PanelContainer/MarginContainer/CanvasLayer/ScrollContainer/VBoxContainer

@onready var connectedIcon: Texture2D = ResourceLoader.load("res://assets/sprites/connection/connected.png", "Texture2D")
@onready var disconnectedIcon: Texture2D = ResourceLoader.load("res://assets/sprites/connection/disconnected.png", "Texture2D")

@onready var openUnitGroup: CenterContainer = logUnits

var unitGroups: Dictionary


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

	setupPlayerList()

	SignalBusScript._updatePing.connect(updatePing)

	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.MATCH


func _process(_delta) -> void:
	if Input.is_action_just_released("TAB"):
		openUnitGroup.visible = not openUnitGroup.visible
	
	if UnitSelectionScript.selectedUnits.is_empty():
		unitButtons.visible = false
	else:
		unitButtons.visible = true


func setFPS(pressed: int) -> void:
	fps.visible = pressed


func setupPlayerList() -> void:
	for player in GameMetaDataScript.connectedClients.values():
		var infoNode: Control = ResourceLoader.load("res://scenes/ui/uiPlayerInfoNode.tscn").instantiate()
		var lSettings: LabelSettings = LabelSettings.new()

		lSettings.font_color = GameMetaDataScript.factionColor.get(player.faction)
		lSettings.outline_color = Color(0, 0, 0, 1)
		lSettings.font_size = 16

		infoNode.name = str(player.uid)
		infoNode.get_node("PlayerName").label_settings = lSettings
		infoNode.get_node("PlayerName").text = player.playerName
		
		playerList.add_child(infoNode)


func updatePing(ping: int, uid: int) -> void:
	if ping == -1:
		playerList.get_node(str(uid, "/Ping")).text = ""
		playerList.get_node(str(uid, "/Connection")).set_texture(disconnectedIcon)
		return
	
	ping = ping if GameMetaDataScript.connectedClients.has(uid) else 0
	playerList.get_node(str(uid, "/Ping")).text = str(ping)

	for ratings in GameMetaDataScript.pingRating:
		if ratings >= ping:
			break
		playerList.get_node(str(uid, "/Ping")).add_theme_color_override("font_color", GameMetaDataScript.pingRating[ratings])


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
