extends Node3D


@onready var mbtUnit: Resource = ResourceLoader.load(GameMetaDataScript.unitDirectories[GameMetaDataScript.unitName.MBT])
@onready var spawnzones2d: StaticBody2D = $insideSpawnzoneChecker

var unit: Dictionary

var viewport: Viewport
var cam: Camera3D
var unitToBePlaced: Unit
var doNotImmediatlySelectUnitAfterPlacing: bool
var szNodeNames: Array
var unitPosition2d: Node2D

const pathToMeshNode: String = "Model/Cube"


func _ready() -> void:
	unit = {
		GameMetaDataScript.unitName.MBT: mbtUnit
	}

	doNotImmediatlySelectUnitAfterPlacing = false

	viewport = get_viewport()
	cam = viewport.get_camera_3d()

	unitPosition2d = Node2D.new()
	spawnzones2d.add_child(unitPosition2d)

	initSpawnzones()

	SignalBusScript._addUnitToMap.connect(addUnit)
	SignalBusScript._selectPlacedUnit.connect(selectPlacedUnit)
	SignalBusScript._startBattle.connect(startBattle)


func _physics_process(_delta: float) -> void:
	if unitToBePlaced:
		unitFollowsMousePosition()
		setUnitDown()
		rotateUnit()


func initSpawnzones():
	if not GameMetaDataScript.mapInfo.has("spawnzones"):
		return

	var teamno: int = 1

	for sz: Dictionary in GameMetaDataScript.mapInfo.spawnzones:
		var meshno: int = 1

		for m: Array in sz.values():
			var mesh: MeshInstance3D = MeshInstance3D.new()
			var arrMesh: ArrayMesh = ArrayMesh.new()
			var vertices: PackedVector3Array = PackedVector3Array()
			var vertices2d: PackedVector2Array = PackedVector2Array()
			var array: Array = []
			var loopedThroughOnce: bool = false

			for adder: int in [1, 2]:
				for point: Array in m:
					vertices.push_back(Vector3(point[0], point[1] + (adder * 0.01), point[2]))
					if not loopedThroughOnce and teamno == GameMetaDataScript.client.Team:
						vertices2d.push_back(Vector2(point[0], point[2]))
				loopedThroughOnce = true
									
			array.resize(Mesh.ARRAY_MAX)
			array[Mesh.ARRAY_VERTEX] = vertices
			arrMesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, array)
			mesh.mesh = arrMesh
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mesh.name = str("SZ", teamno, "MESH", meshno)

			szNodeNames.push_back(mesh.name)

			if teamno == GameMetaDataScript.client.Team:
				createSpawnzone2d(vertices2d)
				mesh.set_surface_override_material(0, ResourceLoader.load("res://assets/materials/mySpawnzone.tres"))
			else:
				mesh.set_surface_override_material(0, ResourceLoader.load("res://assets/materials/enemySpawnzone.tres"))

			meshno += 1
			add_child(mesh)
		
		teamno += 1


@warning_ignore("confusable_local_declaration")
func createSpawnzone2d(v: PackedVector2Array):
	for index in range(0, len(v) - 1):
		var sz2dline: CollisionShape2D = CollisionShape2D.new()
		sz2dline.shape = SegmentShape2D.new()

		sz2dline.shape.a = v[index]
		sz2dline.shape.b = v[index + 1]
		spawnzones2d.add_child(sz2dline)
	
	var sz2dline: CollisionShape2D = CollisionShape2D.new()
	sz2dline.shape = SegmentShape2D.new()
	
	sz2dline.shape.a = v[-1]
	sz2dline.shape.b = v[0]
	spawnzones2d.add_child(sz2dline)


func isUnitInsideSpawnzone() -> bool:
	var v: PackedVector2Array = [
		Vector2(unitPosition2d.position.x + 1000, unitPosition2d.position.y),
		Vector2(unitPosition2d.position.x - 1000, unitPosition2d.position.y),
		Vector2(unitPosition2d.position.x, unitPosition2d.position.y + 1000),
		Vector2(unitPosition2d.position.x, unitPosition2d.position.y - 1000)
	]
	var space_state = spawnzones2d.get_world_2d().direct_space_state

	for vec: Vector2 in v:
		var query = PhysicsRayQueryParameters2D.create(unitPosition2d.position, vec)
		var result = space_state.intersect_ray(query)
		if not result:
			return false
	return true


func addUnit(u: GameMetaDataScript.unitName, faction: GameMetaDataScript.faction) -> void:
	unitToBePlaced = unit[u].instantiate()
	add_child(unitToBePlaced)
	unitToBePlaced.get_node(pathToMeshNode).set_surface_override_material(0, UnitSelectionScript.loadPlacementMaterial(faction))
	unitToBePlaced.get_node("Model").freeze = true
	unitToBePlaced.get_node("Model/CollisionShape3D").disabled = true
	unitToBePlaced.name = str(unitToBePlaced.get_instance_id())
	unitToBePlaced.get_node("Model").rotate_y(GameMetaDataScript.mapInfo.rotationAngles[GameMetaDataScript.client.Team - 1] * PI)

	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT:
		var team = GameMetaDataScript.client.Team - 1
		unitToBePlaced.position = Vector3(GameMetaDataScript.mapInfo.defaultSpawnPositions[team][0], GameMetaDataScript.mapInfo.defaultSpawnPositions[team][1], GameMetaDataScript.mapInfo.defaultSpawnPositions[team][2])
		unitPosition2d.position = Vector2(unitToBePlaced.position.x, unitToBePlaced.position.z)


func removeUnit(u: Unit) -> void:
	remove_child(u)
	unitToBePlaced = null


func selectPlacedUnit(u: Unit) -> void:
	if unitToBePlaced == null and not doNotImmediatlySelectUnitAfterPlacing:
		UnitSelectionScript.deselectAll()
		unitToBePlaced = u
		if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT:
			spawnzones2d.add_child(unitPosition2d)
			unitPosition2d.position = Vector2(unitToBePlaced.position.x, unitToBePlaced.position.z)
	
	doNotImmediatlySelectUnitAfterPlacing = false


func unitFollowsMousePosition() -> void:
	var mousePos: Vector2 = viewport.get_mouse_position()
	var origin: Vector3 = cam.project_ray_origin(mousePos)
	var to: Vector3 = cam.project_position(mousePos, 100)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, to, 2, [self])
	var posDict: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	if posDict:
		var pos: Vector3 = posDict.position
		if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.UNITPLACEMENT:
			unitPosition2d.position = Vector2(pos.x, pos.z)
			if isUnitInsideSpawnzone():
				unitToBePlaced.position = pos
		else:
			unitToBePlaced.position = pos


func setUnitDown() -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		unitToBePlaced.get_node("Model/CollisionShape3D").disabled = false
		unitToBePlaced.get_node("Model").freeze = false
		
		var unitData: Dictionary = {
			"name": unitToBePlaced.unitName,
			"pos": unitToBePlaced.position,
			"id": GameMetaDataScript.client.uid,
			"team": GameMetaDataScript.client.Team,
			"faction": GameMetaDataScript.client.Faction,
			"rotation": unitToBePlaced.get_node("Model").rotation,
			"iid": str(unitToBePlaced.name)
		}

		removeUnit(unitToBePlaced)
		doNotImmediatlySelectUnitAfterPlacing = true
		rpc("_setUnit", unitData)
	elif Input.is_action_just_pressed("right_mouse_button"):
		removeUnit(unitToBePlaced)


func rotateUnit() -> void:
	if Input.is_action_just_pressed("ui_page_up"):
		unitToBePlaced.get_node("Model").rotate_y(PI / 4)
	if Input.is_action_just_pressed("ui_page_down"):
		unitToBePlaced.get_node("Model").rotate_y(-PI/ 4)


@rpc("any_peer", "call_local", "reliable")
func _setUnit(udata: Dictionary) -> void:
	var path: String = GameMetaDataScript.unitDirectories[udata.name]
	var instance: Unit = ResourceLoader.load(path).instantiate()

	if has_node(udata.iid):
		remove_child(get_node(udata.iid))

	add_child(instance, true)

	instance.get_node(pathToMeshNode).set_surface_override_material(0, UnitSelectionScript.loadPlacementMaterial(udata.faction))
	instance.position = udata.pos
	instance.playerUid = udata.id
	instance.team = udata.team
	instance.faction = udata.faction
	instance.get_node("Model").rotation = udata.rotation
	instance.name = udata.iid
	instance.set_multiplayer_authority(udata.id)

	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.BATTLE:
		instance.startTimer()


func startBattle() -> void:
	for sz: String in szNodeNames:
		remove_child(get_node(sz))
	
	szNodeNames = []
	remove_child(spawnzones2d)
	unitPosition2d = null
	spawnzones2d = null
