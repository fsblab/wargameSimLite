class_name GroundUnit extends Unit


func setArmor(front: int, back: int, top: int, sides: int) -> void:
	armor.BACK = back
	armor.FRONT = front
	armor.SIDES = sides
	armor.TOP = top
