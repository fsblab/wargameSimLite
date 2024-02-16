extends DirectionalLight3D


func setShadow(enable: bool) -> void:
	shadow_enabled = enable


func setDirectionalShadowMode(index: int) -> void:
	directional_shadow_mode = SettingsConfigScript.shadowOptions[index]
