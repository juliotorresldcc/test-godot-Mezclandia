class_name ComboTracker
extends RefCounted
## Estados del combo (FR-CMB-001) y mejor combo (FR-CMB-003).

enum State { IDLE, ACTIVE, BROKEN }

var count: int = 0
var state: State = State.IDLE
var best: int = 0

var _config: GameConfig
var _broken_time_left: float = 0.0


func _init(config: GameConfig) -> void:
	_config = config


func tier() -> int:
	return ScoreRules.tier(_config, count)


## Registra un acierto. Devuelve true si sube el nivel de combo.
func on_hit() -> bool:
	var previous_tier: int = tier()
	count += 1
	state = State.ACTIVE
	best = maxi(best, count)
	return tier() > previous_tier


## Registra un error. Devuelve el combo previo (0 si no había combo).
func on_error() -> int:
	var previous: int = count
	count = 0
	if previous >= 1:
		state = State.BROKEN
		_broken_time_left = _config.combo_broken_feedback
	return previous


## Avanza el tiempo de juego; cierra la ventana de COMBO_BROKEN.
func advance(dt: float) -> void:
	if state == State.BROKEN:
		_broken_time_left -= dt
		if _broken_time_left <= 1e-9:
			state = State.IDLE
