class_name GameManager
extends Control
## Navegación entre pantallas (FR-UX-001/002), Atrás y foco (NFR-PLAT-003), aplicación de
## resultados antes de Resultados (FR-UX-051), guardado (FR-SAV-002/005) y descanso (FR-RG-002).

const TRANSITION_SECONDS: float = 0.25
const TRANSITION_SLIDE: float = 0.04

## Ruta del guardado; las pruebas la sustituyen antes de añadir el nodo al árbol.
static var save_path_override: String = ""

## Transiciones instantáneas (pruebas de interfaz).
var instant_transitions: bool = false
var config: GameConfig = GameConfig.shared()
var layout: Layout
var save_system: SaveSystem
var progression: ProgressionSystem
var background := Background.new()
var screen_host := Control.new()
var overlay_host := Control.new()
var current_screen: ScreenBase
var game_screen: GameScreen
var pause_overlay: PauseOverlay
var settings_overlay: SettingsScreen
var load_recovered: bool = false
var play_seconds_since_launch: float = 0.0

var _reminders_shown: int = 0
var _blocker := Control.new()
var _seed_rng := RandomNumberGenerator.new()


func _ready() -> void:
	_seed_rng.randomize()
	Strings.install()
	Engine.physics_ticks_per_second = roundi(1.0 / config.sim_step)
	layout = Layout.from_viewport(get_viewport())
	theme = UiKit.build_theme(layout)
	save_system = SaveSystem.new(config, save_path_override if save_path_override != "" else SaveSystem.DEFAULT_PATH)
	var loaded: SaveSystem.LoadResult = save_system.load_profile(new_seed())
	load_recovered = loaded.recovered_from_error
	progression = ProgressionSystem.new(loaded.profile, config)
	background.name = "Background"
	add_child(background)
	for host: Control in [screen_host, overlay_host, _blocker]:
		host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		host.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(host)
	screen_host.name = "Screens"
	overlay_host.name = "Overlays"
	_blocker.name = "TransitionBlocker"
	_blocker.visible = false
	_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	apply_settings()
	show_splash()


func new_seed() -> int:
	return (_seed_rng.randi() << 31) ^ _seed_rng.randi()


# --- Navegación ---

func show_splash() -> void:
	var splash := SplashScreen.new(layout, config.splash_min_time)
	splash.finished.connect(_on_splash_finished)
	_swap_screen(splash)


func show_menu() -> void:
	game_screen = null
	AudioManager.play_menu_music()
	var menu := MainMenuScreen.new(layout, progression)
	menu.play_pressed.connect(start_game)
	menu.collection_pressed.connect(show_collection)
	menu.missions_pressed.connect(show_missions)
	menu.settings_pressed.connect(show_settings.bind(false))
	menu.exit_requested.connect(_confirm_exit)
	_swap_screen(menu)


func start_game() -> void:
	_close_overlays()
	progression.register_session_started()
	var session := GameSession.new(config, new_seed())
	game_screen = GameScreen.new(layout, session, progression.profile.settings, progression.profile.equipped, progression.should_show_onboarding())
	game_screen.paused.connect(_show_pause)
	game_screen.finished.connect(_on_session_finished)
	_swap_screen(game_screen)


func show_collection() -> void:
	var screen := CollectionScreen.new(layout, progression)
	screen.back_pressed.connect(show_menu)
	screen.save_requested.connect(save)
	_swap_screen(screen)


func show_missions() -> void:
	var screen := MissionsScreen.new(layout, progression)
	screen.back_pressed.connect(show_menu)
	screen.save_requested.connect(save)
	_swap_screen(screen)


## Ajustes desde el menú (pantalla) o desde la pausa (capa, sin Restablecer: FR-UX-040).
func show_settings(from_pause: bool) -> void:
	var screen := SettingsScreen.new(layout, progression.profile.settings, not from_pause, Haptics.is_available())
	screen.settings_changed.connect(func() -> void:
		apply_settings()
		save())
	screen.reset_confirmed.connect(_on_reset_confirmed)
	if from_pause:
		settings_overlay = screen
		screen.back_pressed.connect(func() -> void:
			settings_overlay.queue_free()
			settings_overlay = null)
		overlay_host.add_child(screen)
	else:
		screen.back_pressed.connect(show_menu)
		_swap_screen(screen)


func show_results(stats: SessionStats, rewards: ProgressionSystem.SessionRewards, break_minutes: int) -> void:
	game_screen = null
	var screen := ResultsScreen.new(layout, stats, rewards, break_minutes)
	screen.retry_pressed.connect(start_game)
	screen.menu_pressed.connect(show_menu)
	_swap_screen(screen)


# --- Partida ---

func _show_pause() -> void:
	pause_overlay = PauseOverlay.new(layout, game_screen.session.score)
	pause_overlay.resume_pressed.connect(_on_resume)
	pause_overlay.restart_pressed.connect(_on_restart)
	pause_overlay.settings_pressed.connect(show_settings.bind(true))
	pause_overlay.quit_pressed.connect(_on_quit_to_menu)
	overlay_host.add_child(pause_overlay)


func _on_resume() -> void:
	_close_overlays()
	game_screen.arena.show_symbols = progression.profile.settings.color_symbols
	game_screen.arena.reduce_effects = progression.profile.settings.reduce_effects
	game_screen.resume()


func _abandon_current() -> void:
	var session: GameSession = game_screen.session
	if session.abandon():
		play_seconds_since_launch += session.stats.duration
		progression.register_abandoned()
		save()
	AudioManager.set_paused_duck(false)


func _on_restart() -> void:
	_abandon_current()
	start_game()


func _on_quit_to_menu() -> void:
	_abandon_current()
	_close_overlays()
	show_menu()


## Aplica y guarda el resultado antes de mostrar Resultados (FR-UX-051).
func _on_session_finished(session: GameSession) -> void:
	var rewards: ProgressionSystem.SessionRewards = progression.apply_session(session.stats)
	play_seconds_since_launch += session.stats.duration
	save()
	show_results(session.stats, rewards, _break_reminder_minutes())


func _break_reminder_minutes() -> int:
	var interval: float = config.break_reminder_interval * 60.0
	var crossed: int = floori(play_seconds_since_launch / interval)
	if crossed <= _reminders_shown:
		return 0
	_reminders_shown = crossed
	if not progression.profile.settings.break_reminder:
		return 0
	return floori(play_seconds_since_launch / 60.0)


# --- Ajustes, guardado y diálogos ---

func apply_settings() -> void:
	var settings: Profile.Settings = progression.profile.settings
	AudioManager.set_music_volume(settings.music_volume)
	AudioManager.set_sfx_volume(settings.sfx_volume)
	Haptics.enabled = settings.vibration
	background.reduce_effects = settings.reduce_effects


func save() -> bool:
	var ok: bool = save_system.save(progression.profile)
	if not ok:
		Toast.show_on(overlay_host, tr("SAVE_FAILED"), layout, 3.0)
	return ok


func _on_reset_confirmed() -> void:
	progression.reset(new_seed())
	save()
	Toast.show_on(overlay_host, tr("SETTINGS_RESET_DONE"), layout, 2.0)


func _on_splash_finished() -> void:
	show_menu()
	if load_recovered:
		var dialog: ModalDialog = ModalDialog.create(tr("LOAD_ERROR"), [tr("COMMON_OK")] as Array[String], layout)
		overlay_host.add_child(dialog)


func _confirm_exit() -> void:
	if OS.has_feature("ios"):
		return
	var dialog: ModalDialog = ModalDialog.create(tr("EXIT_CONFIRM"), [tr("EXIT_QUIT"), tr("COMMON_CANCEL")] as Array[String], layout, 1)
	dialog.chosen.connect(func(index: int) -> void:
		if index == 0:
			get_tree().quit())
	overlay_host.add_child(dialog)


func _close_overlays() -> void:
	for child: Node in overlay_host.get_children():
		if child is PauseOverlay or child is SettingsScreen:
			child.queue_free()
	pause_overlay = null
	settings_overlay = null


# --- Atrás y foco ---

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			handle_back()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			AudioManager.set_focus_mute(true)
			if game_screen != null and game_screen.session.state in [GameSession.State.PLAYING, GameSession.State.RESUMING]:
				game_screen.request_pause()
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			AudioManager.set_focus_mute(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		handle_back()
		get_viewport().set_input_as_handled()


## Botón Atrás: diálogo abierto → Cancelar; capas → su acción; si no, la pantalla actual.
func handle_back() -> void:
	if _blocker.visible:
		return
	# find_children no filtra por class_name de script: se comprueba el tipo explícitamente.
	var dialogs: Array[Node] = find_children("Dialog", "", true, false).filter(func(node: Node) -> bool: return node is ModalDialog)
	if not dialogs.is_empty():
		var dialog: ModalDialog = dialogs.back()
		dialog.cancel()
		return
	if settings_overlay != null:
		settings_overlay.handle_back()
	elif pause_overlay != null and is_instance_valid(pause_overlay):
		pause_overlay.handle_back()
	elif current_screen != null:
		current_screen.handle_back()


# --- Transiciones (ART-040, FR-UX-002) ---

func _swap_screen(screen: ScreenBase) -> void:
	var previous: ScreenBase = current_screen
	current_screen = screen
	screen_host.add_child(screen)
	if previous != null:
		previous.process_mode = Node.PROCESS_MODE_DISABLED
	if instant_transitions or previous == null:
		if previous != null:
			previous.queue_free()
		return
	_blocker.visible = true
	screen.modulate.a = 0.0
	screen.position.x = layout.size.x * TRANSITION_SLIDE
	var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(screen, "modulate:a", 1.0, TRANSITION_SECONDS)
	tween.tween_property(screen, "position:x", 0.0, TRANSITION_SECONDS)
	tween.tween_property(previous, "modulate:a", 0.0, TRANSITION_SECONDS)
	tween.tween_property(previous, "position:x", -layout.size.x * TRANSITION_SLIDE, TRANSITION_SECONDS)
	tween.chain().tween_callback(func() -> void:
		previous.queue_free()
		_blocker.visible = false)
