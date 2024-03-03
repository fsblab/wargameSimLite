extends GroundUnit


func _ready():
	setup(15., -10., 1)


func _enter_tree():
	set_multiplayer_authority(name.to_int())
