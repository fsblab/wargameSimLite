extends Control


var selectedUnits: Array:
	get: return selectedUnits
var unitNotSelectedMaterial: StandardMaterial3D:
	get: return unitNotSelectedMaterial
var unitSelectedMaterial: StandardMaterial3D:
	get: return unitSelectedMaterial


# Called when the node enters the scene tree for the first time.
func _ready():
	selectedUnits = Array()
	unitNotSelectedMaterial = preload("res://assets/materials/unitNotSelected.tres")
	unitSelectedMaterial = preload("res://assets/materials/unitSelected.tres")
	unitNotSelectedMaterial.vertex_color_use_as_albedo = true
	unitSelectedMaterial.vertex_color_use_as_albedo = true


func selectUnit(unit: Node3D):
	selectedUnits.append(unit)


func selectMultipleUnitsThroughRigidBody(unitsCB: Array):
	for unit in unitsCB:
		selectUnit(unit.get_parent())


func deselectUnit(unit: Node3D):
	selectedUnits.erase(unit)


func deselectAll():
	selectedUnits.clear()
