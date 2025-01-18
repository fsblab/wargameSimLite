extends Control


signal _backFromCredits

func backToMainMenu() -> void:
	_backFromCredits.emit()
