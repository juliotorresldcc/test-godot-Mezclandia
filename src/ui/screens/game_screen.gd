class_name GameScreen
extends ScreenBase
## Pantalla de partida: HUD, entrada y respuesta sensorial (FR-UX-030…032, FR-INP-001/006, FR-AUD-001, FR-HAP-001).

## La partida pasó a PAUSED; GameManager muestra la capa de pausa.
signal paused
## La partida terminó y la secuencia de fin acabó (FR-GS-005).
signal finished(session: GameSession)

var session: GameSession
var arena := ArenaView.new()
var settings: Profile.Settings
var equipped: Dictionary[String, String] = {}
var onboarding: bool = false
var pause_button: IconButton

var _score_label: Label
var _multiplier_label: Label
var _combo_label: Label
var _time_label: Label
var _new_color_label: Label
var _message_label: Label
var _hint_label: Label
var _countdown_label: Label
var _seed_label: Label
var _energy_bar: MeterBar
var _prism_bar: MeterBar
var _new_color_left: float = 0.0
var _end_elapsed: float = -1.0
var _intensity_on: bool = false
var _was_critical: bool = false


func _init(screen_layout: Layout, game_session: GameSession, player_settings: Profile.Settings, equipped_items: Dictionary[String, String], show_onboarding: bool) -> void:
	super(screen_layout)
	name = "GameScreen"
	session = game_session
	settings = player_settings
	equipped = equipped_items
	onboarding = show_onboarding


func _ready() -> void:
	arena.show_symbols = settings.color_symbols
	arena.reduce_effects = settings.reduce_effects
	arena.core_skin = equipped.get(CosmeticsCatalog.CATEGORY_CORE, "core_default")
	arena.trail_skin = equipped.get(CosmeticsCatalog.CATEGORY_TRAIL, "trail_default")
	arena.setup(session, layout)
	add_child(arena)
	_build_hud()
	session.orb_resolved.connect(_on_orb_resolved)
	session.pulse_empty.connect(func() -> void: AudioManager.play("pulse_empty"))
	session.combo_changed.connect(_on_combo_changed)
	session.combo_broken.connect(_on_combo_broken)
	session.energy_changed.connect(_on_energy_changed)
	session.prism_started.connect(_on_prism_started)
	session.prism_warning.connect(func() -> void: AudioManager.play("prism_warning"))
	session.prism_ended.connect(_on_prism_ended)
	session.new_color_activated.connect(_on_new_color)
	session.state_changed.connect(_on_state_changed)
	arena.energy_flash.connect(func() -> void: _energy_bar.flash_left = 0.2)
	AudioManager.play_game_music()
	_refresh_hud()


func _physics_process(_delta: float) -> void:
	if session.state == GameSession.State.PLAYING:
		session.step()


func _process(delta: float) -> void:
	session.update_real_time(delta)
	if _new_color_left > 0.0:
		_new_color_left -= delta
		_new_color_label.visible = _new_color_left > 0.0
	if _end_elapsed >= 0.0:
		_end_elapsed += delta
		if _end_elapsed >= session.config.end_sequence_duration:
			_end_elapsed = -1.0
			finished.emit(session)
	var want_intensity: bool = session.state == GameSession.State.PLAYING and Difficulty.progress(session.config, session.t) >= 0.5
	if want_intensity != _intensity_on and not session.is_terminal():
		_intensity_on = want_intensity
		AudioManager.set_layer("game_intensity", want_intensity)
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	var position_known: bool = true
	var at := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed:
		at = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION:
		at = event.position
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		position_known = false
	else:
		return
	# La región de juego excluye el área táctil del botón Pausa (FR-INP-001).
	if position_known and layout.pause_rect().grow(layout.px(4)).has_point(at):
		return
	tap()


## Un toque de juego (FR-INP-001, T01).
func tap() -> void:
	match session.state:
		GameSession.State.PRE_START:
			session.start()
		GameSession.State.PLAYING:
			session.request_pulse()


## Pausa por botón, Atrás o pérdida de foco (T02/T03/T07).
func request_pause() -> bool:
	if not session.pause():
		return false
	AudioManager.set_paused_duck(true)
	paused.emit()
	return true


func resume() -> void:
	session.resume()
	AudioManager.set_paused_duck(false)


func handle_back() -> void:
	request_pause()


func _build_hud() -> void:
	var top: Rect2 = layout.top_band_rect()
	_time_label = _hud_label(18, false, Palette.TEXT_PRIMARY)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_time_label.position = top.position + Vector2(layout.px(16), layout.px(16))
	_time_label.size = Vector2(layout.px(96), layout.px(28))
	_new_color_label = _hud_label(14, true, Palette.ORB_VIOLET)
	_new_color_label.text = tr("HUD_NEW_COLOR")
	_new_color_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_new_color_label.position = top.position + Vector2(layout.px(16), layout.px(96))
	_new_color_label.size = Vector2(layout.px(120), layout.px(24))
	_new_color_label.visible = false
	_score_label = _hud_label(40, true, Palette.TEXT_PRIMARY)
	_score_label.name = "Score"
	_score_label.position = Vector2(top.position.x + layout.px(80), top.position.y + layout.px(10))
	_score_label.size = Vector2(top.size.x - layout.px(160), layout.px(56))
	_multiplier_label = _hud_label(24, true, Palette.ORB_YELLOW)
	_multiplier_label.position = _score_label.position + Vector2(0, layout.px(58))
	_multiplier_label.size = Vector2(_score_label.size.x, layout.px(32))
	_combo_label = _hud_label(14, false, Palette.TEXT_SECONDARY)
	_combo_label.position = _multiplier_label.position + Vector2(0, layout.px(32))
	_combo_label.size = Vector2(_score_label.size.x, layout.px(22))
	pause_button = IconButton.new(IconButton.Icon.PAUSE, layout)
	pause_button.name = "PauseButton"
	pause_button.position = layout.pause_rect().position
	pause_button.size = layout.pause_rect().size
	pause_button.pressed.connect(request_pause)
	add_child(pause_button)

	var bottom: Rect2 = layout.bottom_band_rect()
	var bar_width: float = (bottom.size.x - layout.px(48)) / 2.0
	var bar_height: float = layout.px(30)
	var bar_y: float = bottom.end.y - layout.px(24) - bar_height
	_energy_bar = MeterBar.new(tr("HUD_ENERGY"), layout)
	_energy_bar.name = "EnergyBar"
	_energy_bar.position = Vector2(bottom.position.x + layout.px(16), bar_y)
	_energy_bar.size = Vector2(bar_width, bar_height)
	add_child(_energy_bar)
	_prism_bar = MeterBar.new(tr("HUD_PRISM"), layout)
	_prism_bar.name = "PrismBar"
	_prism_bar.fill_color = Palette.ORB_VIOLET
	_prism_bar.position = Vector2(bottom.position.x + layout.px(32) + bar_width, bar_y)
	_prism_bar.size = Vector2(bar_width, bar_height)
	add_child(_prism_bar)

	# Textos superpuestos a la arena solo fuera de PLAYING (CR-003).
	var center: Vector2 = layout.arena_center
	_message_label = _hud_label(20, true, Palette.TEXT_PRIMARY)
	_message_label.text = tr("GAME_TAP_TO_START")
	_message_label.position = center + Vector2(-layout.px(180), layout.arena_radius * 0.45)
	_message_label.size = Vector2(layout.px(360), layout.px(32))
	_hint_label = _hud_label(16, false, Palette.TEXT_SECONDARY)
	_hint_label.text = tr("GAME_ONBOARDING_HINT")
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.position = center + Vector2(-layout.px(150), -layout.arena_radius * 0.75)
	_hint_label.size = Vector2(layout.px(300), layout.px(60))
	_hint_label.visible = onboarding
	_countdown_label = _hud_label(64, true, Palette.TEXT_PRIMARY)
	_countdown_label.position = center + Vector2(-layout.px(60), -layout.arena_radius * 0.55 - layout.px(40))
	_countdown_label.size = Vector2(layout.px(120), layout.px(80))
	_seed_label = _hud_label(14, false, Palette.alpha(Palette.TEXT_SECONDARY, 0.4))
	_seed_label.text = tr("DEBUG_SEED") % session.session_seed
	_seed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_seed_label.position = Vector2(bottom.position.x + layout.px(16), bottom.end.y - layout.px(20))
	_seed_label.size = Vector2(layout.px(200), layout.px(18))
	_seed_label.visible = OS.is_debug_build()


func _hud_label(size_dp: float, title: bool, color: Color) -> Label:
	var label: Label = UiKit.label("", layout, size_dp, title, color)
	add_child(label)
	return label


func _refresh_hud() -> void:
	_score_label.text = UiKit.format_int(session.score)
	var combo: int = session.combo.count
	var broken: bool = session.combo.state == ComboTracker.State.BROKEN
	_multiplier_label.visible = combo > 0 or broken
	_combo_label.visible = combo > 0 or broken
	if combo > 0:
		_multiplier_label.text = "×%.1f" % ScoreRules.multiplier(session.config, combo)
		_combo_label.text = tr("HUD_COMBO") % combo
		_combo_label.modulate.a = 1.0
		_combo_label.position.y = _multiplier_label.position.y + layout.px(32)
	_time_label.text = UiKit.format_time(session.config.session_max_time - session.t)
	_energy_bar.fraction = float(session.energy) / session.config.energy_max
	_energy_bar.fill_color = Palette.TEXT_PRIMARY if session.is_energy_critical() else Palette.UI_ACCENT
	if session.prism.active:
		_prism_bar.fraction = session.prism.time_left / session.config.prism_duration
		_prism_bar.blink_hz = 2.0 if session.prism.time_left <= session.config.prism_warning_time else 0.0
	else:
		_prism_bar.fraction = float(session.prism.charge) / session.config.prism_charge_max
		_prism_bar.blink_hz = 0.0
	var pre_start: bool = session.state == GameSession.State.PRE_START
	_message_label.visible = pre_start
	_hint_label.visible = pre_start and onboarding
	_countdown_label.visible = session.state == GameSession.State.RESUMING
	if _countdown_label.visible:
		var step: float = session.config.resume_countdown / 3.0
		_countdown_label.text = str(clampi(ceili(session.resume_time_left / step - 1e-6), 1, 3))


func _on_orb_resolved(_orb: Orb, result: GameSession.Result, _points: int) -> void:
	match result:
		GameSession.Result.HIT:
			AudioManager.play("hit", session.combo.tier())
			Haptics.vibrate(Haptics.Kind.HIT)
		GameSession.Result.HIT_CRYSTAL:
			AudioManager.play("hit_crystal")
			Haptics.vibrate(Haptics.Kind.HIT)
		GameSession.Result.ERROR_COLOR:
			AudioManager.play("error_color")
			Haptics.vibrate(Haptics.Kind.ERROR)
		GameSession.Result.OMISSION:
			AudioManager.play("omission")
			Haptics.vibrate(Haptics.Kind.ERROR)


func _on_combo_changed(_count: int, _tier: int, tier_up: bool) -> void:
	if tier_up:
		AudioManager.play("combo_tier_up")
		_multiplier_label.pivot_offset = _multiplier_label.size / 2.0
		var tween: Tween = create_tween()
		tween.tween_property(_multiplier_label, "scale", Vector2.ONE * 1.3, 0.1)
		tween.tween_property(_multiplier_label, "scale", Vector2.ONE, 0.1)


func _on_combo_broken(previous: int) -> void:
	if previous >= session.config.combo_step:
		AudioManager.play("combo_break")
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(_combo_label, "position:y", _combo_label.position.y + layout.px(8), session.config.combo_broken_feedback)
	tween.tween_property(_combo_label, "modulate:a", 0.0, session.config.combo_broken_feedback)


func _on_energy_changed(_value: int, critical: bool) -> void:
	if critical and not _was_critical:
		AudioManager.play("energy_critical")
	_was_critical = critical


func _on_prism_started() -> void:
	AudioManager.play("prism_start")
	AudioManager.set_layer("game_prism", true)
	Haptics.vibrate(Haptics.Kind.PRISM)
	_set_background_prism(true)


func _on_prism_ended() -> void:
	AudioManager.play("prism_end")
	AudioManager.set_layer("game_prism", false)
	_set_background_prism(false)


func _on_new_color() -> void:
	AudioManager.play("new_color")
	_new_color_left = session.config.new_color_notice_duration
	_new_color_label.visible = true


func _on_state_changed(_from: GameSession.State, to: GameSession.State) -> void:
	match to:
		GameSession.State.PLAYING:
			_hint_label.visible = false
		GameSession.State.GAME_OVER, GameSession.State.COMPLETED:
			AudioManager.play("game_over" if to == GameSession.State.GAME_OVER else "completed")
			AudioManager.set_layer("game_prism", false)
			_set_background_prism(false)
			pause_button.disabled = true
			_end_elapsed = 0.0


func _set_background_prism(active: bool) -> void:
	var background: Background = get_tree().root.find_child("Background", true, false) as Background
	if background != null:
		background.set_prism(active)
