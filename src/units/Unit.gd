class_name Unit extends Node3D


@onready var meshNode : MeshInstance3D
var maxVelocity : int
var accel : int
var rotationVelocity : int
var motion : Vector3

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var unitrb : RigidBody3D = $RB
@onready var model : Node3D = $RB/Model
@onready var marker : Marker3D = $MoveToMarker


func setup(mi : MeshInstance3D, v : int, a : int, omega : int):
	add_to_group("units")
	meshNode = mi
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
	
	maxVelocity = v
	accel = a
	rotationVelocity = omega
	motion = Vector3(0, 0, 0)


func checkIfSelected():
	if self in UnitSelectionScript.selectedUnits:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
	else:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)


func moveToTarget(d):
	var direction = marker.position - unitrb.position
	var distance = direction.length()
	direction = direction.normalized()
	
	nav.target_position = marker.position
	
	motion = direction * maxVelocity * d
	
	unitrb.position += motion
	
	if abs(distance) < .1:
		unitrb.position = marker.position


func rotateToTarget(d):
	if unitrb.position.x == marker.position.x and unitrb.position.z == marker.position.z:
		return true
	
	var direction = marker.position - unitrb.position
	var angle = atan2(direction.z, direction.x) - atan2(unitrb.transform.basis.z.z, unitrb.transform.basis.z.x)
	
	if angle > PI:
		angle -= 2 * PI
	elif angle < -PI:
		angle += 2 * PI
	
	if angle == 0:
		return true
	if abs(angle) < .05:
		get_child(0).rotate_y(-angle)
		return true
	elif angle > 0:
		get_child(0).rotate_y(-rotationVelocity * d)
		return false
	elif angle < 0:
		get_child(0).rotate_y(rotationVelocity * d)
		return false
