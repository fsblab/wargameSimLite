class_name ProjectileScript extends Node3D


@onready var blastArea: Area3D = $BlastArea
@onready var particleAnimation: GPUParticles3D = $Particle

var speed: float
var direction: Vector3
var isFlying: bool
var ignoreUnit: PhysicsBody3D
var shootingUnit: PhysicsBody3D
var ammo: Ammunition


func _ready() -> void:
	isFlying = false
	blastArea.body_entered.connect(struckSomething)
	$selfDestructIfNothingIsHit.timeout.connect(qfree)
	particleAnimation.finished.connect(qfree)


func _physics_process(delta: float) -> void:
	if isFlying:
		global_position += direction * delta * speed


func setup(s: float, u: PhysicsBody3D, dir: Vector3, a: Ammunition) -> void:
	shootingUnit = u
	shootingUnit.add_child(self)

	speed = s
	global_position = u.global_position + u.get_parent().shootFrom
	direction = dir
	ammo = a

	ignoreUnit = null

	particleAnimation.draw_pass_1.radius = ammo.effectiveRadius
	particleAnimation.draw_pass_1.height = ammo.effectiveRadius * 2


func fire() -> void:
	isFlying = true


func struckSomething(body: Node3D) -> void:
	if not body is StaticBody3D:
		if body.get_parent() is Unit and not body == shootingUnit:
			body.get_parent().receiveDamage.rpc_id(body.get_parent().playerUid, ammo.serialize(), true)
			ignoreUnit = body
		elif body == shootingUnit:
			return
	
	particleAnimation.restart()
	
	$MeshInstance3D.visible = false
	isFlying = false
	blastArea.get_node("BlastRadius").shape.radius = ammo.effectiveRadius
	var hits: Array = blastArea.get_overlapping_bodies()
	
	for unit: PhysicsBody3D in hits:
		if unit is StaticBody3D or unit == ignoreUnit:
			continue
		unit.get_parent().receiveDamage.rpc_id(unit.get_parent().playerUid, ammo.serialize())


func qfree() -> void:
	queue_free()
