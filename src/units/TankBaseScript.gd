extends GroundUnit


# Called when the node enters the scene tree for the first time.
func _ready():
	setup($RB/Model/Cube, 10, 1, 1)


#func _process(_delta):
#	print($RB.position.x, $MoveToMarker.position.x)
