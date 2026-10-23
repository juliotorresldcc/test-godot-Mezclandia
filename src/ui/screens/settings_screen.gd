class_name SettingsScreen
extends ScreenBase
## Ajustes (FR-UX-080/081). Los cambios se aplican al instante y se guardan.

signal back_pressed
## Un ajuste cambió: GameManager lo aplica (audio, vibración) y guarda.
signal settings_changed
signal reset_confirmed

var _settings: Profile.Settings
var _allow_reset: bool
var _vibration_available: bool
var _credits: Control


func _init(screen_layout: Layout, settings: Profile.Settings, allow_reset: bool, vibration_available: bool) -> void:
	super(screen_layout)
	name = "SettingsScreen"
	_settings = settings
	_allow_reset = allow_reset
	_vibration_available = vibration_available
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Palette.BG_NIGHT
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var column: VBoxContainer = UiKit.screen_column(self, layout, 14)
	column.add_child(UiKit.header(tr("SETTINGS_TITLE"), layout, func() -> void: back_pressed.emit()))
	_add_slider(column, "SETTINGS_MUSIC", "MusicSlider", _settings.music_volume, func(value: int) -> void: _settings.music_volume = value)
	_add_slider(column, "SETTINGS_SFX", "SfxSlider", _settings.sfx_volume, func(value: int) -> void: _settings.sfx_volume = value)
	var vibration: CheckButton = _add_toggle(column, "SETTINGS_VIBRATION", "VibrationToggle", _settings.vibration and _vibration_available, func(on: bool) -> void: _settings.vibration = on)
	if not _vibration_available:
		vibration.disabled = true
		vibration.text = tr("SETTINGS_VIBRATION") + "\n" + tr("SETTINGS_NOT_AVAILABLE")
	_add_toggle(column, "SETTINGS_SYMBOLS", "SymbolsToggle", _settings.color_symbols, func(on: bool) -> void: _settings.color_symbols = on)
	_add_toggle(column, "SETTINGS_REDUCE_EFFECTS", "ReduceEffectsToggle", _settings.reduce_effects, func(on: bool) -> void: _settings.reduce_effects = on)
	_add_toggle(column, "SETTINGS_BREAK_REMINDER", "BreakReminderToggle", _settings.break_reminder, func(on: bool) -> void: _settings.break_reminder = on)
	if _allow_reset:
		var reset: Button = UiKit.button(tr("SETTINGS_RESET"), layout, false, "ResetButton")
		reset.pressed.connect(_on_reset_pressed)
		column.add_child(reset)
	var credits: Button = UiKit.button(tr("SETTINGS_CREDITS"), layout, false, "CreditsButton")
	credits.pressed.connect(_show_credits)
	column.add_child(credits)
	column.add_child(UiKit.label(tr("SETTINGS_VERSION") % ProjectSettings.get_setting("application/config/version"), layout, 14, false, Palette.TEXT_SECONDARY))


func handle_back() -> void:
	if _credits != null and is_instance_valid(_credits):
		_credits.queue_free()
		_credits = null
		return
	back_pressed.emit()


func _add_slider(column: VBoxContainer, key: String, node_name: String, value: int, apply: Callable) -> void:
	var title: Label = UiKit.label(tr(key) % value, layout, 16, false)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	column.add_child(title)
	var slider := HSlider.new()
	slider.name = node_name
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 10
	slider.value = value
	slider.custom_minimum_size = Vector2(0, layout.px(48))
	slider.value_changed.connect(func(new_value: float) -> void:
		apply.call(int(new_value))
		title.text = tr(key) % int(new_value)
		settings_changed.emit())
	column.add_child(slider)


func _add_toggle(column: VBoxContainer, key: String, node_name: String, on: bool, apply: Callable) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.name = node_name
	toggle.text = tr(key)
	toggle.button_pressed = on
	toggle.custom_minimum_size = Vector2(0, layout.px(48))
	toggle.add_theme_font_size_override("font_size", layout.font_px(16))
	toggle.toggled.connect(func(pressed: bool) -> void:
		apply.call(pressed)
		AudioManager.play("ui_tap")
		settings_changed.emit())
	column.add_child(toggle)
	return toggle


func _on_reset_pressed() -> void:
	var dialog: ModalDialog = ModalDialog.create(tr("SETTINGS_RESET_CONFIRM"), [tr("SETTINGS_RESET_DELETE"), tr("COMMON_CANCEL")] as Array[String], layout, 1)
	dialog.chosen.connect(func(index: int) -> void:
		if index == 0:
			reset_confirmed.emit())
	add_child(dialog)


func _show_credits() -> void:
	_credits = PanelContainer.new()
	_credits.name = "CreditsPanel"
	_credits.position = Vector2(layout.px(16), layout.safe.position.y + layout.px(16))
	_credits.size = Vector2(layout.size.x - layout.px(32), layout.safe.size.y - layout.px(32))
	add_child(_credits)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", roundi(layout.px(12)))
	_credits.add_child(box)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var text: Label = UiKit.label(Strings.credits(), layout, 14, false)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(text)
	var close: Button = UiKit.button(tr("COMMON_CLOSE"), layout, true, "CloseCreditsButton")
	close.pressed.connect(func() -> void:
		_credits.queue_free()
		_credits = null)
	box.add_child(close)
