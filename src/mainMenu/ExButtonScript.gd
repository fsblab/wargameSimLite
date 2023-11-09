extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(self._ex)


func _ex():
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
