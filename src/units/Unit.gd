class_name Unit extends Node3D

@onready var nav: NavigationAgent3D = $Model/NavigationAgent3D
@onready var model: VehicleBody3D = $Model
@onready var wheel: VehicleWheel3D = $Model/VehicleWheel3D
@onready var marker: Marker3D = $MoveToMarker
@onready var meshNode: MeshInstance3D = model.get_child(0)
@onready var taskHandler: TaskHandler

var engineForce: float
var rotationVelocity: int


func setup(F: float, omega: int) -> void:
	add_to_group("units")
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
	
	taskHandler = TaskHandler.new()
	
	engineForce = F
	rotationVelocity = omega
	
	marker.global_position = model.global_position


func checkIfSelected() -> bool:
	if self in UnitSelectionScript.selectedUnits:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
		return true
	else:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
		return false


func driveToTarget() -> bool:	
	var distanceSquared = (marker.global_position - model.global_position).length_squared()
	
	model.engine_force = engineForce if model.engine_force == 0. else model.engine_force
	
	if distanceSquared < model.linear_velocity.length_squared() / 2.:
		model.engine_force = 0.
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
		model.engine_force = engineForce
		return true
	elif angle > 0:
		get_child(0).rotate_y(-rotationVelocity * d)
	elif angle < 0:
		get_child(0).rotate_y(rotationVelocity * d)
	model.engine_force = 8. * model.mass
	return false


func rotateAndMove(d) -> bool:
	var rtt = rotateToTarget(d)
	var mtt = driveToTarget()
	return rtt and mtt


func setTarget(pos: Vector3) -> bool:
	marker.global_position = pos
	nav.target_position = pos
	getReachablePosition()
	return true


func getReachablePosition():
	var navPath: PackedVector3Array
	
	if nav.is_target_reachable():
		return true
	
	navPath = nav.get_current_navigation_path()
	for step in range(len(navPath)):
		nav.target_position = navPath[-step - 1]
		if nav.is_target_reachable():
			marker.global_position = nav.target_position
			return true
