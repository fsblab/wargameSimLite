extends Control


@onready var unsavedChangesdialogWindow: CenterContainer = $UnsavedChangesDialogWindow
@onready var restoreDefaultDialogWindow: CenterContainer = $RestoreDefaultDialogWindow


func saveCurrentSettings() -> void:
	SettingsConfigScript.setSettings()


func revertChangedSettings() -> void:
	SettingsConfigScript.revertSettings()


func restoreDefaultSettings() -> void:
	restoreDefaultDialogWindow.visible = true


func selectAntiAliasing(index: int) -> void:
	SettingsConfigScript.changedSettings["aa"] = SettingsConfigScript.msaaOptions[index]


func selectFPS(index: int) -> void:
	SettingsConfigScript.changedSettings["fps"] = index


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
	
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/AA.select(SettingsConfigScript.currentSettings["aa"])
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/FPS.select(SettingsConfigScript.currentSettings["fps"])
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/Resolution.select(resolutionIndex)
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/ResolutionScale.select(resolutionScaleIndex)
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/ShadowOnOff.button_pressed = SettingsConfigScript.currentSettings["shadow"]
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/ShadowMode.select(SettingsConfigScript.currentSettings["shadowMode"])
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/VSync.select(SettingsConfigScript.currentSettings["vsync"])
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer/WindowMode.select(0 if SettingsConfigScript.currentSettings["windowMode"] == 0 else 1)
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VolumeSlider.value = SettingsConfigScript.currentSettings["volume"]
	$CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VolumeBox.value = SettingsConfigScript.currentSettings["volume"]
