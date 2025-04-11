extends Node3D


var mousePosition: Vector2
var viewport: Viewport
var cam: Camera3D
var spaceState: PhysicsDirectSpaceState3D

var origin: Vector3
var targetPosition: Vector3
var query: PhysicsRayQueryParameters3D
var result: Dictionary
var aimingAtEnemy: bool

var task: TaskHandler


func _ready() -> void:
	mousePosition = Vector2(0, 0)
	viewport = get_viewport()
	cam = viewport.get_camera_3d()
	spaceState = get_world_3d().direct_space_state
	
	origin = Vector3(0, 0, 0)
	targetPosition = Vector3(0, 0, 0)
	query = PhysicsRayQueryParameters3D.new()

	aimingAtEnemy = false


func _process(_delta: float) -> void:
	mousePosition = viewport.get_mouse_position()
	origin = cam.project_ray_origin(mousePosition)
	targetPosition = cam.project_position(mousePosition, 1000)
	query = PhysicsRayQueryParameters3D.create(origin, targetPosition, 3, [self])
	result = spaceState.intersect_ray(query)

	if result:
		if not UnitSelectionScript.selectedUnits.isEmpty() and not UnitSelectionScript.selectedUnits.getData()[0].shootAtMode:
			var colliderParent: Object = result.collider.get_parent()
			# condition = collider is unit * is enemy team * enemy is visible
			var condition: int = int(colliderParent is Unit and not colliderParent.team == GameMetaDataScript.client.Team and VisibilityScript.visibleEmemyUnits.has(colliderParent))
			[func(): aimingAtEnemy = false; Input.set_custom_mouse_cursor(null), func(): aimingAtEnemy = true; Input.set_custom_mouse_cursor(StdScript.crosshair, Input.CursorShape.CURSOR_ARROW, Vector2(16, 16))][condition].call()

	if Input.is_action_just_released("right_mouse_button") and not aimingAtEnemy:
		for unit in UnitSelectionScript.selectedUnits.getData():
			if result:
				unit.shootAtMode = false
				var tSetTarget: Task = Task.new(Callable(unit, "setTarget"), [result.position], false)
				var tRotateAndMove: Task = Task.new(Callable(unit, "rotateAndMove"), [unit.engineForce], true)
				unit.taskHandler.pushMultipleTasks([tSetTarget, tRotateAndMove])
	elif Input.is_action_just_released("right_mouse_button") and aimingAtEnemy:
		for unit in UnitSelectionScript.selectedUnits.getData():
			if result:
				unit.loadShootAtEnemyIntoTaskHandler(result.collider.get_parent())
