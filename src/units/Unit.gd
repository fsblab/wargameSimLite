class_name Unit extends Node3D


# onready variables
@onready var nav: NavigationAgent3D = $Model/NavigationAgent3D
@onready var model: VehicleBody3D = $Model
@onready var wheel: VehicleWheel3D = $Model/VehicleWheel3D
@onready var marker: Marker3D = $MoveToMarker
@onready var meshNode: MeshInstance3D = $Model/Cube
@onready var fov: CollisionShape3D = $Model/FoV/CollisionShape3D
@onready var rangeMesh: MeshInstance3D = $Model/Range
@onready var timer: Timer = $SpawnTime
@onready var reloadTimer: Timer = $ReloadTime
@onready var taskHandler: TaskHandler

# setup variables
var engineForce: float
var engineForceReverse: float
var rotationVelocity: int
var stealth: int
var vision: int
var viewDistance: int
var viewDistanceSquared: int
@export var healthpoints: int
var enemyUnitsWithinViewDistance: Set
var shootAtMode: bool

# determined during spawn variables
var team: int
var playerUid: int
var unitName: GameMetaDataScript.unitName
var faction: GameMetaDataScript.faction
var status: UnitAttributesScript.unitStatus
var panicValue: int
var shootFrom: Vector3

# set in child classes
var weapons: Dictionary = {
	UnitAttributesScript.weaponTypes.MAINWEAPON: null,
	UnitAttributesScript.weaponTypes.ARMORPENETRATION: null,
	UnitAttributesScript.weaponTypes.HIGHEXPLOSIVE: null,
	UnitAttributesScript.weaponTypes.SMALLCALIBER: null
}

var armor: Dictionary = {
	"BACK" = 0,
	"FRONT" = 0,
	"SIDES" = 0,
	"TOP" = 0
}


func _ready() -> void:
	add_to_group("units")
	meshNode.set_surface_override_material(0, UnitSelectionScript.unitPlacementMaterial)
	status = UnitAttributesScript.unitStatus.PLACED
	panicValue = 100
	shootFrom = Vector3(0, 1, 0)
	playerUid = GameMetaDataScript.client.uid
	shootAtMode = false
	marker.global_position = model.global_position

	taskHandler = TaskHandler.new()
	enemyUnitsWithinViewDistance = Set.new()

	model.get_node("Selected").mesh.material.set("size", float(model.get_node("Selected").mesh.size.x))

	SignalBusScript._startBattle.connect(spawnUnit)


func _physics_process(delta):
	if playerUid == multiplayer.get_unique_id() and status == UnitAttributesScript.unitStatus.SPAWNED:
		checkVisibilityOfUnits()
	
	if taskHandler.taskFinished:
		if taskHandler.taskQueue.is_empty():
			return
		taskHandler.pop()
	
	taskHandler.callTask(delta)


func _input(_event: InputEvent) -> void:
	if UnitSelectionScript.selectedUnits.has(self) and Input.is_action_just_pressed("left_mouse_button") and shootAtMode:
		Input.set_custom_mouse_cursor(null)
		loadShootAtPositionIntoTaskHandler()


func _unhandled_key_input(_event: InputEvent) -> void:
	if UnitSelectionScript.selectedUnits.has(self) and Input.is_physical_key_pressed(KEY_E):
		taskHandler.clearTaskQueue()
		marker.global_position = model.global_position

	if UnitSelectionScript.selectedUnits.has(self) and Input.is_physical_key_pressed(KEY_C):
		rangeMesh.visible = not rangeMesh.visible
	
	if UnitSelectionScript.selectedUnits.has(self) and Input.is_physical_key_pressed(KEY_T):
		shootAtMode = not shootAtMode
		[func(): Input.set_custom_mouse_cursor(null), func(): Input.set_custom_mouse_cursor(StdScript.crosshair, Input.CursorShape.CURSOR_ARROW, Vector2(16, 16))][int(shootAtMode)].call()


## F = Force, engine force for vehicles and flying objects, running speed for infantry
## oppositeF = -Force, engine force for (vehicular) reverse
## omega = rotational velocity, speed at which a unit rotates
## uName = unit name, intuitive string identifier
## inv = invisibility, value for stealth or how hard it is to see a unit
## vis = vision, ability of unit to see
## view = view distance, distance a unit is able to see - outside of that completely blind
## srange = shooting range, maximal distance a unit is able to shoot at
## hp = health points
func setup(F: float, oppositeF: float, omega: int, uname: GameMetaDataScript.unitName, inv: int, vis: int, view: int, hp: int) -> void:
	engineForce = F
	engineForceReverse = oppositeF
	rotationVelocity = omega
	unitName = uname
	stealth = inv
	vision = vis
	viewDistance = view
	viewDistanceSquared = viewDistance * viewDistance
	healthpoints = hp

	fov.shape.radius = view
	rangeMesh.mesh.top_radius = view
	rangeMesh.mesh.bottom_radius = view


func spawnUnit(pos: Vector3 = position, to: Vector3 = position) -> void:
	meshNode.set_surface_override_material(0, UnitSelectionScript.loadNotSelectedMaterial(faction))
	status = UnitAttributesScript.unitStatus.SPAWNED
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


func setWeapons(weps: Array) -> void:
	for i in range(4 - len(weps)):
		weps.push_front(null)
	
	for key in weapons:
		weapons[key] = weps.pop_back()


func checkIfSelected() -> bool:
	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT or not playerUid == multiplayer.get_unique_id() or status == UnitAttributesScript.unitStatus.PLACED:
		return false
	
	if UnitSelectionScript.selectedUnits.has(self):
		get_node("Model/Selected").visible = true
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitSelectedMaterial)
		return true
	else:
		get_node("Model/Selected").visible = false
		meshNode.set_surface_override_material(0, UnitSelectionScript.unitNotSelectedMaterial)
		return false


## drive towards target position until position is reached, may decrease in accuracy the faster the unit moves
func driveToTarget(F: float) -> bool:
	var distanceSquared = (marker.global_position - model.global_position).length_squared()
	
	model.engine_force = F if model.engine_force == 0. else model.engine_force
	
	if distanceSquared < model.linear_velocity.length_squared() / 2.:
		model.engine_force = 0.
		return true
	
	return false


## rotates to face next position defined by pathfinder (= NavigationAgent)
func rotateToTarget(F: float, d, _dist: int = 16) -> bool:
	#if (marker.global_position - model.global_position).length_squared() <= dist:
	#	return true
	
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


## for right click on some surface to move towards
func rotateAndMove(F: float, d) -> bool:
	var rtt = rotateToTarget(F, d)
	var mtt = driveToTarget(F)
	return rtt and mtt


## moves within shooting range of target position and then stops
func approachTarget(F: float) -> bool:
	var distanceSquared = (marker.global_position - model.global_position).length_squared()
	
	model.engine_force = F if model.engine_force == 0. else model.engine_force
	
	if distanceSquared <= viewDistanceSquared:
		model.engine_force = 0.
		return true
	
	return false


## for left click while in shooting at position mode
func rotateAndApproach(F: float, srange: int, d) -> bool:
	var rtt = rotateToTarget(F, d, srange)
	var mtt = approachTarget(F)
	return rtt and mtt


## for right click on enemy unit
func huntEnemy(F: float, srange: int, enemyUnit: Unit, d: float) -> bool:
	var st = setTargetOnEnemy(enemyUnit)
	var rtt = rotateToTarget(F, d, srange)
	var mtt = approachTarget(F)
	return st and rtt and mtt



## sets target position i.e. position that unit is expected to move towards
func setTarget(pos: Vector3) -> bool:
	marker.global_position = pos
	nav.target_position = pos

	if not getReachablePosition():
		marker.global_position = model.global_position
	
	return true


## sets target position on enemy position to hunt enemy in case it is moving, stops hunt when enemy outside of visible enemy units
func setTargetOnEnemy(enemyUnit: Unit) -> bool:
	if not VisibilityScript.visibleEmemyUnits.has(enemyUnit):
		return true

	marker.global_position = enemyUnit.model.global_position
	nav.target_position = enemyUnit.model.global_position

	if not getReachablePosition():
		marker.global_position = model.global_position
	
	return true


## checks whether target position for unit is reachable, otherwise resets target position
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


func unitEnteredFoV(unit: CollisionObject3D) -> void:
	if not unit.get_parent() is Unit:
		return

	var enemyUnit: Unit = unit.get_parent()
	
	if enemyUnit.team != team and enemyUnit.team != 0 and enemyUnit != self and playerUid == multiplayer.get_unique_id() and status == UnitAttributesScript.unitStatus.SPAWNED:
		VisibilityScript.seeEnemyUnit(enemyUnit, self)
		enemyUnitsWithinViewDistance.add(unit)


func unitExitedFoV(unit: CollisionObject3D) -> void:
	if enemyUnitsWithinViewDistance.has(unit) and playerUid == multiplayer.get_unique_id() and status == UnitAttributesScript.unitStatus.SPAWNED:
		VisibilityScript.unseeEnemyUnit(unit.get_parent(), self)
		enemyUnitsWithinViewDistance.remove(unit)


func checkVisibilityOfUnits() -> void:
	for enemy: CollisionObject3D in enemyUnitsWithinViewDistance.getData():
		var enemyUnit = enemy.get_parent()
		
		if enemyUnit.stealth < getVision(enemy.global_position):
			VisibilityScript.seeEnemyUnit(enemyUnit, self)
		else:
			VisibilityScript.unseeEnemyUnit(enemyUnit, self)


func getVision(pos: Vector3) -> int:
	var d: float = (model.global_position - pos).length_squared()

	if d <= viewDistanceSquared / 4.:
		return vision + 2
	elif d <= viewDistanceSquared / 2.:
		return vision + 1
	elif d <= viewDistanceSquared:
		return vision
	else:
		return 0


func isWeaponUsable(weapon: Weapon) -> bool:
	return weapon and weapon.ammoCapacity and weapon.isActive


func loadShootAtEnemyIntoTaskHandler(enemyUnit: Unit) -> void:
	var softTarget = false if int(StdScript.sum(enemyUnit.armor.values())) > 0 else true
	var weapon: Weapon = weapons[UnitAttributesScript.weaponTypes.ARMORPENETRATION] if not softTarget and isWeaponUsable(weapons[UnitAttributesScript.weaponTypes.ARMORPENETRATION]) else weapons[UnitAttributesScript.weaponTypes.SMALLCALIBER] if isWeaponUsable(weapons[UnitAttributesScript.weaponTypes.SMALLCALIBER]) else weapons[UnitAttributesScript.weaponTypes.HIGHEXPLOSIVE]

	if not isWeaponUsable(weapon):
		return

	var shootingRangeSquared: int = weapon.shootingRangeSquared

	var trotateAndApproach: Task = Task.new(Callable(self, "huntEnemy"), [engineForce, shootingRangeSquared, enemyUnit], true)
	var tShoot: Task = Task.new(Callable(self, "shootAtEnemy"), [weapon, enemyUnit], false)
	taskHandler.pushMultipleTasks([trotateAndApproach, tShoot])


func shootAtEnemy(weapon: Weapon, enemyUnit: Unit) -> bool:
	if not VisibilityScript.visibleEmemyUnits.has(enemyUnit) or not enemyUnitsWithinViewDistance.has(enemyUnit.model):
		return true
	elif not weapon:
		return true
	elif not weapon.isActive:
		return false

	weapon.shootAtEnemy(self, panicValue, enemyUnit)
	reloadWeapon(weapon)

	if self == UnitSelectionScript.singleSelectedUnit:
		SignalBusScript.selectedUnitChanged(self, true)
	
	return true


func loadShootAtPositionIntoTaskHandler() -> void:
	var mousePosition: Vector2 = get_viewport().get_mouse_position()
	var origin: Vector3 = get_viewport().get_camera_3d().project_ray_origin(mousePosition)
	var targetPosition: Vector3 = get_viewport().get_camera_3d().project_position(mousePosition, 1000)
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, targetPosition, 2, [self])
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	var shootingRangeSquared: int = weapons[UnitAttributesScript.weaponTypes.MAINWEAPON].shootingRangeSquared
	
	if result:
		var tSetTarget: Task = Task.new(Callable(self, "setTarget"), [result.position], false)
		var trotateAndApproach: Task = Task.new(Callable(self, "rotateAndApproach"), [engineForce, shootingRangeSquared], true)
		var tShoot: Task = Task.new(Callable(self, "shootAtPosition"), [result.position], false)
		taskHandler.pushMultipleTasks([tSetTarget, trotateAndApproach, tShoot])


func shootAtPosition(pos: Vector3, weapon = weapons[UnitAttributesScript.weaponTypes.MAINWEAPON]) -> bool:
	if not weapon:
		return true
	elif not weapon.isActive:
		return false

	weapon.shootAtPosition(self, panicValue, pos)
	reloadWeapon(weapon)

	if self == UnitSelectionScript.singleSelectedUnit:
		SignalBusScript.selectedUnitChanged(self, true)
	
	return true


func getPanicStatus() -> String:
	var identifier: String

	for key: String in UnitAttributesScript.panicStatus:
		if UnitAttributesScript.panicStatus[key] <= panicValue:
			identifier = key
	
	return identifier


@rpc("any_peer", "call_local", "reliable")
func receiveDamage(ammoSerialized: Dictionary, directHit: bool = false) -> void:
	var dmg: int

	if directHit:
		dmg = max(ammoSerialized.armorDamage - int(StdScript.sum(armor.values())), 1) if int(StdScript.sum(armor.values())) > 0 else ammoSerialized.highExplosiveDamage
	else:
		dmg = 0 if int(StdScript.sum(armor.values())) > 1 else 2

	healthpoints -= dmg

	if healthpoints <= 0:
		UnitSelectionScript.deselectUnit(self)
		unitGetsDestroyed.rpc()
	elif self == UnitSelectionScript.singleSelectedUnit:
		SignalBusScript.selectedUnitChanged(self, true)
	
	receivePanic(ammoSerialized.panicAddend)
	SignalBusScript.unitReceivedDamaged(self)


func receivePanic(panic: int) -> void:
	panicValue -= panic


@rpc("any_peer", "call_local", "reliable")
func unitGetsDestroyed() -> void:
	var destroyedUnit: Node3D = ResourceLoader.load("res://scenes/units/destroyed_tank.tscn").instantiate()
	get_parent().add_child(destroyedUnit)
	destroyedUnit.global_position = model.global_position
	destroyedUnit.global_rotation = model.global_rotation
	destroyedUnit.get_node("tank/Cube").set_surface_override_material(0, ResourceLoader.load("res://assets/materials/destroyedUnit.tres"))
	queue_free()


func reloadWeapon(weapon: Weapon) -> void:
	weapon.isActive = false
	reloadTimer.wait_time = weapon.reloadTime
	reloadTimer.start()

	await reloadTimer.timeout

	weapon.isActive = true
