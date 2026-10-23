class_name SessionStats
extends RefCounted
## Estadísticas de una partida (FR-STAT-001).

var score: int = 0
var duration: float = 0.0
var hits: int = 0
var color_errors: int = 0
var omissions: int = 0
var empty_pulses: int = 0
var discards: int = 0
var best_combo: int = 0
var prism_activations: int = 0
var crystal_orbs: int = 0
var crystals_from_orbs: int = 0
## Estado final (GameSession.State) o -1 si la partida no ha terminado.
var end_state: int = -1


func accuracy() -> int:
	return ScoreRules.accuracy(hits, color_errors, omissions)
