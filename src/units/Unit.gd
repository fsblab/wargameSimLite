class_name Unit extends Node3D

@onready var nav: NavigationAgent3D = $Model/NavigationAgent3D
@onready var model: CharacterBody3D = $Model
@onready var marker: Marker3D = $MoveToMarker
@onready var meshNode: MeshInstance3D = model.get_child(0)

@onready var taskHandler: TaskHandler

var maxVelocity: int
var accel: int
var breakingFactor: int
var rotationVelocity: int
var motion: Vector3


func setup(v: int, a: int, breakF: int, omega: int) -> void:
	add_to_group("units")
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
	
	taskHandler = TaskHandler.new()
	
	maxVelocity = v
	accel = a
	breakingFactor = breakF
	rotationVelocity = omega
	motion = Vector3(0, 0, 0)
	
	marker.global_position = model.global_position


func checkIfSelected() -> bool:
	if self in UnitSelectionScript.selectedUnits:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
		return true
	else:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
		return false


func moveToTarget(d) -> bool:
	nav.target_position = marker.global_position
	
	if !nav.is_target_reachable():
		#marker.global_position = marker.global_position - (marker.global_position - model.global_position).normalized()
		#nav.target_position = marker.global_position
		setTarget(model.global_position)
		return true
	
	#var direction = (nav.get_next_path_position() - model.global_position).normalized()
	var distance = (marker.global_position - model.global_position).length_squared()
	
	#motion = direction * maxVelocity * d
	model.velocity = model.velocity.lerp(maxVelocity * model.basis.z, accel * d)
	
	model.move_and_slide()
	#model.global_position += motion
	
	if abs(distance) < 2:
		marker.global_position = model.global_position
		model.velocity = Vector3(0, 0, 0)
		return true
	return false


func rotateToTarget(d) -> bool:
	if model.position.x == marker.position.x and model.position.z == marker.position.z:
		return true
	
	var direction = (nav.get_next_path_position() - model.global_position).normalized()
	var angle = atan2(direction.z, direction.x) - atan2(model.transform.basis.z.z, model.transform.basis.z.x)
	
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
		model.velocity = model.velocity - (model.velocity.normalized() * breakingFactor * d)
		return false
	elif angle < 0:
		get_child(0).rotate_y(rotationVelocity * d)
		model.velocity = model.velocity - (model.velocity.normalized() * breakingFactor * d)
		return false
	return false


func rotateAndMove(d) -> bool:
	var rtt = rotateToTarget(d)
	var mtt = moveToTarget(d)
	return rtt and mtt


func setTarget(pos: Vector3) -> bool:
	marker.global_position = pos
	return true
