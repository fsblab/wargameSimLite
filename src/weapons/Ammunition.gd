class_name Ammunition


var armorDamage: int
var effectiveRadius: int
var highExplosiveDamage: int
var name: String
var panicAddend: int
var projectile: Node3D


func _init(ad: int, er: int, hed: int, n: String, pa: int) -> void:
    armorDamage = ad
    effectiveRadius = er
    highExplosiveDamage = hed
    name = n
    panicAddend = pa


func serialize() -> Dictionary:
    return {"armorDamage": armorDamage, "effectiveRadius": effectiveRadius, "highExplosiveDamage": highExplosiveDamage, "name": name, "panicAddend": panicAddend}


## startPos = Starting Position - point in space where the projectile is fired from
## destPos = Destination Position - point in space where the projectile is flying towards
## ignoreUnit = Ignore Unit - unit that is to be hit directly, thus not subject to additional explosive damage within the blast radius and to be ignored in that context
func shoot(unit: Unit, destPos: Vector3, ignoreUnit: Unit = null) -> void:
    var direction = (destPos - (unit.model.global_position + Vector3(0, 1, 0))).normalized()
    projectile = ResourceLoader.load("res://scenes/units/projectile.tscn").instantiate()
    projectile.setup(40, unit.model, direction, ignoreUnit, self)
    projectile.fire()
