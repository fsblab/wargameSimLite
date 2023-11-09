class_name Unit extends Node3D


@onready var meshNode : MeshInstance3D
var maxVelocity : int
var rotationVelocity : int

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var model : CharacterBody3D = $Model
@onready var marker : Marker3D = $MoveToMarker


func setup(mi : MeshInstance3D, v : int, w : int):
	add_to_group("units")
	meshNode = mi
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
	
	maxVelocity = v
	rotationVelocity = w


func checkIfSelected():
	if self in UnitSelectionScript.selectedUnits:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
	else:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)


func moveToTarget(d):
	var direction = get_child(1).position - model.position
	var distance = direction.length()
	direction = direction.normalized()
	
	model.velocity = direction * maxVelocity * d
	
	#TODO: bewegung durch rigidbody bewegungen ersetzen
	model.move_and_slide()
	
	if abs(distance) < .1:
		model.position = $MoveToMarker.position


func rotateToTarget(d):
	if model.position.x == $MoveToMarker.position.x and model.position.z == $MoveToMarker.position.z:
		return true
	
	var direction = get_child(1).position - model.position
	var angle = atan2(direction.z, direction.x) - atan2(model.transform.basis.z.z, model.transform.basis.z.x)
	
	if angle > PI:
		angle -= 2 * PI
	elif angle < -PI:
		angle += 2 * PI
	
	if abs(angle) < .05:
		get_child(0).rotate_y(-angle)
		return true
	if angle > 0:
		get_child(0).rotate_y(-rotationVelocity * d)
		return false
	elif angle < 0:
		get_child(0).rotate_y(rotationVelocity * d)
		return false
