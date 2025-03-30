class_name UnitAttributesScript extends Object


enum typeOfDistance {
    FAR,
    MEDIUMFAR,
    MEDIUM,
    MEDIUMLOW,
    LOW,
}

enum typeOfQuality {
    ECEPTIONAL,
    GOOD,
    MEDIUM,
    BAD,
    BLIND
}

enum unitStatus {
	PLACED,
	SPAWNED,
	DESTROYED
}

enum weaponTypes {
    MAINWEAPON,
    ARMORPENETRATION,
    HIGHEXPLOSIVE,
    SMALLCALIBER
}

const distance = {
    typeOfDistance.FAR: 60,
    typeOfDistance.MEDIUMFAR: 50,
    typeOfDistance.MEDIUM: 40,
    typeOfDistance.MEDIUMLOW: 30,
    typeOfDistance.LOW: 20
}

const panicStatus: Dictionary = {
	"FINE" = 80,
	"SHAKEN" = 50,
	"PANIC" = 20,
	"ROUTING" = 0
}