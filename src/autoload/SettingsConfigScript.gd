extends Node

var msaaOptions = [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X
]
var resolutionOptions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
	Vector2i(5120, 2880),
	Vector2i(7680, 4320)
]
var resolutionScaleOptions = [
	.5,
	.75,
	1
]
var shadowOptions = [
	DirectionalLight3D.SHADOW_ORTHOGONAL,
	DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS,
	DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
]
var vsyncOptions = [
	DisplayServer.VSYNC_DISABLED,
	DisplayServer.VSYNC_ADAPTIVE,
	DisplayServer.VSYNC_ENABLED,
	DisplayServer.VSYNC_MAILBOX
]
var windowOptions = [
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_FULLSCREEN
]


var defaultSettings = {
		"aa": msaaOptions[0],
		"fps": false,
		"resolution": DisplayServer.screen_get_size(),
		"resolutionScale": resolutionScaleOptions[2],
		"shadow": true,
		"shadowMode": shadowOptions[2],
		"volume": 100,
		"vsync": vsyncOptions[0],
		"windowMode": windowOptions[1]
	}


var currentSettings = {
		"aa": msaaOptions[0],
		"fps": false,
		"resolution": DisplayServer.screen_get_size(),
		"resolutionScale": resolutionScaleOptions[2],
		"shadow": true,
		"shadowMode": shadowOptions[2],
		"volume": 100,
		"vsync": vsyncOptions[0],
		"windowMode": windowOptions[1]
	}


var changedSettings = {}


var defaultPlayerInfo = {
	"faction": GameMetaDataScript.faction.NONE,
	"name": ""
}


var currentPlayerInfo = {
	"faction": GameMetaDataScript.faction.NONE,
	"name": ""
}


var changedPlayerInfo = {}


func _ready():
	readSettingsConfig()
	setSettings()


func readSettingsConfig() -> void:
	if not FileAccess.file_exists("user://settings.config"):
		writeSettingsConfig()
		return
	
	var file: FileAccess = FileAccess.open("user://settings.config", FileAccess.READ)
	var jsonString: String = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(jsonString)
	
	if not error == OK:
		writeSettingsConfig()
		return
	
	var width: RegEx = RegEx.new()
	width.compile("\\d+")
	var height: RegEx = RegEx.new()
	height.compile("(?<=,).*\\d+")
	
	var player: Dictionary = json.data["playerinfo"]
	var settings: Dictionary = json.data["settings"]
	
	settings["resolution"] = Vector2i(int(width.search(settings["resolution"]).get_string()), int(height.search(settings["resolution"]).get_string()))
	
	currentPlayerInfo = player
	currentSettings = settings
	setSettings()


func setSettings() -> void:
	if changedSettings.is_empty():
		return
	
	for setting in changedSettings:
		currentSettings[setting] = changedSettings[setting]
	
	DisplayServer.window_set_mode(currentSettings["windowMode"])
	get_viewport().msaa_3d = msaaOptions[currentSettings["aa"]]
	get_tree().call_group("UI", "setFPS", currentSettings["fps"])
	DisplayServer.window_set_size(currentSettings["resolution"])
	get_viewport().scaling_3d_scale = resolutionScaleOptions[currentSettings["resolutionScale"]]
	get_tree().call_group("Lights", "setShadow", currentSettings["shadow"])
	get_tree().call_group("Lights", "setDirectionalShadowMode", currentSettings["shadowMode"])
	if currentSettings["volume"] == 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, linear_to_db(currentSettings["volume"] / 100.))
	DisplayServer.window_set_vsync_mode(vsyncOptions[currentSettings["vsync"]])
	
	changedSettings.clear()
	
	writeSettingsConfig()


func setPlayerInfo() -> void:
	if changedPlayerInfo.is_empty():
		return
	
	for info in changedPlayerInfo:
		currentPlayerInfo[info] = changedPlayerInfo[info]
	
	GameMetaDataScript.client.faction = currentPlayerInfo["faction"]
	GameMetaDataScript.client.playerName = currentPlayerInfo["name"]
	
	changedPlayerInfo.clear()
	
	writeSettingsConfig()


func writeSettingsConfig() -> void:
	var file = FileAccess.open("user://settings.config", FileAccess.WRITE)
	var data = {"settings": currentSettings, "playerinfo": currentPlayerInfo}
	file.store_line(JSON.stringify(data, "\t"))
	file.close()


func revertSettings() -> void:
	changedSettings.clear()


func revertPlayerInfo() -> void:
	changedPlayerInfo.clear()


func resetSettings() -> void:
	currentSettings = defaultSettings.duplicate(true)
	setSettings()
