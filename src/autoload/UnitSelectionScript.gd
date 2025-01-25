extends Node


var selectedUnits: Array:
	get: return selectedUnits
var unitNotSelectedMaterial: StandardMaterial3D:
	get: return unitNotSelectedMaterial
var unitSelectedMaterial: StandardMaterial3D:
	get: return unitSelectedMaterial
var unitPlacementMaterial: StandardMaterial3D:
	get: return unitPlacementMaterial


func _ready() -> void:
	selectedUnits = Array()
	SignalBusScript._loadMaterial.connect(loadMaterial)


func loadMaterial() -> void:
	unitPlacementMaterial = ResourceLoader.load(GameMetaDataScript.teamMaterials.get(int(GameMetaDataScript.client.Faction))[0])
	unitNotSelectedMaterial = ResourceLoader.load(GameMetaDataScript.teamMaterials.get(int(GameMetaDataScript.client.Faction))[1])
	unitSelectedMaterial = ResourceLoader.load(GameMetaDataScript.teamMaterials.get(int(GameMetaDataScript.client.Faction))[2])


func loadPlacementMaterial(faction: GameMetaDataScript.faction) -> StandardMaterial3D:
	return ResourceLoader.load(GameMetaDataScript.teamMaterials[faction][0])


func loadNotSelectedMaterial(faction: GameMetaDataScript.faction) -> StandardMaterial3D:
	return ResourceLoader.load(GameMetaDataScript.teamMaterials[faction][1])


func loadSelectedMaterial(faction: GameMetaDataScript.faction) -> StandardMaterial3D:
	return ResourceLoader.load(GameMetaDataScript.teamMaterials[faction][2])


func selectUnit(unit: Node3D) -> void:
	if unit.playerUid == multiplayer.get_unique_id() and unit.status == Unit.unitStatus.SPAWNED:
		selectedUnits.append(unit)
	elif unit.playerUid == multiplayer.get_unique_id() and unit.status == Unit.unitStatus.PLACED:
		SignalBusScript.selectPlacedUnit(unit)


func selectMultipleUnitsThroughRigidBody(unitsRB: Array) -> void:
	for model: VehicleBody3D in unitsRB:
		var unit: Node3D = model.get_parent()
		if unit.playerUid == multiplayer.get_unique_id():
			selectUnit(unit)


func deselectUnit(unit: Node3D) -> void:
	selectedUnits.erase(unit)


func deselectAll() -> void:
	selectedUnits.clear()
