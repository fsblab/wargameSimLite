extends Button


var singleplayer
var current
var root
var cam

# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().get_root()
	current = root.get_child(root.get_child_count() - 1)
	pressed.connect(_sp)


func _sp():
	current.queue_free()
	singleplayer = ResourceLoader.load("res://scenes/functionality_test.tscn")
	cam = ResourceLoader.load("res://scenes/camera.tscn")
	
	current = cam.instantiate()
	current.translate(Vector3.UP * 2)
	root.add_child(current)
	
	current = singleplayer.instantiate()
	root.add_child(current)
	
	#root.remove_child($root/MainMenu)
	
	get_tree().set_current_scene(current)
