class_name GroundUnit extends Unit


func _physics_process(delta):
	if self in UnitSelectionScript.selectedUnits and Input.is_key_pressed(KEY_E):
		taskHandler.clearTaskQueue()
		marker.global_position = model.global_position
	
	if taskHandler.taskFinished:
		if taskHandler.taskQueue.is_empty():
			return
		taskHandler.pop()
	taskHandler.callTask(delta)
