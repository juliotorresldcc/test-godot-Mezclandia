extends TestCase
## TEST-LAY-01 (FR-FAIR-006, ART-010/020/022, NFR-A11Y-004/005), TEST-STR-01 (FR-UX-004),
## TEST-RSC-01 (SC-007), TEST-AUD-01/02 (FR-AUD-*), TEST-HAP-01 (FR-HAP-003),
## TEST-VIS-01/02 (ART-051/052), TEST-SYNC-01 (ART-001).

const RESOLUTIONS: Array[Array] = [
	# [lienzo visible, inserción superior en dp, etiqueta]
	[Vector2(1080, 1920), 0.0, "9:16"],
	[Vector2(1080, 2400), 0.0, "9:20"],
	[Vector2(1440, 1920), 0.0, "3:4"],
	[Vector2(1080, 1920), 0.0, "720×1280 (mismo lienzo 9:16)"],
	[Vector2(1080, 2400), 40.0, "9:20 con muesca"],
]


func test_lay_01_hud_never_overlaps_arena() -> void:
	for entry: Array in RESOLUTIONS:
		var size: Vector2 = entry[0]
		var inset: float = entry[1] * size.x / Layout.REFERENCE_WIDTH_DP
		var layout := Layout.new(size, Rect2(Vector2(0, inset), size - Vector2(0, inset)))
		var label: String = entry[2]
		check(not layout.intersects_arena(layout.top_band_rect()), "%s: banda superior invade la arena" % label)
		check(not layout.intersects_arena(layout.bottom_band_rect()), "%s: banda inferior invade la arena" % label)
		check(not layout.intersects_arena(layout.pause_rect()), "%s: botón Pausa invade la arena" % label)
		check(not layout.next_block_rect().intersects(layout.bottom_band_rect()), "%s: SIGUIENTE invade la banda inferior" % label)
		check(layout.arena_center.x - layout.arena_bounds_radius() >= 0.0 and layout.arena_center.x + layout.arena_bounds_radius() <= size.x, "%s: arena fuera del ancho" % label)
		check(layout.pause_rect().size.x >= Layout.TOUCH_TARGET_DP * layout.dp - 0.01, "%s: área táctil de Pausa < 48 dp" % label)
		check(layout.font_px(10) >= roundi(Layout.MIN_TEXT_DP * layout.dp), "%s: texto < 14 dp" % label)


func test_lay_02_reference_radius() -> void:
	check_near(Layout.new(Vector2(1080, 1920)).arena_radius, 453.6, 0.01, "9:16 (CR-001)")
	check_near(Layout.new(Vector2(1440, 1920)).arena_radius, 475.74, 0.05, "3:4 (CR-001)")


func test_str_01_all_keys_exist() -> void:
	var missing: PackedStringArray = []
	var key_pattern := RegEx.create_from_string("\"((?:APP|COMMON|LOAD|SAVE|EXIT|MENU|GAME|HUD|DEBUG|PAUSE|RESULTS|COLLECTION|MISSIONS|MISSION|STATS|STAT|SETTINGS|CREDITS|ORB|COSMETIC)_[A-Z0-9_]+)\"")
	for path: String in _files("res://src", ".gd"):
		if path.ends_with("strings.gd"):
			continue
		for match: RegExMatch in key_pattern.search_all(FileAccess.get_file_as_string(path)):
			var key: String = match.get_string(1)
			if not Strings.ES.has(key):
				missing.append("%s (%s)" % [key, path.get_file()])
	for template_id: String in MissionCatalog.TEMPLATE_IDS:
		if not Strings.ES.has(MissionCatalog.description_key(template_id)):
			missing.append(MissionCatalog.description_key(template_id))
	for key: String in MissionsScreen.STAT_ROWS:
		if not Strings.ES.has("STAT_" + key.to_upper()):
			missing.append("STAT_" + key.to_upper())
	for id: String in CosmeticsCatalog.ITEMS:
		if not Strings.ES.has(CosmeticsCatalog.name_key(id)):
			missing.append(CosmeticsCatalog.name_key(id))
	check(missing.is_empty(), "claves sin texto: %s" % ", ".join(missing))


func test_rsc_01_no_broken_references() -> void:
	var broken: PackedStringArray = []
	var path_pattern := RegEx.create_from_string("\"(res://[^\"]+)\"")
	for path: String in _files("res://src", ".gd") + _files("res://scenes", ".tscn") + PackedStringArray(["res://project.godot"]):
		for match: RegExMatch in path_pattern.search_all(FileAccess.get_file_as_string(path)):
			var reference: String = match.get_string(1)
			if not reference.ends_with("/") and not ResourceLoader.exists(reference) and not FileAccess.file_exists(reference):
				broken.append("%s → %s" % [path.get_file(), reference])
	for id: String in AudioManager.SOUNDS:
		if not ResourceLoader.exists(AudioManager.SOUND_DIR + id + ".wav"):
			broken.append("audio %s" % id)
	for path: String in _files("res://src", ".gd"):
		var script: GDScript = load(path) as GDScript
		if script == null or not script.can_instantiate():
			broken.append("script %s" % path)
	check(broken.is_empty(), "referencias rotas: %s" % ", ".join(broken))


func test_aud_01_all_sounds_load_and_play() -> void:
	for id: String in AudioManager.SOUNDS:
		AudioManager.stop_all_sfx()
		check(AudioManager.is_loaded(id), "%s cargado" % id)
		check(AudioManager.play(id), "%s se reproduce (controlador Dummy)" % id)
	check(not AudioManager.play("no_existe"), "identificador desconocido rechazado")
	AudioManager.stop_all_sfx()


func test_aud_03_voice_limit_priority() -> void:
	AudioManager.stop_all_sfx()
	for i: int in GameConfig.shared().sfx_max_voices:
		check(AudioManager.play("prism_start"), "voz %d" % i)
	check(not AudioManager.play("ui_tap"), "sin voces libres: un sonido de menor prioridad se descarta (FR-AUD-005)")
	check(AudioManager.play("game_over"), "uno de mayor prioridad sustituye al de menor prioridad")
	AudioManager.stop_all_sfx()


func test_aud_02_volume_mapping() -> void:
	check_near(AudioManager.percent_to_db(100), 0.0, 1e-6, "100 % = 0 dB")
	check_near(AudioManager.percent_to_db(50), 20.0 * log(0.5) / log(10.0), 1e-4, "50 % = 20·log10(0.5)")
	AudioManager.set_music_volume(0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Music")), "0 % silencia el bus")
	AudioManager.set_music_volume(70)
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Music")), "70 % no silencia")


func test_hap_01_unavailable_on_desktop() -> void:
	check(not Haptics.is_available(), "Linux: no disponible")
	var before: int = Haptics.calls
	Haptics.vibrate(Haptics.Kind.ERROR)
	check_eq(Haptics.calls, before, "ninguna llamada de vibración")


func test_vis_01_flash_limiter() -> void:
	var limiter := FlashLimiter.new()
	var allowed: Array[bool] = []
	for time: float in [0.0, 0.1, 0.2, 0.3, 0.99, 1.0, 1.05]:
		allowed.append(limiter.try_flash(time))
	check_eq(allowed, [true, true, true, false, false, true, false] as Array[bool], "≤ 3 destellos en cualquier ventana de 1 s")


func test_vis_02_particle_budget() -> void:
	var buffer := ParticleBuffer.new()
	var rng := RandomNumberGenerator.new()
	var emitted: int = 0
	for i: int in 40:
		emitted += buffer.emit(12, Vector2.ZERO, Color.WHITE, 10.0, 1.0, 2.0, rng)
	check_eq(buffer.count, ParticleBuffer.CAPACITY, "presupuesto de 300")
	check_eq(emitted, 300, "emisión recortada")
	buffer.update(2.0)
	check_eq(buffer.count, 0, "las partículas caducan")


func _files(directory: String, extension: String) -> PackedStringArray:
	var result := PackedStringArray()
	for file: String in DirAccess.get_files_at(directory):
		if file.ends_with(extension):
			result.append(directory.path_join(file))
	for sub: String in DirAccess.get_directories_at(directory):
		result.append_array(_files(directory.path_join(sub), extension))
	return result


func test_fmt_01_time_and_numbers() -> void:
	check_eq(UiKit.format_time(74.4), "1:14", "duración hacia abajo")
	check_eq(UiKit.format_time(74.4, true), "1:15", "tiempo restante hacia arriba")
	check_eq(UiKit.format_time(90.0, true), "1:30", "inicio de partida")
	check_eq(UiKit.format_int(12450), "12 450", "separador de miles")
	check_eq(UiKit.format_int(999), "999", "sin separador")
