extends Node3D

var viewport: Viewport
var mousePosition: Vector2
var cam: Camera3D
var rootNode: Node3D

var direction: Vector3
var zoomScalar: int


# Called when the node enters the scene tree for the first time.
func _ready():
	zoomScalar = 100
	
	viewport = get_viewport()
	cam = viewport.get_camera_3d()
	
	rootNode = get_node(get_meta("RootNode"))


func _physics_process(delta):
	if Input.is_action_just_pressed("mmb_up"):
		mousePosition = viewport.get_mouse_position()
		direction = cam.project_local_ray_normal(mousePosition)
		rootNode.translate(direction * zoomScalar * delta)
	
	if Input.is_action_just_pressed("mmb_down"):
		mousePosition = viewport.get_mouse_position()
		direction = cam.project_local_ray_normal(mousePosition)
		rootNode.translate(-direction * zoomScalar * delta)
