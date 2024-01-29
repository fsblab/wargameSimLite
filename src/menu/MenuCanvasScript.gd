extends CanvasLayer


@onready var main: Control = $Pause
@onready var settings: Control = $Settings
@onready var menu: Node = get_parent()


func cont():
	menu.visible = false
	visible = false
	get_tree().paused = false


func toSettings():
	main.visible = false
	settings.visible = true


func goBackFromSettings():
	main.visible = true
	settings.visible = false


func backToMainMenu():
	pass


func quitToDesktop():
	get_tree().quit()
