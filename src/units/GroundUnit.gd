class_name GroundUnit extends Unit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if $MoveToMarker.position.x != model.position.x and $MoveToMarker.position.z != model.position.z:
		if rotateToTarget(delta):
			moveToTarget(delta)
