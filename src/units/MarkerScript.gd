extends Decal


@onready var unit: Node3D = get_parent().get_parent()
@onready var model: CharacterBody3D = unit.get_child(0)


func _process(_delta):
	if position == model.position:
		visible = false
	elif unit in UnitSelectionScript.selectedUnits:
		visible = true
	else:
		visible = false
