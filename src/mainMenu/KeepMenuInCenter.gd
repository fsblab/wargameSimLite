extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position.x = get_viewport_rect().size.x / 2 - size.x / 2
	position.y = get_viewport_rect().size.y / 2 - size.y / 2
