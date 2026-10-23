extends TestCase
## Partida: TEST-GS-* (FR-GS-*), TEST-RES-* (FR-RES-001), TEST-INP-* (FR-INP-002…005),
## TEST-ENE-* (FR-ENE-*), TEST-SIM-01 (FR-SIM-002), TEST-SPN-* (FR-ORB-*, FR-SEQ-004, FR-EVT-002).

const K := OrbType.Kind
const S := GameSession.State
const R := GameSession.Result

var config := GameConfig.new()


func _session(spawning: bool = false, seed_value: int = 1) -> GameSession:
	var session := GameSession.new(config, seed_value)
	session.set_spawning_enabled(spawning)
	session.start()
	return session


func _other_color(session: GameSession) -> OrbType.Kind:
	for kind: OrbType.Kind in OrbType.BASE_COLORS:
		if kind != session.sequence.current():
			return kind
	return K.CYAN


func _results(session: GameSession) -> Array[int]:
	var results: Array[int] = []
	session.orb_resolved.connect(func(_orb: Orb, result: GameSession.Result, _points: int) -> void: results.append(result))
	return results


# --- Estados (FR-GS-001…007) ---

func test_gs_01_start_initializes() -> void:
	var session := GameSession.new(config, 3)
	check_eq(session.state, S.PRE_START, "estado inicial")
	check(not session.request_pulse(), "sin pulsos en PRE_START (FR-INP-005)")
	check(session.start(), "T01")
	check_eq(session.state, S.PLAYING, "PLAYING")
	check_eq(session.t, 0.0, "t = 0")
	check_eq(session.energy, 100, "E inicial")
	check_eq(session.score, 0, "puntuación 0")
	check_eq(session.stats.empty_pulses, 0, "el toque inicial no genera pulso")
	check_eq(session.orbs.size(), 1, "primer orbe en t = 0 (FR-ORB-002)")


func test_gs_02_pause_from_pre_start_returns_to_pre_start() -> void:
	var session := GameSession.new(config, 3)
	check(session.pause(), "T02")
	check(session.resume(), "T05")
	check_eq(session.state, S.PRE_START, "vuelve a PRE_START")


func test_gs_03_pause_freezes_everything() -> void:
	var session := _session(true)
	for i: int in 30:
		session.step()
	var radius: float = session.orbs[0].radius
	var t: float = session.t
	check(session.pause(), "T03")
	for i: int in 600:
		session.step()
	session.update_real_time(10.0)
	check_eq(session.orbs[0].radius, radius, "orbes congelados")
	check_eq(session.t, t, "t congelado")
	check(not session.request_pulse(), "sin pulsos en pausa")


func test_gs_04_resume_countdown() -> void:
	var session := _session()
	session.pause()
	check(session.resume(), "T04")
	check_eq(session.state, S.RESUMING, "RESUMING")
	session.update_real_time(1.0)
	check_eq(session.state, S.RESUMING, "sigue la cuenta atrás a 1.0 s")
	session.update_real_time(0.51)
	check_eq(session.state, S.PLAYING, "T06 tras 1.5 s")


func test_gs_05_pause_during_resuming() -> void:
	var session := _session()
	session.pause()
	session.resume()
	check(session.pause(), "T07")
	check_eq(session.state, S.PAUSED, "PAUSED")
	session.resume()
	check_eq(session.state, S.RESUMING, "vuelve a reanudar con origen PLAYING")


func test_gs_06_abandon_only_from_pause() -> void:
	var session := _session()
	check(not session.abandon(), "no se abandona desde PLAYING")
	session.pause()
	check(session.abandon(), "T10")
	check_eq(session.state, S.ABANDONED, "ABANDONED")
	check(not session.resume(), "terminal")
	check(not session.pause(), "terminal")


func test_gs_07_terminal_ignores_input() -> void:
	var session := _session()
	session.energy = 35
	session.inject_orb(_other_color(session), 0.30)
	session.request_pulse()
	session.step()
	check_eq(session.state, S.GAME_OVER, "GAME_OVER")
	check(not session.request_pulse(), "sin pulsos")
	check(not session.pause(), "sin pausa")
	check(not session.start(), "sin reinicio")


func test_gs_08_invalid_config_refuses_to_start() -> void:
	expected_errors = 1
	var bad := GameConfig.new()
	bad.energy_start = 0
	var session := GameSession.new(bad, 1)
	check(not session.start(), "FR-FAIR-005")
	check_eq(session.state, S.PRE_START, "no inicia")


# --- Resolución (FR-RES-001, una prueba por fila) ---

func test_res_01_hit() -> void:
	var session := _session()
	var target: OrbType.Kind = session.sequence.current()
	session.energy = 50
	var results: Array[int] = _results(session)
	session.inject_orb(target, 0.30)
	session.request_pulse()
	session.step()
	check_eq(results, [R.HIT] as Array[int], "acierto")
	check_eq(session.combo.count, 1, "c+1")
	check_eq(session.score, 100, "puntos")
	check_eq(session.energy, 51, "+1 energía")
	check_eq(session.prism.charge, 4, "+4 carga")
	check_eq(session.sequence.index, 1, "avanza")


func test_res_02_color_error() -> void:
	var session := _session()
	for i: int in 3:
		session.combo.on_hit()
	session.prism.charge = 63
	var results: Array[int] = _results(session)
	session.inject_orb(_other_color(session), 0.30)
	session.request_pulse()
	session.step()
	check_eq(results, [R.ERROR_COLOR] as Array[int], "error de color")
	check_eq(session.combo.count, 0, "c = 0")
	check_eq(session.score, 0, "sin puntos")
	check_eq(session.energy, 65, "−35")
	check_eq(session.prism.charge, 31, "floor(Q/2)")
	check_eq(session.sequence.index, 0, "no avanza")


func test_res_03_crystal_hit() -> void:
	var session := _session()
	var results: Array[int] = _results(session)
	session.energy = 50
	session.inject_orb(K.CRYSTAL, 0.30)
	session.request_pulse()
	session.step()
	check_eq(results, [R.HIT_CRYSTAL] as Array[int], "acierto cristal")
	check_eq(session.combo.count, 1, "c+1")
	check_eq(session.score, 100, "puntos")
	check_eq(session.energy, 51, "+1")
	check_eq(session.prism.charge, 20, "+20 carga")
	check_eq(session.stats.crystals_from_orbs, 3, "+3 cristales")
	check_eq(session.sequence.index, 0, "no avanza")


func test_res_04_prism_capture_any() -> void:
	var session := _session()
	session.prism.charge = 100
	session.prism.try_activate()
	var results: Array[int] = _results(session)
	session.inject_orb(_other_color(session), 0.30)
	session.request_pulse()
	session.step()
	check_eq(results, [R.HIT] as Array[int], "acierto PRISM con color no objetivo")
	check_eq(session.score, 200, "×2")
	check_eq(session.prism.charge, 0, "carga bloqueada")
	check_eq(session.sequence.index, 0, "no avanza (color ≠ objetivo)")
	session.inject_orb(session.sequence.current(), 0.30)
	session.step()
	session.step()
	session.step()
	session.step()
	session.step()
	session.step()
	session.step()
	session.step()
	session.step()
	session.request_pulse()
	session.step()
	check_eq(session.sequence.index, 1, "avanza (color = objetivo)")


func test_res_05_empty_pulse() -> void:
	var session := _session()
	session.combo.on_hit()
	var empties: Array[int] = [0]
	session.pulse_empty.connect(func() -> void: empties[0] += 1)
	session.request_pulse()
	session.step()
	check_eq(empties[0], 1, "pulso vacío")
	check_eq(session.combo.count, 1, "combo intacto")
	check_eq(session.energy, 100, "energía intacta")


func test_res_06_omission() -> void:
	var session := _session()
	var target: OrbType.Kind = session.sequence.current()
	var results: Array[int] = _results(session)
	session.inject_orb(target, 0.175)
	session.step()
	check_eq(results, [R.OMISSION] as Array[int], "omisión")
	check_eq(session.energy, 65, "−35")
	check_eq(session.sequence.index, 1, "avanza")


func test_res_07_discard_non_target() -> void:
	var session := _session()
	var results: Array[int] = _results(session)
	session.inject_orb(_other_color(session), 0.175)
	session.step()
	check_eq(results, [R.DISCARD] as Array[int], "descarte")
	check_eq(session.energy, 100, "sin penalización")
	check_eq(session.sequence.index, 0, "no avanza")


func test_res_08_discard_crystal() -> void:
	var session := _session()
	var results: Array[int] = _results(session)
	session.inject_orb(K.CRYSTAL, 0.175)
	session.step()
	check_eq(results, [R.DISCARD] as Array[int], "descarte cristal")
	check_eq(session.energy, 100, "sin penalización")


func test_res_09_prism_impact_neutral_but_advances() -> void:
	var session := _session()
	session.prism.charge = 100
	session.prism.try_activate()
	var results: Array[int] = _results(session)
	session.inject_orb(session.sequence.current(), 0.175)
	session.step()
	check_eq(results, [R.DISCARD] as Array[int], "descarte en PRISM")
	check_eq(session.energy, 100, "sin penalización")
	check_eq(session.sequence.index, 1, "avanza (regla FR-SEQ-002)")


func test_res_10_pulse_before_impact_in_same_step() -> void:
	# E01: el pulso se resuelve antes del movimiento.
	var session := _session()
	var results: Array[int] = _results(session)
	session.inject_orb(session.sequence.current(), 0.1705)
	session.request_pulse()
	session.step()
	check_eq(results, [R.HIT] as Array[int], "captura antes del impacto")


# --- Entrada (FR-INP-002/003) ---

func test_inp_01_one_pulse_per_step() -> void:
	var session := _session()
	check(session.request_pulse(), "primer toque")
	check(not session.request_pulse(), "segundo toque en el mismo paso descartado")


func test_inp_02_cooldown() -> void:
	var session := _session()
	session.request_pulse()
	session.step()
	for i: int in 6:
		session.step()
	check(not session.request_pulse(), "a los 0.10 s se descarta")
	for i: int in 4:
		session.step()
	check(session.request_pulse(), "a los ~0.17 s se acepta")


# --- Energía y fin (FR-ENE-*) ---

func test_ene_01_three_errors_game_over() -> void:
	var session := _session()
	var values: Array[int] = []
	for i: int in 3:
		session.inject_orb(_other_color(session), 0.30)
		session.request_pulse()
		session.step()
		values.append(session.energy)
		for j: int in 10:
			session.step()
	check_eq(values, [65, 30, 0] as Array[int], "100 → 65 → 30 → 0")
	check_eq(session.state, S.GAME_OVER, "T08")
	check_eq(session.orbs.size(), 0, "orbes eliminados (FR-ENE-005)")


func test_ene_02_completed_at_max_time() -> void:
	var session := _session()
	var steps: int = 0
	while session.state == S.PLAYING and steps < 10000:
		session.step()
		steps += 1
	check_eq(session.state, S.COMPLETED, "T09")
	check_eq(steps, 5400, "90 s = 5400 pasos")
	check(session.stats.duration <= config.session_max_time + config.sim_step, "duración ≤ 90 s + paso")


func test_ene_03_game_over_wins_tie_with_time_cap() -> void:
	var session := _session()
	session.steps = 5399
	session.energy = 35
	session.inject_orb(session.sequence.current(), 0.175)
	session.step()
	check_eq(session.state, S.GAME_OVER, "E07: prevalece GAME_OVER")


func test_ene_04_critical_flag() -> void:
	var session := _session()
	var critical: Array[bool] = []
	session.energy_changed.connect(func(_value: int, is_critical: bool) -> void: critical.append(is_critical))
	session.inject_orb(_other_color(session), 0.30)
	session.request_pulse()
	session.step()
	check_eq(critical.back(), false, "E=65 no crítico")
	for j: int in 10:
		session.step()
	session.inject_orb(_other_color(session), 0.30)
	session.request_pulse()
	session.step()
	check_eq(critical.back(), true, "E=30 crítico")


# --- Generación (FR-ORB-002/003, FR-SEQ-004, FR-EVT-002) ---

func test_spn_01_first_spawn_and_interval() -> void:
	var session := _session(true)
	check_eq(session.orbs[0].spawn_time, 0.0, "primera aparición en t=0")
	while session.orbs.size() < 2:
		session.step()
	check_near(session.orbs[1].spawn_time, 1.10, config.sim_step, "segunda aparición a 1.10 s")


func test_spn_02_angle_gap_and_pity() -> void:
	for seed_value: int in 40:
		var session := _session(true, seed_value)
		var last_angle: float = -1.0
		var streak: int = 0
		var violations: Array[String] = []
		session.orb_spawned.connect(func(orb: Orb) -> void:
			if last_angle >= 0.0:
				var diff: float = absf(fposmod(orb.angle_deg - last_angle + 180.0, 360.0) - 180.0)
				if diff < config.orb_min_angle_gap - 1e-6:
					violations.append("ángulo %.2f" % diff)
			last_angle = orb.angle_deg
			if OrbType.is_color(orb.kind):
				streak = 0 if orb.kind == orb.projected_target else streak + 1
				if streak > config.pity_max_non_target:
					violations.append("racha %d" % streak))
		for i: int in 5400:
			session.step()
			# Bot perfecto para que la partida dure.
			var orb: Orb = session.orb_in_zone()
			if orb != null and session.capture_would_hit(orb):
				session.request_pulse()
		check(violations.is_empty(), "semilla %d: %s" % [seed_value, ", ".join(violations)])


func test_spn_03_crystal_conditions() -> void:
	var total: int = 0
	for seed_value: int in 60:
		var session := _session(true, seed_value)
		var times: Array[float] = []
		session.orb_spawned.connect(func(orb: Orb) -> void:
			if orb.kind == K.CRYSTAL:
				check(not session.prism.active, "sin cristales en PRISM")
				times.append(orb.spawn_time))
		while session.state == S.PLAYING:
			var orb: Orb = session.orb_in_zone()
			if orb != null and session.capture_would_hit(orb):
				session.request_pulse()
			session.step()
		total += times.size()
		check(times.size() <= config.crystal_max_per_session, "máximo por partida")
		for i: int in times.size():
			check(times[i] >= config.crystal_min_time - 1e-6, "tras 10 s")
			if i > 0:
				check(times[i] - times[i - 1] >= config.crystal_cooldown - 1e-6, "separación ≥ 8 s")
	check(total > 0, "aparecen orbes cristal en 60 partidas (%d)" % total)


# --- Determinismo e invariantes ---

func _play(seed_value: int) -> Array:
	var session := _session(true, seed_value)
	session.debug_checks = true
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 31
	var history: Array = []
	session.orb_spawned.connect(func(orb: Orb) -> void: history.append([orb.kind, orb.angle_deg, orb.spawn_time]))
	while session.state == S.PLAYING:
		if rng.randf() < 0.05:
			session.request_pulse()
		session.step()
	history.append([session.score, session.stats.hits, session.stats.color_errors, session.stats.omissions, session.steps, session.invariant_violations])
	return history


func test_sim_01_determinism() -> void:
	var reference: Array = _play(12345)
	for i: int in 100:
		if _play(12345) != reference:
			check(false, "repetición %d distinta" % i)
			return
	check(_play(54321) != reference, "otra semilla produce otra partida")


func test_fair_01_invariants_random_play() -> void:
	for seed_value: int in 500:
		var history: Array = _play(seed_value)
		var violations: int = history.back()[5]
		if violations > 0:
			check(false, "semilla %d: %d violaciones" % [seed_value, violations])
			return
