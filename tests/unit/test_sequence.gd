extends TestCase
## TEST-SEQ-01…04 — FR-SEQ-001…003.

const K := OrbType.Kind


func _sequence(provider: Callable, seed_value: int = 7) -> TargetSequence:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return TargetSequence.new(rng, provider)


func _orb(kind: OrbType.Kind) -> Orb:
	return Orb.new(0, kind, 1.0, 0.0, 0.0, kind)


func test_seq_01_no_consecutive_repeats() -> void:
	var sequence: TargetSequence = _sequence(func() -> Array[OrbType.Kind]: return OrbType.ALL_COLORS.duplicate())
	for i: int in 100000:
		if sequence.at(i + 1) == sequence.at(i):
			check(false, "repetición consecutiva en %d" % i)
			return


func test_seq_02_no_violet_with_three_colors() -> void:
	var sequence: TargetSequence = _sequence(func() -> Array[OrbType.Kind]: return OrbType.BASE_COLORS.duplicate())
	for i: int in 10000:
		if sequence.at(i) == K.VIOLET:
			check(false, "violeta generado con 3 colores activos")
			return


func test_seq_03_projection() -> void:
	var sequence: TargetSequence = _sequence(func() -> Array[OrbType.Kind]: return OrbType.BASE_COLORS.duplicate())
	var other: OrbType.Kind = K.CYAN
	for kind: OrbType.Kind in OrbType.BASE_COLORS:
		if kind != sequence.at(0) and kind != sequence.at(1):
			other = kind
	var in_flight: Array[Orb] = [_orb(sequence.at(0)), _orb(other)]
	check_eq(sequence.projected(in_flight), sequence.at(1), "ejemplo FR-SEQ-003")
	in_flight = [_orb(sequence.at(0)), _orb(sequence.at(1)), _orb(K.CRYSTAL)]
	check_eq(sequence.projected(in_flight), sequence.at(2), "dos objetivos y un cristal")


func test_seq_04_advance_rule() -> void:
	var sequence: TargetSequence = _sequence(func() -> Array[OrbType.Kind]: return OrbType.BASE_COLORS.duplicate())
	var first: OrbType.Kind = sequence.current()
	check(not sequence.on_consumed(K.CRYSTAL), "el cristal no avanza")
	var wrong: OrbType.Kind = K.CYAN if first != K.CYAN else K.MAGENTA
	check(not sequence.on_consumed(wrong), "un color distinto no avanza")
	check(sequence.on_consumed(first), "el color objetivo avanza")
	check_eq(sequence.index, 1, "idx tras avanzar")
