class_name ScoreRules
extends RefCounted
## Fórmulas de puntuación y combo (FR-SCO-001/002, FR-CMB-002, FR-STAT-002).


## m(c) = min(mult_max, 1 + mult_step · floor(c / combo_step)).
static func multiplier(config: GameConfig, combo: int) -> float:
	var tiers: int = floori(float(combo) / float(config.combo_step))
	return minf(config.mult_max, 1.0 + config.mult_step * tiers)


## Puntos de un acierto con el combo ya incrementado; round_half_up(x) = floor(x + 0.5).
static func points(config: GameConfig, combo: int, prism_active: bool) -> int:
	var k: float = config.prism_score_factor if prism_active else 1.0
	return floori(config.score_base * multiplier(config, combo) * k + 0.5)


## Nivel de combo visible: 0 … floor((mult_max − 1) / mult_step).
static func tier(config: GameConfig, combo: int) -> int:
	var max_tier: int = floori((config.mult_max - 1.0) / config.mult_step + 1e-9)
	return mini(floori(float(combo) / float(config.combo_step)), max_tier)


## Precisión en % entero (FR-STAT-002).
static func accuracy(hits: int, color_errors: int, omissions: int) -> int:
	var total: int = hits + color_errors + omissions
	if total == 0:
		return 0
	return floori(100.0 * hits / total)
