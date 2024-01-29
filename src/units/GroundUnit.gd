class_name GroundUnit extends Unit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if self in UnitSelectionScript.selectedUnits and Input.is_key_pressed(KEY_E):
		taskHandler.clearTaskQueue()
		marker.global_position = model.global_position
	
	if taskHandler.taskFinished:
		if taskHandler.taskQueue.is_empty():
			return
		taskHandler.pop(delta)
	taskHandler.callTask()
