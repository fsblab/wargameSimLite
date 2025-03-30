class_name Weapon extends Object


var ammo: Ammunition
var ammoCapacity: int
var name: String
var precision: int
var shootingRange: int
var shootingRangeSquared: int
var weaponTexture: Resource

var isActive: bool

func _init(a: Ammunition, ac: int, n: String, p: int, sr: int, wt: Texture2D) -> void:
    ammo = a
    ammoCapacity = ac
    name = n
    precision = p
    shootingRange = sr
    shootingRangeSquared = sr * sr
    weaponTexture = wt

    isActive = true


func getPrecision(panic) -> int:
    return int(precision * (panic / 100.))