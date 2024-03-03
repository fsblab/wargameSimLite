extends Control


@onready var unsavedChangesdialogWindow: CenterContainer = $UnsavedChangesDialogWindow
@onready var restoreDefaultDialogWindow: CenterContainer = $RestoreDefaultDialogWindow


func saveCurrentSettings() -> void:
	SettingsConfigScript.setSettings()


func saveCurrentPlayerInfo() -> void:
	SettingsConfigScript.setPlayerInfo()


func revertChangedSettings() -> void:
	SettingsConfigScript.revertSettings()


func revertChangedPlayerInfo() -> void:
	SettingsConfigScript.revertPlayerInfo()


func restoreDefaultSettings() -> void:
	restoreDefaultDialogWindow.visible = true


func selectAntiAliasing(index: int) -> void:
	SettingsConfigScript.changedSettings["aa"] = SettingsConfigScript.msaaOptions[index]


func selectFPS(pressed: int) -> void:
	SettingsConfigScript.changedSettings["fps"] = pressed


func selectVSync(index: int) -> void:
	SettingsConfigScript.changedSettings["vsync"] = SettingsConfigScript.vsyncOptions[index]


func selectScreenMode(index: int) -> void:
	SettingsConfigScript.changedSettings["windowMode"] = SettingsConfigScript.windowOptions[index]


func selectResolution(index: int) -> void:
	SettingsConfigScript.changedSettings["resolution"] = SettingsConfigScript.resolutionOptions[index]


func selectResolutionScale(index: int) -> void:
	SettingsConfigScript.changedSettings["resolutionScale"] = SettingsConfigScript.resolutionScaleOptions[index]


func selectShadow(pressed: int) -> void:
	SettingsConfigScript.changedSettings["shadow"] = pressed


func selectShadowMode(index: int) -> void:
	SettingsConfigScript.changedSettings["shadowMode"] = SettingsConfigScript.shadowOptions[index]


func selectVolume(value: int) -> void:
	SettingsConfigScript.changedSettings["volume"] = value


func changePlayerFaction(value: int) -> void:
	SettingsConfigScript.changedPlayerInfo["faction"] = value


func changePlayerName(playerName: String) -> void:
	SettingsConfigScript.changedPlayerInfo["name"] = playerName


func goBackFromSettings() -> void:
	if SettingsConfigScript.changedSettings.is_empty():
		visible = false
		return
	unsavedChangesdialogWindow.visible = true


func unsavedChangesDialogWindowYes() -> void:
	SettingsConfigScript.setSettings()
	unsavedChangesdialogWindow.visible = false
	visible = false


func dialogWindowNo() -> void:
	SettingsConfigScript.revertSettings()
	unsavedChangesdialogWindow.visible = false
	visible = false


func dialogWindowCancel() -> void:
	unsavedChangesdialogWindow.visible = false
	restoreDefaultDialogWindow.visible = false


func restoreDefaultDialogWindowYes() -> void:
	SettingsConfigScript.resetSettings()
	restoreDefaultDialogWindow.visible = false
	setComponentValues()


#tried a lot but this abomination is the only solution I could come up with that worked
func setComponentValues() -> void:
	var resolutionIndex: int = SettingsConfigScript.resolutionOptions.find(SettingsConfigScript.currentSettings["resolution"])
	var resolutionScaleIndex: int = 2 if SettingsConfigScript.currentSettings["resolutionScale"] > .8 else 1 if SettingsConfigScript.currentSettings["resolutionScale"] > .6 else 0
	#without the following line of code changedSettings has { "shadow": 1 } randomly stored for some reason and I don't understand why
	SettingsConfigScript.changedSettings.clear()
	
	$CenterContainer/PanelContainer/TabContainer/PlayerInfo/VBoxContainer/GridContainer/LineEdit.text = SettingsConfigScript.currentPlayerInfo["name"]
	$CenterContainer/PanelContainer/TabContainer/PlayerInfo/VBoxContainer/GridContainer/OptionButton.select(SettingsConfigScript.currentPlayerInfo["faction"])

	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/WindowMode.select(0 if SettingsConfigScript.currentSettings["windowMode"] == 0 else 1)
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/AA.select(SettingsConfigScript.currentSettings["aa"])
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/FPS.button_pressed = SettingsConfigScript.currentSettings["fps"]
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/Resolution.select(resolutionIndex)
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/ResolutionScale.select(resolutionScaleIndex)
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/ShadowOnOff.button_pressed = SettingsConfigScript.currentSettings["shadow"]
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/ShadowMode.select(SettingsConfigScript.currentSettings["shadowMode"])
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/GridContainer/VSync.select(SettingsConfigScript.currentSettings["vsync"])
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer/VolumeSlider.value = SettingsConfigScript.currentSettings["volume"]
	$CenterContainer/PanelContainer/TabContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer/VolumeBox.value = SettingsConfigScript.currentSettings["volume"]
