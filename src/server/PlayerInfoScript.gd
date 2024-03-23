extends HBoxContainer


@onready var playerName: Label = $PlayerNameLabel
@onready var readyButton: Button = $Ready
@onready var kickButton: Button = $Kick


func toggleReady() -> void:
	readyButton.text = "✔️" if readyButton.text == "❌" else "❌"


func setPlayerNameColor(color: Color) -> void:
	playerName.add_theme_color_override("font_color", color)


func disableKickButton() -> void:
	kickButton.disabled = true
