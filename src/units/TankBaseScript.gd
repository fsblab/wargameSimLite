extends GroundUnit


func _ready():
	super()
	setup(15., -10., 1, GameMetaDataScript.unitName.MBT, 0, 1, UnitAttributesScript.distance[UnitAttributesScript.typeOfDistance.MEDIUM], 10)
	#setArmor(10, 3, 5, 1)
	setArmor(2, 2, 2, 2)
	shootFrom = Vector3(0, 1.5, 2.5)
	var mainWeapon: Weapon = TankCannonHEAT.new()
	setWeapons([mainWeapon, TankCannonAP.new(), mainWeapon])


func reloadWeapon(weapon: Weapon) -> void:
	weapons[UnitAttributesScript.weaponTypes.ARMORPENETRATION].isActive = false
	weapons[UnitAttributesScript.weaponTypes.HIGHEXPLOSIVE].isActive = false

	reloadTimer.wait_time = weapon.reloadTime
	reloadTimer.start()

	await reloadTimer.timeout

	weapons[UnitAttributesScript.weaponTypes.ARMORPENETRATION].isActive = true
	weapons[UnitAttributesScript.weaponTypes.HIGHEXPLOSIVE].isActive = true
