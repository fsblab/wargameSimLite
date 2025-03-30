extends Node


var selectedUnits: Set:
	get: return selectedUnits
var unitNotSelectedMaterial: StandardMaterial3D:
	get: return unitNotSelectedMaterial
var unitSelectedMaterial: StandardMaterial3D:
	get: return unitSelectedMaterial
var unitPlacementMaterial: StandardMaterial3D:
	get: return unitPlacementMaterial
var singleSelectedUnit: Unit


func _ready() -> void:
	selectedUnits = Set.new()
	SignalBusScript._loadMaterial.connect(loadMaterial)
	singleSelectedUnit = null


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
	if unit.playerUid == multiplayer.get_unique_id() and unit.status == UnitAttributesScript.unitStatus.SPAWNED:
		selectedUnits.add(unit)
	elif unit.playerUid == multiplayer.get_unique_id() and unit.status == UnitAttributesScript.unitStatus.PLACED:
		SignalBusScript.selectPlacedUnit(unit)
	SignalBusScript.unitSelected(unit)


func selectMultipleUnitsThroughRigidBody(unitsRB: Array) -> void:
	for model: VehicleBody3D in unitsRB:
		var unit: Node3D = model.get_parent()
		if unit.playerUid == multiplayer.get_unique_id():
			selectUnit(unit)
	if GameMetaDataScript.currentBattlePhase == GameMetaDataScript.battlePhase.BATTLE and not selectedUnits.isEmpty():
		singleSelectedUnit = selectedUnits.getData()[0]
		SignalBusScript.selectedUnitChanged(singleSelectedUnit, true)


func deselectUnit(unit: Node3D) -> void:
	unit.rangeMesh.visible = false
	unit.shootAtMode = false
	selectedUnits.remove(unit)
	SignalBusScript.unitSelected(unit, true)

	if selectedUnits.isEmpty():
		Input.set_custom_mouse_cursor(null)
		singleSelectedUnit = null
	elif unit == singleSelectedUnit:
		singleSelectedUnit = selectedUnits.getData()[0]
		SignalBusScript.selectedUnitChanged(singleSelectedUnit, true)


func deselectAll() -> void:
	for unit: Node3D in selectedUnits.getData():
		unit.rangeMesh.visible = false
		unit.shootAtMode = false
	
	Input.set_custom_mouse_cursor(null)
	selectedUnits.clear()
	singleSelectedUnit = null
	SignalBusScript.selectedUnitChanged(null, false)
