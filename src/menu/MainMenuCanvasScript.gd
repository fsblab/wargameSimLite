extends CanvasLayer


@onready var main: Control = $MainMenu
@onready var settings: Control = $Settings


func sp():
	var root = get_tree().get_root()
	var current = root.get_child(2)
	
	current.queue_free()
	
	var singleplayer = ResourceLoader.load("res://scenes/functionalityTest.tscn")
	var cam = ResourceLoader.load("res://scenes/camera.tscn")
	var pauseMenu = ResourceLoader.load("res://scenes/pauseMenu.tscn")
	
	current = cam.instantiate()
	current.translate(Vector3.UP * 2)
	root.add_child(current)
	
	current = pauseMenu.instantiate()
	root.add_child(current)
	current.visible = false
	
	current = singleplayer.instantiate()
	root.add_child(current)
	
	get_tree().set_current_scene(current)


func toSettings():
	main.visible = false
	settings.visible = true


func goBackFromSettings():
	main.visible = true


func quitToDesktop():
	get_tree().quit()
