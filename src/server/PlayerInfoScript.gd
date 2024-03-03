extends HBoxContainer


@onready var playerName: Label = $PlayerNameLabel
@onready var faction: OptionButton = $Faction
@onready var readyButton: Button = $Ready
@onready var kickButton: Button = $Kick


func _ready() -> void:
	playerName.text = SettingsConfigScript.currentPlayerInfo["name"]
	faction.select(SettingsConfigScript.currentPlayerInfo["faction"])


func toggleReady() -> void:
	readyButton.text = "✔️" if readyButton.text == "❌" else "❌"


func setPlayerNameColor(color: Color) -> void:
	playerName.add_theme_color_override("font_color", color)


func disableKickButton() -> void:
	kickButton.disabled = true
