extends Node3D


var mousePosition : Vector2
var viewport : Viewport
var cam : Camera3D
var spaceState

var origin : Vector3
var targetPosition : Vector3
var query : PhysicsRayQueryParameters3D
var result


# Called when the node enters the scene tree for the first time.
func _ready():
	mousePosition = Vector2(0, 0)
	viewport = get_viewport()
	cam = viewport.get_camera_3d()
	spaceState = get_world_3d().direct_space_state
	
	origin = Vector3(0, 0, 0)
	targetPosition = Vector3(0, 0, 0)
	query = PhysicsRayQueryParameters3D.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_released("right_mouse_button"):
		mousePosition = viewport.get_mouse_position()
		origin = cam.project_ray_origin(mousePosition)
		targetPosition = cam.project_position(mousePosition, 1000)
		
		query = PhysicsRayQueryParameters3D.create(origin, targetPosition, 2, [self])
		result = spaceState.intersect_ray(query)
		
		#NOTE: get_child(1) always has to be the marker
		for unit in UnitSelectionScript.selectedUnits:
			unit.get_child(1).position = result.position
