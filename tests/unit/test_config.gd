extends TestCase
## TEST-CFG-01/02 — FR-FAIR-005, NFR-MNT-001, parameters.md §3.


func test_cfg_01_default_config_is_valid() -> void:
	var errors: PackedStringArray = GameConfig.new().validate()
	check(errors.is_empty(), "La configuración por defecto debe ser válida: %s" % "; ".join(errors))


func test_cfg_01_constraint_values_match_parameters_doc() -> void:
	var config := GameConfig.new()
	check_near(config.radial_gap_at(0.0), 0.385, 1e-9, "C4 u=0")
	check_near(config.radial_gap_at(1.0), 0.360, 1e-9, "C4 u=1")
	check_near(config.min_radial_gap_over_ramp(), 0.360, 1e-9, "C4 mínimo")


func test_cfg_02_each_constraint_detects_violation() -> void:
	var cases: Dictionary[String, Callable] = {
		"Rango": func(c: GameConfig) -> void: c.orb_speed_max = 2.0,
		"C1": func(c: GameConfig) -> void: c.zone_outer_radius = 0.16,
		"C2": func(c: GameConfig) -> void: c.orb_radius = 0.07,
		"C3": func(c: GameConfig) -> void: c.target_chance_end = 0.6,
		"C4": func(c: GameConfig) -> void: c.spawn_interval_min = 0.40,
		"C5": func(c: GameConfig) -> void: c.zone_outer_radius = 0.50; c.min_radial_gap = 0.30,
		"C7": func(c: GameConfig) -> void: c.prism_warning_time = 3.0; c.prism_duration = 3.0,
		"C8": func(c: GameConfig) -> void: c.energy_start = 0,
		"C10": func(c: GameConfig) -> void: c.max_orbs_in_flight = 3,
		"C11": func(c: GameConfig) -> void: c.pulse_cooldown = 0.26,
		"C12": func(c: GameConfig) -> void: c.fourth_color_time = 60.0; c.session_max_time = 60.0,
	}
	for label: String in cases:
		var config := GameConfig.new()
		cases[label].call(config)
		var errors: PackedStringArray = config.validate()
		var found: bool = false
		for error: String in errors:
			if error.begins_with(label):
				found = true
		check(found, "%s no detectado; errores: %s" % [label, "; ".join(errors)])
