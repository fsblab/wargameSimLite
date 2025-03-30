class_name TankCannonAP extends Weapon


func _init() -> void:
    super(
        Ammunition.new(16, 0, 0, "APFSDS", 10),
        14,
        "Tank Cannon (AP)",
        70,
        UnitAttributesScript.distance[UnitAttributesScript.typeOfDistance.MEDIUM],
        ResourceLoader.load("res://assets/sprites/weapons/apfsds.png", "Texture2D")
    )