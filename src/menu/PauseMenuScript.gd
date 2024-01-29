extends Control


@onready var canvas = $CanvasLayer


func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	canvas.visible = false


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().paused = !get_tree().paused
			visible = !visible
			canvas.visible = !canvas.visible
