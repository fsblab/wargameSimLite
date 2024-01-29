extends Node3D


var movementVelocity: int


# Called when the node enters the scene tree for the first time.
func _ready():
	movementVelocity = 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_W):
		translate(Vector3.FORWARD * delta * movementVelocity)
	if Input.is_key_pressed(KEY_A):
		translate(Vector3.LEFT * delta * movementVelocity)
	if Input.is_key_pressed(KEY_S):
		translate(Vector3.BACK * delta * movementVelocity)
	if Input.is_key_pressed(KEY_D):
		translate(Vector3.RIGHT * delta * movementVelocity)
	
	position.y = clamp(position.y, .5, 20)
