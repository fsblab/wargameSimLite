extends Button


var singleplayer: Resource
var current: Node
var root: Node
var cam: Resource
var pauseMenu: Resource


func _ready():
	root = get_tree().get_root()
	current = root.get_child(root.get_child_count() - 1)
	pressed.connect(sp)


func sp():
	current.queue_free()
	singleplayer = ResourceLoader.load("res://scenes/functionalityTest.tscn")
	cam = ResourceLoader.load("res://scenes/camera.tscn")
	pauseMenu = ResourceLoader.load("res://scenes/pauseMenu.tscn")
	
	current = cam.instantiate()
	current.translate(Vector3.UP * 2)
	root.add_child(current)
	
	current = pauseMenu.instantiate()
	root.add_child(current)
	current.visible = false
	
	current = singleplayer.instantiate()
	root.add_child(current)
	
	get_tree().set_current_scene(current)
