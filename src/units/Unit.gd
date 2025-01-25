class_name Unit extends Node3D


@onready var nav: NavigationAgent3D = $Model/NavigationAgent3D
@onready var model: VehicleBody3D = $Model
@onready var wheel: VehicleWheel3D = $Model/VehicleWheel3D
@onready var marker: Marker3D = $MoveToMarker
@onready var meshNode: MeshInstance3D = $Model/Cube
@onready var timer: Timer = $Timer
@onready var taskHandler: TaskHandler

var engineForce: float
var engineForceReverse: float
var rotationVelocity: int
var invisibility: int
var healthpoints: int

var team: int
var playerUid: int
var unitName: GameMetaDataScript.unitName
var faction: GameMetaDataScript.faction

enum unitStatus {
	PLACED,
	SPAWNED,
	DESTROYED
}

var status: unitStatus


func _ready() -> void:
	add_to_group("units")
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitPlacementMaterial)
	status = unitStatus.PLACED

	taskHandler = TaskHandler.new()
	marker.global_position = model.global_position
	playerUid = GameMetaDataScript.client.uid

	SignalBusScript._startBattle.connect(spawnUnit)


func _physics_process(delta):
	if self in UnitSelectionScript.selectedUnits and Input.is_key_pressed(KEY_E):
		taskHandler.clearTaskQueue()
		marker.global_position = model.global_position
	
	if taskHandler.taskFinished:
		if taskHandler.taskQueue.is_empty():
			return
		taskHandler.pop()
	
	taskHandler.callTask(delta)


func setup(F: float, oppositeF: float, omega: int, uname: GameMetaDataScript.unitName, inv: int, hp: int) -> void:	
	engineForce = F
	engineForceReverse = oppositeF
	rotationVelocity = omega
	unitName = uname
	invisibility = inv
	healthpoints = hp


func spawnUnit(pos: Vector3 = position, to: Vector3 = position) -> void:
	meshNode.set_surface_override_material(0, UnitSelectionScript.loadNotSelectedMaterial(faction))
	status = unitStatus.SPAWNED
	position = pos
	marker.position = to

	if (pos - to).length_squared() > 16:
		var tSetTarget: Task = Task.new(Callable(self, "setTarget"), [to], false)
		var tRotateAndMove: Task = Task.new(Callable(self, "rotateAndMove"), [engineForce], true)
		taskHandler.pushMultipleTasks([tSetTarget, tRotateAndMove])


func spawnUnitAtNearestSpawnpoint() -> void:
	var sp: PackedVector3Array

	for point: Array in GameMetaDataScript.mapInfo.spawnpoints[team - 1].values():
		sp.push_back(Vector3(point[0], point[1], point[2]))

	var distances: Array = StdScript.map(sp, func(point: Vector3): return abs((point - position).length_squared()))
	var index: int = distances.find(distances.min())

	spawnUnit(sp[index], position)


func startTimer() -> void:
	timer.start()


func checkIfSelected() -> bool:
	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT or not playerUid == multiplayer.get_unique_id() or status == unitStatus.PLACED:
		return false
	
	if self in UnitSelectionScript.selectedUnits:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
		return true
	else:
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
		return false


func driveToTarget(F: float) -> bool:
	var distanceSquared = (marker.global_position - model.global_position).length_squared()
	
	model.engine_force = F if model.engine_force == 0. else model.engine_force
	
	if distanceSquared < model.linear_velocity.length_squared() / 2.:
		model.engine_force = 0.
		return true
	
	return false


func rotateToTarget(F: float, d) -> bool:
	if model.position.x == marker.position.x and model.position.z == marker.position.z:
		return true
	
	var direction = (nav.get_next_path_position() - model.global_position).normalized()
	var angle: float

	if F > 0:
		angle = atan2(direction.z, direction.x) - atan2(model.transform.basis.z.z, model.transform.basis.z.x)
	else:
		angle = PI + atan2(direction.z, direction.x) - atan2(model.transform.basis.z.z, model.transform.basis.z.x)
	
	if angle > PI:
		angle = angle - 2 * PI
	elif angle < -PI:
		angle = angle + 2 * PI
	
	if angle == 0:
		return true
	if abs(angle) < .05:
		get_child(0).rotate_y(-angle)
		model.engine_force = F
		return true
	elif angle > 0:
		get_child(0).rotate_y(-rotationVelocity * d)
	elif angle < 0:
		get_child(0).rotate_y(rotationVelocity * d)
	
	model.engine_force = 6.5 * model.mass if F > 0 else -8. * model.mass
	return false


func rotateAndMove(F: float, d) -> bool:
	var rtt = rotateToTarget(F, d)
	var mtt = driveToTarget(F)
	return rtt and mtt


func setTarget(pos: Vector3) -> bool:
	marker.global_position = pos
	nav.target_position = pos

	if not getReachablePosition():
		marker.global_position = model.global_position
	
	return true


func getReachablePosition() -> bool:
	var navPath: PackedVector3Array
	
	if nav.is_target_reachable():
		return true
	
	navPath = nav.get_current_navigation_path()

	for step in range(len(navPath)):
		nav.target_position = navPath[-step - 1]
		if nav.is_target_reachable():
			marker.global_position = nav.target_position
			return true
	
	return false
