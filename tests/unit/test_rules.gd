extends TestCase
## TEST-DIF-01/02 (FR-DIF-001…003), TEST-SCO-01…03 (FR-SCO-001/002, FR-CMB-002, FR-STAT-002).

var config := GameConfig.new()


func test_dif_01_table_values() -> void:
	var expected: Array[Array] = [
		[0.0, 0.35, 1.10, 0.55], [15.0, 0.4625, 0.9375, 0.5125], [30.0, 0.575, 0.775, 0.475],
		[45.0, 0.6875, 0.6125, 0.4375], [60.0, 0.80, 0.45, 0.40],
	]
	for row: Array in expected:
		var t: float = row[0]
		check_near(Difficulty.orb_speed(config, t), row[1], 1e-9, "v(%s)" % t)
		check_near(Difficulty.spawn_interval(config, t), row[2], 1e-9, "Δ(%s)" % t)
		check_near(Difficulty.target_chance(config, t), row[3], 1e-9, "p_obj(%s)" % t)


func test_dif_02_limits() -> void:
	for t: float in [-1.0, 0.0, 30.0, 60.0, 61.0, 1.0e6]:
		var v: float = Difficulty.orb_speed(config, t)
		var d: float = Difficulty.spawn_interval(config, t)
		check(v >= config.orb_speed_min and v <= config.orb_speed_max, "v fuera de límites en t=%s" % t)
		check(d >= config.spawn_interval_min and d <= config.spawn_interval_max, "Δ fuera de límites en t=%s" % t)
	check_near(Difficulty.orb_speed(config, -1.0), config.orb_speed_min, 1e-9, "t<0 tratado como 0")
	check_near(Difficulty.orb_speed(config, 1.0e6), config.orb_speed_max, 1e-9, "máximo tras la rampa (FR-DIF-003)")


func test_dif_03_active_colors() -> void:
	check_eq(Difficulty.active_colors(config, 19.99).size(), 3, "3 colores antes de 20 s")
	check_eq(Difficulty.active_colors(config, 20.0).size(), 4, "4 colores desde 20 s")


func test_sco_01_points_table() -> void:
	var expected: Dictionary[int, Array] = {1: [100, 200], 4: [100, 200], 5: [150, 300], 9: [150, 300],
		10: [200, 400], 29: [350, 700], 30: [400, 800], 31: [400, 800], 100: [400, 800]}
	for c: int in expected:
		check_eq(ScoreRules.points(config, c, false), expected[c][0], "puntos c=%d normal" % c)
		check_eq(ScoreRules.points(config, c, true), expected[c][1], "puntos c=%d PRISM" % c)


func test_sco_02_round_half_up() -> void:
	var custom := GameConfig.new()
	custom.score_base = 15
	custom.mult_step = 0.5
	# 15 · 1.5 = 22.5 → 23
	check_eq(ScoreRules.points(custom, 5, false), 23, "round_half_up(22.5)")


func test_sco_03_tier_and_accuracy() -> void:
	check_eq(ScoreRules.tier(config, 0), 0, "tier c=0")
	check_eq(ScoreRules.tier(config, 12), 2, "tier c=12")
	check_eq(ScoreRules.tier(config, 500), 6, "tier máximo")
	check_eq(ScoreRules.accuracy(47, 2, 1), 94, "ejemplo FR-STAT-002")
	check_eq(ScoreRules.accuracy(0, 0, 0), 0, "denominador 0")
