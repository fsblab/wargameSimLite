extends Button


func _ready():
	pressed.connect(self.ex)


func ex():
	get_tree().quit()
