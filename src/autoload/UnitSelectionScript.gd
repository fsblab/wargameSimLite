extends Node


var selectedUnits: Array:
	get: return selectedUnits
var unitNotSelectedMaterial: StandardMaterial3D:
	get: return unitNotSelectedMaterial
var unitSelectedMaterial: StandardMaterial3D:
	get: return unitSelectedMaterial


func _ready():
	selectedUnits = Array()
	unitNotSelectedMaterial = preload("res://assets/materials/unitNotSelected.tres")
	unitSelectedMaterial = preload("res://assets/materials/unitSelected.tres")
	unitNotSelectedMaterial.vertex_color_use_as_albedo = true
	unitSelectedMaterial.vertex_color_use_as_albedo = true


func selectUnit(unit: Node3D) -> void:
	selectedUnits.append(unit)


func selectMultipleUnitsThroughRigidBody(unitsCB: Array) -> void:
	for unit in unitsCB:
		selectUnit(unit.get_parent())


func deselectUnit(unit: Node3D) -> void:
	selectedUnits.erase(unit)


func deselectAll() -> void:
	selectedUnits.clear()
