extends SceneTree
## Simulaciones masivas: SC-001 (duración), SC-002 (invariantes), E17 (spam).
## Uso: godot --headless --path . --audio-driver Dummy --script res://tests/sim/run_sim.gd [-- N]
## Código de salida 1 si algún criterio no se cumple.

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var sessions: int = int(args[0]) if args.size() > 0 else 1000
	var invariant_sessions: int = sessions * 10
	var config := GameConfig.new()
	var ok: bool = true
	var summaries: Dictionary[String, Dictionary] = {}
	for bot: SimBot.Kind in [SimBot.Kind.NOVICE, SimBot.Kind.EXPERT, SimBot.Kind.SPAM, SimBot.Kind.PASSIVE]:
		summaries[SimBot.Kind.keys()[bot]] = _run_bot(bot, sessions, config, true)
	for name: String in summaries:
		print("%-8s %s" % [name, summaries[name]])

	var novice: Dictionary = summaries["NOVICE"]
	var expert: Dictionary = summaries["EXPERT"]
	var spam: Dictionary = summaries["SPAM"]
	ok = _criterion("SC-001 mediana NOVATO en [30, 60] s", novice["median_s"] >= 30.0 and novice["median_s"] <= 60.0) and ok
	ok = _criterion("SC-001 mediana EXPERTO ≥ 75 s", expert["median_s"] >= 75.0) and ok
	var max_allowed: float = config.session_max_time + config.sim_step + 1e-6
	var longest: float = 0.0
	for summary: Dictionary in summaries.values():
		longest = maxf(longest, summary["max_s"])
	ok = _criterion("SC-001 ninguna partida > 90 s + paso (máx %.4f s)" % longest, longest <= max_allowed) and ok
	ok = _criterion("E17 puntuación media SPAM < NOVATO", spam["mean_score"] < novice["mean_score"]) and ok

	var random_summary: Dictionary = _run_bot(SimBot.Kind.RANDOM, invariant_sessions, config, true)
	print("RANDOM   %s" % random_summary)
	# SC-002: invariantes comprobados en todas las partidas (las largas cubren PRISM, cristal y violeta).
	var checked: int = invariant_sessions + 4 * sessions
	var violations: int = random_summary["violations"]
	for summary: Dictionary in summaries.values():
		violations += summary["violations"]
	ok = _criterion("SC-002 0 violaciones de invariantes en %d partidas" % checked, violations == 0) and ok
	print("\nRESULTADO SIMULACIÓN: %s" % ("APROBADO" if ok else "FALLIDO"))
	quit(0 if ok else 1)


func _run_bot(bot: SimBot.Kind, count: int, config: GameConfig, debug_checks: bool) -> Dictionary:
	var durations: Array[float] = []
	var total_score: int = 0
	var completed: int = 0
	var violations: int = 0
	var crystals: int = 0
	var prism: int = 0
	for i: int in count:
		var session: GameSession = SimBot.play(bot, 100000 + i, config, debug_checks)
		durations.append(session.stats.duration)
		total_score += session.score
		completed += int(session.state == GameSession.State.COMPLETED)
		violations += session.invariant_violations
		crystals += session.stats.crystal_orbs
		prism += session.stats.prism_activations
	durations.sort()
	return {
		"n": count,
		"median_s": snappedf(durations[count / 2], 0.01),
		"p10_s": snappedf(durations[count / 10], 0.01),
		"p90_s": snappedf(durations[count * 9 / 10], 0.01),
		"max_s": durations.back(),
		"mean_score": total_score / count,
		"completed_pct": snappedf(100.0 * completed / count, 0.1),
		"crystal_orbs_mean": snappedf(float(crystals) / count, 0.01),
		"prism_mean": snappedf(float(prism) / count, 0.01),
		"violations": violations,
	}


func _criterion(label: String, passed: bool) -> bool:
	print("%s  %s" % ["OK   " if passed else "FALLO", label])
	return passed
