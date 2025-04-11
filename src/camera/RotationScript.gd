extends Node3D


var rotationScalar: int
var rootNode: Node3D

func _ready():
	rotationScalar = 2
	rootNode = get_parent()


func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		rotate_x(-Input.get_last_mouse_velocity().normalized().y * delta * rotationScalar)
		rootNode.rotate_y(-Input.get_last_mouse_velocity().normalized().x * delta * rotationScalar)
	
	rotation.x = clamp(rotation.x, -.8, .1)
