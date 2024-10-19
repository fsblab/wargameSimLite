extends CanvasLayer


@onready var pause: Control = $Pause
@onready var settings: Control = $Settings
@onready var menu: Node = get_parent()


func cont() -> void:
	menu.visible = false
	visible = false
	get_tree().paused = false


func toSettings() -> void:
	pause.visible = false
	settings.visible = true


func goBackFromSettings() -> void:
	pause.visible = true


func backToMainMenu() -> void:
	GameMetaDataScript.currentGameState = GameMetaDataScript.gameState.LOADING
	SignalBusScript.disconnectPlayer()

	get_tree().paused = false
	
	var root = get_tree().get_root().get_node("Start")
	var current: Node
	
	for child in root.get_children():
		child.queue_free()
	
	var main = ResourceLoader.load("res://scenes/mainMenu.tscn")
	
	current = main.instantiate()
	root.add_child(current)
	
	GameMetaDataScript.reset()
	
	get_tree().set_current_scene(root)


func quitToDesktop() -> void:
	SignalBusScript.disconnectPlayer()
	get_tree().quit()
