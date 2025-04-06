class_name ProjectileScript extends Node3D


@onready var blastArea: Area3D = get_node("BlastArea")

var speed: float
var direction: Vector3
var isFlying: bool
var ignoreUnit: Unit
var shootingUnit: PhysicsBody3D
var ammo: Ammunition


func _ready() -> void:
	isFlying = false
	blastArea.body_entered.connect(struckSomething)
	get_node("selfDestructIfNothingIsHit").timeout.connect(selfDestruct)


func _physics_process(delta: float) -> void:
	if isFlying:
		global_position += direction * delta * speed


func setup(s: float, u: PhysicsBody3D, dir: Vector3, iu: Unit, a: Ammunition) -> void:
	shootingUnit = u
	shootingUnit.add_child(self)

	speed = s
	global_position = u.global_position + Vector3(0, 1, 0)
	direction = dir
	ignoreUnit = iu
	ammo = a


func fire() -> void:
	isFlying = true


func struckSomething(body: Node3D) -> void:
	if not body is StaticBody3D:
		if body.get_parent() is Unit and not body == shootingUnit:
			body.get_parent().receiveDamage.rpc_id(body.get_parent().playerUid, ammo.serialize(), true)
		elif body == shootingUnit:
			return

	isFlying = false
	blastArea.get_node("BlastRadius").shape.radius = ammo.effectiveRadius
	var hits: Array = blastArea.get_overlapping_bodies()
	
	for unit: PhysicsBody3D in hits:
		if unit is StaticBody3D or ignoreUnit:
			continue
		unit.get_parent().receiveDamage.rpc_id(unit.get_parent().playerUid, ammo.serialize())
	
	queue_free()


func selfDestruct() -> void:
	queue_free()
