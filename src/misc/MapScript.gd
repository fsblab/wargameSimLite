extends Node3D


@onready var mbtUnit: Resource = ResourceLoader.load(GameMetaDataScript.unitDirectories[GameMetaDataScript.unitName.MBT])

var unit: Dictionary

var viewport: Viewport
var cam: Camera3D
var unitToBePlaced: Unit

const pathToMeshNode: String = "Model/Cube"


func _ready() -> void:
	unit = {
		GameMetaDataScript.unitName.MBT : mbtUnit
	}

	viewport = get_viewport()
	cam = viewport.get_camera_3d()

	SignalBusScript._addUnitToMap.connect(addUnit)


func _physics_process(_delta: float) -> void:
	if unitToBePlaced:
		unitFollowsMousePosition()
		setUnitDown()


func addUnit(u: GameMetaDataScript.unitName, faction: GameMetaDataScript.faction) -> void:
	unitToBePlaced = unit[u].instantiate()
	add_child(unitToBePlaced)
	unitToBePlaced.get_node(pathToMeshNode).set_surface_override_material(0, UnitSelectionScript.loadPlacementMaterial(faction))
	unitToBePlaced.get_node("Model").freeze = true
	unitToBePlaced.get_node("Model/CollisionShape3D").disabled = true


func removeUnit(u: Unit) -> void:
	remove_child(u)
	unitToBePlaced = null


func unitFollowsMousePosition() -> void:
	var mousePos: Vector2 = viewport.get_mouse_position()
	var origin: Vector3 = cam.project_ray_origin(mousePos)
	var to: Vector3 = cam.project_position(mousePos, 100)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, to, 2, [self])
	var posDict: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if posDict:
		var pos: Vector3 = posDict.position
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
			"faction": GameMetaDataScript.client.Faction
		}

		removeUnit(unitToBePlaced)
		rpc("_setUnit", unitData)
	elif Input.is_action_just_pressed("right_mouse_button"):
		removeUnit(unitToBePlaced)


@rpc("any_peer", "call_local", "reliable")
func _setUnit(udata: Dictionary) -> void:
	var path: String = GameMetaDataScript.unitDirectories[udata.name]
	var instance: Unit = ResourceLoader.load(path).instantiate()

	add_child(instance, true)

	instance.get_node(pathToMeshNode).set_surface_override_material(0, UnitSelectionScript.loadPlacementMaterial(udata.faction))
	instance.position = udata.pos
	instance.playerUid = udata.id
	instance.team = udata.team
	instance.faction = udata.faction
	instance.set_multiplayer_authority(udata.id)
