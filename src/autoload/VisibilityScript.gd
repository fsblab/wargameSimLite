extends Node


var visibleEmemyUnits: RefSet:
    get: return visibleEmemyUnits

var visibleFriendlyUnits: RefSet:
    get: return visibleFriendlyUnits


func _ready() -> void:
    visibleEmemyUnits = RefSet.new()
    visibleFriendlyUnits = RefSet.new()


func seeEnemyUnit(unit: Unit, seenBy: Unit) -> void:
    visibleEmemyUnits.add(unit, seenBy)
    unit.visible = true


func unseeEnemyUnit(unit: Unit, seenBy: Unit) -> void:
    visibleEmemyUnits.remove(unit, seenBy)
    
    if not visibleEmemyUnits.has(unit):
        unit.visible = false


func seeFriendlyUnit(unit: Unit, seenBy: Unit) -> void:
    visibleFriendlyUnits.add(unit, seenBy)
    unit.visible = true


func unseeFriendlyUnit(unit: Unit, seenBy: Unit) -> void:
    visibleFriendlyUnits.remove(unit, seenBy)

    if not visibleFriendlyUnits.has(unit):
        unit.visible = false