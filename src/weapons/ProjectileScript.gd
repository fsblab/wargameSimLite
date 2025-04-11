class_name ProjectileScript extends Node3D


@onready var blastArea: Area3D = $BlastArea
@onready var particleAnimation: GPUParticles3D = $Particle

var speed: float
var direction: Vector3
var isFlying: bool
var ignoreUnit: PhysicsBody3D
var shootingUnit: PhysicsBody3D
var directHitUnit: Unit
var ammo: Ammunition


func _ready() -> void:
	isFlying = false
	$selfDestructIfNothingIsHit.timeout.connect(qfree)
	particleAnimation.finished.connect(qfree)


func _physics_process(delta: float) -> void:
	if isFlying:
		global_position += direction * delta * speed


func fire(s: float, u: PhysicsBody3D, dir: Vector3, a: Ammunition, directHitU: Unit = null) -> void:
	shootingUnit = u
	shootingUnit.add_child(self)

	blastArea.body_entered.connect([struckSomething, struckEnemy][int(not directHitU == null)])

	directHitUnit = directHitU
	speed = s
	global_position = u.global_position + u.get_parent().shootFrom
	direction = dir
	ammo = a
	ignoreUnit = null
	particleAnimation.draw_pass_1.radius = ammo.effectiveRadius
	particleAnimation.draw_pass_1.height = ammo.effectiveRadius * 2
	isFlying = true


func struckSomething(body: Node3D) -> void:
	if not body is StaticBody3D:
		if body.get_parent() is Unit and not body == shootingUnit:
			body.get_parent().receiveDamage.rpc_id(body.get_parent().playerUid, ammo.serialize(), true)
			ignoreUnit = body
		elif body == shootingUnit:
			return
	
	explode()


func struckEnemy(body: Node3D) -> void:
	if body == shootingUnit:
		return
	
	directHitUnit.receiveDamage.rpc_id(directHitUnit.playerUid, ammo.serialize(), true)
	ignoreUnit = directHitUnit.model

	explode()


func explode() -> void:
	particleAnimation.restart()
	
	$MeshInstance3D.visible = false
	isFlying = false
	blastArea.get_node("BlastRadius").shape.radius = ammo.effectiveRadius
	var hits: Array = blastArea.get_overlapping_bodies()
	
	for unit: PhysicsBody3D in hits:
		if unit is StaticBody3D or unit == ignoreUnit:
			continue
		elif unit.get_parent() is Unit:
			unit.get_parent().receiveDamage.rpc_id(unit.get_parent().playerUid, ammo.serialize())


func qfree() -> void:
	queue_free()
