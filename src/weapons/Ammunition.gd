class_name Ammunition extends Object


var armorDamage: int
var effectiveRadius: int
var highExplosiveDamage: int
var name: String
var panicAddend: int


func _init(ad: int, er: int, hed: int, n: String, pa: int) -> void:
    armorDamage = ad
    effectiveRadius = er
    highExplosiveDamage = hed
    name = n
    panicAddend = pa