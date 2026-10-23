extends TestCase
## TEST-UI-01 (matriz de botones, FR-UX-001…081, SC-005), TEST-UI-02 (Atrás y foco, NFR-PLAT-003),
## TEST-INP-04 (el botón Pausa no genera pulso, FR-INP-001), TEST-LAY-03 (HUD real fuera de la arena).

const SAVE_DIR: String = "user://test_ui/"

var gm: GameManager


func _start(corrupt_save: bool = false) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	for file: String in DirAccess.get_files_at(SAVE_DIR):
		DirAccess.remove_absolute(SAVE_DIR + file)
	if corrupt_save:
		var file := FileAccess.open(SAVE_DIR + "profile.json", FileAccess.WRITE)
		file.store_string("{roto")
		file.close()
	GameManager.save_path_override = SAVE_DIR + "profile.json"
	gm = (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	gm.instant_transitions = true
	tree.root.add_child(gm)
	await frames(2)
	check(gm.current_screen is SplashScreen, "arranque → Inicio")
	(gm.current_screen as SplashScreen)._finish()
	await frames(2)
	check(gm.current_screen is MainMenuScreen, "Inicio → Menú principal")


func _finish() -> void:
	gm.queue_free()
	await frames(2)
	GameManager.save_path_override = ""


func _press(name: String) -> void:
	var nodes: Array[Node] = gm.find_children(name, "", true, false)
	var button: BaseButton = null
	for node: Node in nodes:
		if node is BaseButton and node.is_visible_in_tree() and not node.is_queued_for_deletion():
			button = node
	if button == null:
		check(false, "botón %s no encontrado" % name)
		return
	button.pressed.emit()
	await frames(2)


func _game() -> GameScreen:
	return gm.current_screen as GameScreen


func test_ui_01_menu_to_game_and_pause_flow() -> void:
	await _start()
	await _press("PlayButton")
	check(gm.current_screen is GameScreen, "JUGAR → Partida")
	check_eq(_game().session.state, GameSession.State.PRE_START, "PRE_START")
	_game().tap()
	check_eq(_game().session.state, GameSession.State.PLAYING, "toque → PLAYING")
	await _press("PauseButton")
	check_eq(_game().session.state, GameSession.State.PAUSED, "Pausa → PAUSED")
	check(gm.pause_overlay != null, "capa de pausa visible")
	await _press("ResumeButton")
	check_eq(_game().session.state, GameSession.State.RESUMING, "Reanudar → RESUMING")
	check(gm.pause_overlay == null, "capa cerrada")
	await _press("PauseButton")
	await _press("SettingsButton")
	check(gm.settings_overlay != null, "Ajustes desde Pausa")
	check(gm.settings_overlay.find_child("ResetButton", true, false) == null, "sin Restablecer desde Pausa")
	await _press("BackButton")
	check(gm.settings_overlay == null, "Atrás cierra Ajustes")
	check(gm.pause_overlay != null, "vuelve a la pausa")
	await _press("RestartButton")
	check(gm.current_screen is GameScreen and _game().session.state == GameSession.State.PRE_START, "Reiniciar → partida nueva")
	check_eq(gm.progression.profile.stats["sessions_abandoned"], 1, "abandono registrado")
	await _press("PauseButton")
	await _press("QuitButton")
	check(gm.current_screen is MainMenuScreen, "Salir al menú")
	check_eq(gm.progression.profile.stats["sessions_abandoned"], 2, "segundo abandono")
	await _finish()


func test_ui_02_results_flow() -> void:
	await _start()
	await _press("PlayButton")
	var session: GameSession = _game().session
	_game().tap()
	session.energy = 35
	var wrong: OrbType.Kind = OrbType.Kind.CYAN if session.sequence.current() != OrbType.Kind.CYAN else OrbType.Kind.MAGENTA
	session.orbs.clear()
	session.inject_orb(wrong, 0.30)
	session.request_pulse()
	session.step()
	check_eq(session.state, GameSession.State.GAME_OVER, "derrota")
	await tree.create_timer(session.config.end_sequence_duration + 0.3).timeout
	await frames(2)
	check(gm.current_screen is ResultsScreen, "fin → Resultados")
	check_eq(gm.progression.profile.stats["sessions_finished"], 1, "resultado aplicado antes de Resultados (FR-UX-051)")
	check(FileAccess.file_exists(SAVE_DIR + "profile.json"), "guardado escrito")
	await _press("RetryButton")
	check(gm.current_screen is GameScreen, "Reintentar → Partida")
	gm.current_screen.process_mode = Node.PROCESS_MODE_DISABLED
	gm.show_results(session.stats, ProgressionSystem.SessionRewards.new(), 0)
	await frames(2)
	await _press("MenuButton")
	check(gm.current_screen is MainMenuScreen, "Menú → Menú principal")
	await _finish()


func test_ui_03_collection_purchase_equip_insufficient() -> void:
	await _start()
	gm.progression.profile.crystals = 40
	await _press("CollectionButton")
	check(gm.current_screen is CollectionScreen, "Colección")
	await _press("Item_core_pulsar")
	check(gm.find_child("Dialog", true, false) != null, "diálogo de compra")
	await _press("DialogButton0")
	check("core_pulsar" in gm.progression.profile.owned, "comprado")
	check_eq(gm.progression.profile.crystals, 0, "saldo 0")
	check_eq(gm.progression.profile.equipped["core"], "core_pulsar", "equipado")
	await _press("Item_core_default")
	check_eq(gm.progression.profile.equipped["core"], "core_default", "equipar poseído")
	await _press("Item_core_nebula")
	check(gm.find_child("Toast", true, false) != null, "aviso de cristales insuficientes")
	await _press("TrailsTab")
	check(gm.current_screen.find_child("Item_trail_comet", true, false) != null, "pestaña Estelas")
	await _press("Item_trail_comet")
	await _press("BackButton")
	check(gm.current_screen is MainMenuScreen, "Atrás → Menú")
	var saved: SaveSystem.LoadResult = SaveSystem.new(gm.config, SAVE_DIR + "profile.json").load_profile(1)
	check("core_pulsar" in saved.profile.owned, "compra guardada")
	await _finish()


func test_ui_04_missions_claim() -> void:
	await _start()
	gm.progression.profile.missions[2].progress = 3
	await _press("MissionsButton")
	check(gm.current_screen is MissionsScreen, "Misiones")
	check(gm.current_screen.find_child("Stats", true, false) != null, "estadísticas visibles (FR-STAT-011)")
	await _press("ClaimButton")
	check_eq(gm.progression.profile.crystals, 10, "reclamo +10")
	await _press("BackButton")
	check(gm.current_screen is MainMenuScreen, "Atrás → Menú")
	await _finish()


func test_ui_05_settings_controls() -> void:
	await _start()
	await _press("SettingsButton")
	check(gm.current_screen is SettingsScreen, "Ajustes")
	var slider: HSlider = gm.current_screen.find_child("MusicSlider", true, false)
	slider.value = 30
	await frames(1)
	check_eq(gm.progression.profile.settings.music_volume, 30, "música al 30 %")
	var toggle: CheckButton = gm.current_screen.find_child("ReduceEffectsToggle", true, false)
	toggle.button_pressed = true
	await frames(1)
	check(gm.progression.profile.settings.reduce_effects, "reducir efectos")
	var vibration: CheckButton = gm.current_screen.find_child("VibrationToggle", true, false)
	check(vibration.disabled, "vibración deshabilitada sin soporte (FR-HAP-003)")
	var saved: SaveSystem.LoadResult = SaveSystem.new(gm.config, SAVE_DIR + "profile.json").load_profile(1)
	check_eq(saved.profile.settings.music_volume, 30, "ajuste guardado")
	await _press("CreditsButton")
	check(gm.current_screen.find_child("CreditsPanel", true, false) != null, "créditos")
	await _press("CloseCreditsButton")
	gm.progression.profile.crystals = 77
	await _press("ResetButton")
	await _press("DialogButton0")
	check_eq(gm.progression.profile.crystals, 0, "progreso restablecido")
	check_eq(gm.progression.profile.settings.music_volume, 30, "ajustes conservados")
	await _press("BackButton")
	check(gm.current_screen is MainMenuScreen, "Atrás → Menú")
	await _finish()


func test_ui_06_back_button_and_focus() -> void:
	await _start()
	gm.handle_back()
	await frames(1)
	check(gm.find_child("Dialog", true, false) != null, "Atrás en el menú → «¿Salir?»")
	gm.handle_back()
	await frames(2)
	check(gm.find_child("Dialog", true, false) == null, "Atrás en el diálogo → Cancelar")
	await _press("PlayButton")
	_game().tap()
	gm.handle_back()
	await frames(1)
	check_eq(_game().session.state, GameSession.State.PAUSED, "Atrás en partida → Pausa")
	gm.handle_back()
	await frames(1)
	check_eq(_game().session.state, GameSession.State.RESUMING, "Atrás en Pausa → Reanudar")
	gm._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await frames(1)
	check_eq(_game().session.state, GameSession.State.PAUSED, "pérdida de foco → Pausa (T07)")
	gm._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _finish()


func test_inp_04_pause_button_area_does_not_pulse() -> void:
	await _start()
	await _press("PlayButton")
	var screen: GameScreen = _game()
	screen.tap()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = gm.layout.pause_rect().get_center()
	screen._unhandled_input(touch)
	screen.session.step()
	check_eq(screen.session.stats.empty_pulses, 0, "toque en Pausa sin pulso")
	touch.position = gm.layout.arena_center
	screen._unhandled_input(touch)
	screen.session.step()
	check_eq(screen.session.stats.empty_pulses + screen.session.stats.hits + screen.session.stats.color_errors, 1, "toque en la arena → pulso")
	var emulated := InputEventMouseButton.new()
	emulated.pressed = true
	emulated.button_index = MOUSE_BUTTON_LEFT
	emulated.device = InputEvent.DEVICE_ID_EMULATION
	emulated.position = gm.layout.arena_center
	for i: int in 20:
		screen.session.step()
	var before: int = screen.session.stats.empty_pulses
	screen._unhandled_input(emulated)
	screen.session.step()
	check_eq(screen.session.stats.empty_pulses, before, "el ratón emulado desde táctil no duplica pulsos")
	await _finish()


func test_lay_03_real_hud_outside_arena() -> void:
	await _start()
	await _press("PlayButton")
	_game().tap()
	await frames(2)
	for node: Node in _game().get_children():
		if node is Control and node.visible:
			var rect: Rect2 = (node as Control).get_global_rect()
			check(not gm.layout.intersects_arena(rect), "%s invade la arena durante PLAYING" % node.name)
	await _finish()


func test_ui_07_load_error_dialog() -> void:
	await _start(true)
	check(gm.load_recovered, "guardado corrupto detectado")
	check(gm.find_child("Dialog", true, false) != null, "diálogo FR-UX-012")
	await _press("DialogButton0")
	check(gm.find_child("Dialog", true, false) == null, "Aceptar cierra")
	await _finish()


func test_ui_08_quit_during_prism_restores_background() -> void:
	await _start()
	await _press("PlayButton")
	var session: GameSession = _game().session
	_game().tap()
	session.prism.charge = session.config.prism_charge_max
	session.step()
	check(gm.background.prism_active, "fondo PRISM activo")
	await _press("PauseButton")
	await _press("QuitButton")
	await frames(2)
	check(not gm.background.prism_active, "fondo restablecido al salir durante PRISM")
	await _finish()


func test_inp_05_space_key_is_a_tap() -> void:
	await _start()
	await _press("PlayButton")
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_SPACE
	_game()._unhandled_input(key)
	check_eq(_game().session.state, GameSession.State.PLAYING, "Espacio inicia la partida (FR-INP-006)")
	await _finish()


func test_ui_09_transition_blocks_input() -> void:
	await _start()
	gm.instant_transitions = false
	gm.show_collection()
	check(gm._blocker.visible, "bloqueo de toques durante la transición (FR-UX-002)")
	await tree.create_timer(GameManager.TRANSITION_SECONDS + 0.15).timeout
	check(not gm._blocker.visible, "bloqueo retirado al terminar")
	await _finish()


func test_rg_02_break_reminder() -> void:
	await _start()
	var interval: float = gm.config.break_reminder_interval * 60.0
	gm.play_seconds_since_launch = interval - 1.0
	check_eq(gm._break_reminder_minutes(), 0, "antes de 30 min no hay aviso")
	gm.play_seconds_since_launch = interval + 5.0
	check_eq(gm._break_reminder_minutes(), 30, "al superar 30 min: aviso con los minutos")
	check_eq(gm._break_reminder_minutes(), 0, "una sola vez por intervalo")
	gm.progression.profile.settings.break_reminder = false
	gm.play_seconds_since_launch = 2.0 * interval + 5.0
	check_eq(gm._break_reminder_minutes(), 0, "desactivado en Ajustes")
	await _finish()
