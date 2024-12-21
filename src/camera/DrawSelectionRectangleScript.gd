extends Control

var from: Vector2
var to: Vector2
var xfromyto: Vector2
var xtoyfrom: Vector2
var viewport: Viewport
var cam: Camera3D

var origin: Vector3
var pointA: Vector3
var pointB: Vector3
var pointC: Vector3
var pointD: Vector3

var colliderShape: ConvexPolygonShape3D

var rb: RigidBody3D
var cs: CollisionShape3D
var ar: Area3D

var rayLength: int
var skip: bool


func _ready():
	from = Vector2(0, 0)
	to = Vector2(0, 0)
	xfromyto = Vector2(0, 0)
	xtoyfrom = Vector2(0, 0)
	
	origin = Vector3(0, 0, 0)
	pointA = Vector3(0, 0, 0)
	pointB = Vector3(0, 0, 0)
	pointC = Vector3(0, 0, 0)
	pointD = Vector3(0, 0, 0)
	
	colliderShape = ConvexPolygonShape3D.new()
	
	ar = Area3D.new()
	add_child(ar)
	cs = CollisionShape3D.new()
	cs.shape = colliderShape
	ar.add_child(cs)
	
	rayLength = 100
	skip = false
	
	viewport = get_viewport()
	cam = viewport.get_camera_3d()


func _draw():
	draw_rect(Rect2(from, to - from), Color(Color.YELLOW_GREEN, .33))
	draw_rect(Rect2(from, to - from), Color(Color.GREEN, .5), false, 2.0)


func _physics_process(_delta):
	if skip:
		var results = ar.get_overlapping_bodies()
		
		if !results.is_empty():
			UnitSelectionScript.selectMultipleUnitsThroughRigidBody(results)
		
		get_tree().call_group("units", "checkIfSelected")
		
		from = Vector2(0, 0)
		to = Vector2(0, 0)
		queue_redraw()
		
		skip = false
		
	if Input.is_action_just_pressed("left_mouse_button"):
		from = viewport.get_mouse_position()
		
	if Input.is_action_pressed("left_mouse_button"):
		to = viewport.get_mouse_position()
		queue_redraw()
		
	if Input.is_action_just_released("left_mouse_button"):
		if not Input.is_key_pressed(KEY_SHIFT):
			UnitSelectionScript.deselectAll()
		
		xfromyto = Vector2(from.x, to.y)
		xtoyfrom = Vector2(to.x, from.y)
		
		origin = cam.project_ray_origin(from)
		pointA = cam.project_position(from, rayLength)
		pointB = cam.project_position(to, rayLength)
		pointC = cam.project_position(xfromyto, rayLength)
		pointD = cam.project_position(xtoyfrom, rayLength)
		
		colliderShape.points = PackedVector3Array([origin, pointA, pointB, pointC, pointD])
		skip = true
