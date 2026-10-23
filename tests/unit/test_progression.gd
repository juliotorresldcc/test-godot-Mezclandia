extends TestCase
## TEST-PRG-* (FR-PRG-*, FR-SCO-004, FR-STAT-010, FR-GS-006) y TEST-MIS-* (FR-MIS-*).

var config := GameConfig.new()


func _system() -> ProgressionSystem:
	return ProgressionSystem.new(Profile.create_new(42, config), config)


func _stats(score: int, end_state: GameSession.State, crystal_orbs: int = 0) -> SessionStats:
	var stats := SessionStats.new()
	stats.score = score
	stats.end_state = end_state
	stats.crystal_orbs = crystal_orbs
	stats.crystals_from_orbs = crystal_orbs * config.crystal_orb_reward
	stats.duration = 45.0
	stats.hits = 30
	stats.best_combo = 12
	return stats


func test_prg_01_crystal_formula_example() -> void:
	var system := _system()
	var rewards: ProgressionSystem.SessionRewards = system.apply_session(_stats(12345, GameSession.State.COMPLETED, 2))
	check_eq(rewards.crystals_from_score, 12, "floor(12345/1000)")
	check_eq(rewards.crystals_from_orbs, 6, "3·2")
	check_eq(rewards.crystals_from_completion, 5, "bonificación")
	check_eq(rewards.total(), 23, "ejemplo FR-PRG-001")
	check_eq(system.profile.crystals, 23, "saldo")


func test_prg_02_no_completion_bonus_on_game_over() -> void:
	var system := _system()
	check_eq(system.apply_session(_stats(999, GameSession.State.GAME_OVER)).total(), 0, "999 puntos → 0")


func test_prg_03_record_strictly_greater() -> void:
	var system := _system()
	check(system.apply_session(_stats(5000, GameSession.State.GAME_OVER)).new_record, "primer récord")
	check(not system.apply_session(_stats(5000, GameSession.State.GAME_OVER)).new_record, "empate no es récord (E11)")
	check(system.apply_session(_stats(5001, GameSession.State.GAME_OVER)).new_record, "mayor es récord")
	check_eq(system.profile.stats["best_score"], 5001, "récord guardado")


func test_prg_04_purchase_exact_balance() -> void:
	var system := _system()
	system.profile.crystals = 40
	check_eq(system.item_state("core_pulsar"), ProgressionSystem.ItemState.AVAILABLE, "disponible")
	check(system.purchase("core_pulsar"), "compra")
	check_eq(system.profile.crystals, 0, "saldo 0 (E12)")
	check_eq(system.item_state("core_pulsar"), ProgressionSystem.ItemState.EQUIPPED, "equipado tras comprar")
	check_eq(system.item_state("core_default"), ProgressionSystem.ItemState.OWNED, "el anterior queda poseído")


func test_prg_05_purchase_insufficient_is_atomic() -> void:
	var system := _system()
	system.profile.crystals = 39
	check_eq(system.item_state("core_pulsar"), ProgressionSystem.ItemState.INSUFFICIENT, "insuficiente")
	check(not system.purchase("core_pulsar"), "compra rechazada")
	check_eq(system.profile.crystals, 39, "saldo intacto")
	check("core_pulsar" not in system.profile.owned, "no poseído")


func test_prg_06_equip_owned_only() -> void:
	var system := _system()
	check(not system.equip("trail_comet"), "no se equipa lo no poseído")
	system.profile.crystals = 200
	system.purchase("trail_comet")
	check(system.equip("trail_default"), "equipa poseído")
	check_eq(system.profile.equipped["trail"], "trail_default", "equipado")


func test_prg_07_balance_cap_overflow() -> void:
	var system := _system()
	system.profile.crystals = config.crystals_balance_cap - 2
	system.apply_session(_stats(10000, GameSession.State.GAME_OVER))
	check_eq(system.profile.crystals, config.crystals_balance_cap, "límite")
	check_eq(system.profile.stats["crystals_overflow"], 8, "excedente registrado (E19)")


func test_prg_08_abandoned_changes_nothing_but_stat() -> void:
	var system := _system()
	var before: Dictionary = system.profile.to_dict()
	system.register_abandoned()
	var after: Dictionary = system.profile.to_dict()
	check_eq(after["stats"]["sessions_abandoned"], 1, "estadística de abandono")
	after["stats"]["sessions_abandoned"] = 0
	check_eq(after, before, "nada más cambia (FR-GS-006)")


func test_prg_09_onboarding_first_sessions() -> void:
	var system := _system()
	var shown: Array[bool] = []
	for i: int in 4:
		system.register_session_started()
		shown.append(system.should_show_onboarding())
	check_eq(shown, [true, true, true, false] as Array[bool], "3 primeras partidas")


func test_mis_01_initial_missions() -> void:
	var profile := Profile.create_new(1, config)
	var ids: Array[String] = []
	for mission: Profile.MissionState in profile.missions:
		ids.append(mission.template_id)
	check_eq(ids, ["M_HITS_SESSION", "M_COMBO", "M_SESSIONS"] as Array[String], "FR-MIS-006")
	check_eq(profile.missions[0].target, 20, "20 aciertos")
	check_eq(profile.missions[1].target, 10, "combo 10")
	check_eq(profile.missions[2].target, 3, "3 partidas")
	check_eq(profile.missions[0].reward, 10, "recompensa k=0")


func test_mis_02_per_session_takes_best_value() -> void:
	var system := _system()
	var stats := _stats(100, GameSession.State.GAME_OVER)
	stats.hits = 12
	system.apply_session(stats)
	stats.hits = 8
	system.apply_session(stats)
	check_eq(system.profile.missions[0].progress, 12, "mejor valor de una partida")


func test_mis_03_cumulative_and_completion() -> void:
	var system := _system()
	var completed: Array[int] = []
	for i: int in 3:
		completed.append(system.apply_session(_stats(100, GameSession.State.GAME_OVER)).missions_completed.size())
	check_eq(system.profile.missions[2].progress, 3, "3 partidas acumuladas")
	check_eq(completed, [2, 0, 1] as Array[int], "aciertos y combo en la primera; partidas en la tercera")
	check_eq(system.claimable_count(), 3, "tres por reclamar")


func test_mis_04_claim_refills_with_unique_template() -> void:
	var system := _system()
	system.apply_session(_stats(100, GameSession.State.GAME_OVER))
	var before: int = system.profile.crystals
	check_eq(system.claim(1), 10, "reclamo combo")
	check_eq(system.profile.crystals, before + 10, "saldo")
	check_eq(system.profile.template_tiers["M_COMBO"], 1, "nivel +1")
	var ids: Array[String] = []
	for mission: Profile.MissionState in system.profile.missions:
		ids.append(mission.template_id)
	check_eq(ids.size(), 3, "huecos llenos")
	check(ids[0] != ids[1] and ids[1] != ids[2] and ids[0] != ids[2], "sin plantillas repetidas: %s" % [ids])
	check_eq(system.claim(1), -1, "la misión nueva no está completada")


func test_mis_05_targets_by_tier() -> void:
	check_eq(MissionCatalog.target("M_SCORE_SESSION", 2, config), 10000, "5000+2500·2")
	check_eq(MissionCatalog.target("M_SURVIVE", 10, config), 90, "limitado a session_max_time")
	check_eq(MissionCatalog.reward(10), 30, "recompensa máxima")


func test_mis_06_abandoned_not_counted() -> void:
	var system := _system()
	system.register_abandoned()
	check_eq(system.profile.missions[2].progress, 0, "abandono no cuenta (E13)")


func test_prg_10_reset_keeps_settings() -> void:
	var system := _system()
	system.profile.settings.music_volume = 30
	system.profile.crystals = 500
	system.purchase("core_singularity")
	system.reset(7)
	check_eq(system.profile.crystals, 0, "cristales a 0")
	check_eq(system.profile.owned, ["core_default", "trail_default"] as Array[String], "solo por defecto")
	check_eq(system.profile.settings.music_volume, 30, "ajustes conservados")
