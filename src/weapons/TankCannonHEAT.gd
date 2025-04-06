class_name TankCannonHEAT extends Weapon


func _init() -> void:
    super(
        Ammunition.new(8, 2, 2, "HEAT", 10),
        10,
        "Tank Cannon (HEAT)",
        70,
        8,
        UnitAttributesScript.distance[UnitAttributesScript.typeOfDistance.MEDIUM],
        ResourceLoader.load("res://assets/sprites/weapons/heat.png", "Texture2D")
    )