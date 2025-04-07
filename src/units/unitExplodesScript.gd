extends Node3D


@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var fire: GPUParticles3D = $Fire
@onready var smoke: GPUParticles3D = $Smoke


func _ready() -> void:
	fire.finished.connect(func(): fire.queue_free())
	smoke.finished.connect(func(): smoke.queue_free())
	audio.finished.connect(func(): audio.queue_free())

	fire.restart()
	smoke.restart()
