class_name GroundUnit extends Unit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if (marker.position - unitrb.position).length() > .1:
		if rotateToTarget(delta):
			moveToTarget(delta)
