class_name Weapon


var ammo: Ammunition
var ammoCapacity: int
var name: String
var precision: int
var reloadTime: int
var shootingRange: int
var shootingRangeSquared: int
var weaponTexture: Resource

var isActive: bool
var rng: RandomNumberGenerator


## a = Ammunition,
## ac = Ammo Capacity, number of shots
## n = Name,
## p = Precision, value between 0 and 100 to represent a percentage
## rt = Reload Time, time in whole seconds until gun can shoot again
## sr = Shooting Range, distance weapon is capable to shoot
## wt = Weapon Texture, used in UI when unit is selected
func _init(a: Ammunition, ac: int, n: String, p: int, rt: int, sr: int, wt: Texture2D) -> void:
    ammo = a
    ammoCapacity = ac
    name = n
    precision = p
    reloadTime = rt
    shootingRange = sr
    shootingRangeSquared = sr * sr
    weaponTexture = wt

    isActive = true
    rng = RandomNumberGenerator.new()


func getPrecision(panic: int) -> int:
    return int(precision * (panic / 100.))


func shoot(unit: Unit, panic: int, enemyUnit: Unit) -> void:
    if not isActive:
        return
    
    var position: Vector3 = determinePosition(enemyUnit.global_position, getPrecision(panic))

    ammo.shoot(unit, position)

    if position == enemyUnit.global_position:
        var hasArmor = true if int(StdScript.sum(enemyUnit.armor.values())) else false
        enemyUnit.applyDamaged(ammo.armorDamage if hasArmor else ammo.highExplosiveDamage)
    
    ammoCapacity -= 1

    if not ammoCapacity:
        isActive = false
        return


func shootAt(unit: Unit, panic: int, pos: Vector3) -> void:
    if not isActive:
        return
    
    var position: Vector3 = determinePosition(pos, getPrecision(panic))

    ammo.shoot(unit, position)

    ammoCapacity -= 1

    if not ammoCapacity:
        isActive = false
        return


func determinePosition(pos: Vector3, prec: int) -> Vector3:
    var rand: float = rng.randf()
    var coord: Vector3 = Vector3(cos(2 * rand * PI), pos.y, sin(2 * rand * PI))
    var probability: int = int(rand * 100)
    var hit: bool = prec < probability
    
    return pos + int((prec - probability) / 20. - 5) * coord if not hit else pos
