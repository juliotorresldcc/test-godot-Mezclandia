extends TestCase
## TEST-SAV-01…06 — FR-SAV-001…006, NFR-SEC-001, SC-006.

const DIR: String = "user://test_save/"

var config := GameConfig.new()


func _fresh_path(name: String) -> String:
	DirAccess.make_dir_recursive_absolute(DIR)
	for file: String in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR + file)
	return DIR + name


func _rich_profile() -> Profile:
	var system := ProgressionSystem.new(Profile.create_new(99, config), config)
	system.profile.crystals = 300
	system.purchase("core_nebula")
	system.profile.missions[0].progress = 7
	system.profile.stats["best_score"] = 4321
	system.profile.mission_rng_state = 9007199254740993
	system.profile.settings.music_volume = 40
	system.profile.settings.reduce_effects = true
	return system.profile


func test_sav_01_round_trip_all_fields() -> void:
	var path: String = _fresh_path("profile.json")
	var saves := SaveSystem.new(config, path)
	var profile: Profile = _rich_profile()
	check(saves.save(profile), "guardado")
	var loaded: SaveSystem.LoadResult = saves.load_profile(1)
	check(not loaded.recovered_from_error, "sin error")
	check_eq(loaded.profile.to_dict(), profile.to_dict(), "todos los campos iguales")
	check_eq(loaded.profile.mission_rng_state, 9007199254740993, "entero de 64 bits exacto (AN-02)")


func test_sav_02_missing_file_creates_new_profile() -> void:
	var saves := SaveSystem.new(config, _fresh_path("none.json"))
	var loaded: SaveSystem.LoadResult = saves.load_profile(5)
	check(not loaded.recovered_from_error, "no es un error")
	check_eq(loaded.profile.crystals, 0, "perfil nuevo")


func _expect_recovery(content: String, label: String) -> void:
	var path: String = _fresh_path("profile.json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
	var loaded: SaveSystem.LoadResult = SaveSystem.new(config, path).load_profile(5)
	check(loaded.recovered_from_error, "%s: recuperación" % label)
	check_eq(loaded.profile.crystals, 0, "%s: perfil nuevo" % label)
	check(FileAccess.file_exists(loaded.backup_path), "%s: copia de seguridad en %s" % [label, loaded.backup_path])
	check_eq(FileAccess.get_file_as_string(loaded.backup_path), content, "%s: copia idéntica" % label)


func test_sav_03_corrupt_file() -> void:
	_expect_recovery("{esto no es json", "corrupto")


func test_sav_04_future_version() -> void:
	var data: Dictionary = _rich_profile().to_dict()
	data["schema_version"] = Profile.SCHEMA_VERSION + 1
	_expect_recovery(JSON.stringify(data), "versión futura (E15)")


func test_sav_05_out_of_range_values() -> void:
	var cases: Array[Callable] = [
		func(d: Dictionary) -> void: d["crystals"] = -5,
		func(d: Dictionary) -> void: d["crystals"] = 2.5,
		func(d: Dictionary) -> void: d["owned"] = ["core_default", "trail_default", "hack"],
		func(d: Dictionary) -> void: d["equipped"]["core"] = "core_singularity",
		func(d: Dictionary) -> void: d["settings"]["music_volume"] = 55,
		func(d: Dictionary) -> void: d["missions"] = [],
		func(d: Dictionary) -> void: d["stats"].erase("best_score"),
	]
	for i: int in cases.size():
		var data: Dictionary = _rich_profile().to_dict()
		cases[i].call(data)
		_expect_recovery(JSON.stringify(data), "caso %d" % i)


func test_sav_06_interrupted_write_keeps_previous() -> void:
	var path: String = _fresh_path("profile.json")
	var saves := SaveSystem.new(config, path)
	var original: Profile = _rich_profile()
	saves.save(original)
	var changed: Profile = _rich_profile()
	changed.crystals = 1
	saves.fail_before_replace_for_test = true
	check(not saves.save(changed), "la escritura informa del fallo")
	saves.fail_before_replace_for_test = false
	var loaded: SaveSystem.LoadResult = saves.load_profile(1)
	check(not loaded.recovered_from_error, "el guardado anterior sigue legible")
	check_eq(loaded.profile.crystals, original.crystals, "el guardado anterior está intacto")


func test_sav_07_no_personal_data() -> void:
	var keys: Array = _rich_profile().to_dict().keys()
	keys.sort()
	check_eq(keys, ["crystals", "equipped", "mission_rng_seed", "mission_rng_state", "missions", "owned", "schema_version", "settings", "stats", "template_tiers"], "solo campos de juego (FR-SAV-006)")
