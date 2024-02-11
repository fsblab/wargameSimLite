extends CanvasLayer


@onready var main: Control = $Pause
@onready var settings: Control = $Settings
@onready var menu: Node = get_parent()


func cont() -> void:
	menu.visible = false
	visible = false
	get_tree().paused = false


func toSettings() -> void:
	main.visible = false
	settings.visible = true


func goBackFromSettings() -> void:
	main.visible = true


func backToMainMenu() -> void:
	get_tree().paused = false
	
	var root = get_tree().get_root()
	var current: Node
	
	for i in range(2, root.get_child_count()):
		current = root.get_child(i)
		current.queue_free()
	
	var back = ResourceLoader.load("res://scenes/start.tscn")
	
	current = back.instantiate()
	root.add_child(current)
	
	get_tree().set_current_scene(current)


func quitToDesktop() -> void:
	get_tree().quit()
