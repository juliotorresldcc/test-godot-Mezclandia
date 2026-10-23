class_name TargetSequence
extends RefCounted
## Secuencia de objetivos, regla de avance y proyección (FR-SEQ-001…003).

## Índice del objetivo vigente (idx).
var index: int = 0

var _sequence: Array[OrbType.Kind] = []
var _rng: RandomNumberGenerator
## Devuelve los colores activos en el instante de generar un elemento.
var _active_colors: Callable


func _init(rng: RandomNumberGenerator, active_colors_provider: Callable) -> void:
	_rng = rng
	_active_colors = active_colors_provider


## Elemento i de la secuencia; genera bajo demanda los que falten.
func at(i: int) -> OrbType.Kind:
	while _sequence.size() <= i:
		_generate_next()
	return _sequence[i]


func current() -> OrbType.Kind:
	return at(index)


func next() -> OrbType.Kind:
	return at(index + 1)


func generated_count() -> int:
	return _sequence.size()


## Objetivo que regirá cuando llegue un orbe nuevo, dados los orbes en vuelo en orden de llegada.
func projected(orbs_in_flight: Array[Orb]) -> OrbType.Kind:
	var j: int = index
	for orb: Orb in orbs_in_flight:
		if OrbType.is_color(orb.kind) and orb.kind == at(j):
			j += 1
	return at(j)


## Regla de avance FR-SEQ-002. Devuelve true si el objetivo avanzó.
func on_consumed(kind: OrbType.Kind) -> bool:
	if OrbType.is_color(kind) and kind == current():
		index += 1
		return true
	return false


func _generate_next() -> void:
	var candidates: Array[OrbType.Kind] = _active_colors.call()
	if not _sequence.is_empty():
		candidates.erase(_sequence.back())
	_sequence.append(candidates[_rng.randi_range(0, candidates.size() - 1)])
