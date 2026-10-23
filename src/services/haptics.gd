extends Node
## Vibración opcional (FR-HAP-001…003). Autoload «Haptics».

enum Kind { HIT, ERROR, PRISM }

var enabled: bool = true
## Número de llamadas reales de vibración (para pruebas).
var calls: int = 0
var _config: GameConfig = GameConfig.shared()


## Solo Android e iOS admiten vibración (FR-HAP-003).
func is_available() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios")


func vibrate(kind: Kind) -> void:
	if not enabled or not is_available():
		return
	var duration_ms: int = [_config.haptic_hit_ms, _config.haptic_error_ms, _config.haptic_prism_ms][kind]
	if duration_ms <= 0:
		return
	calls += 1
	Input.vibrate_handheld(duration_ms)
