class_name PauseOverlay
extends ScreenBase
## Capa de pausa (FR-UX-040, ART-042).

signal resume_pressed
signal restart_pressed
signal settings_pressed
signal quit_pressed

var _score: int


func _init(screen_layout: Layout, score: int) -> void:
	super(screen_layout)
	name = "PauseOverlay"
	_score = score
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Palette.alpha(Palette.BG_NIGHT, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(layout.px(320), 0)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", roundi(layout.px(12)))
	panel.add_child(column)
	column.add_child(UiKit.label(tr("PAUSE_TITLE"), layout, 32, true))
	column.add_child(UiKit.label(UiKit.format_int(_score), layout, 20, true, Palette.TEXT_SECONDARY))
	var buttons: Array[Array] = [
		["PAUSE_RESUME", "ResumeButton", true, resume_pressed],
		["PAUSE_RESTART", "RestartButton", false, restart_pressed],
		["PAUSE_SETTINGS", "SettingsButton", false, settings_pressed],
		["PAUSE_QUIT", "QuitButton", false, quit_pressed],
	]
	for entry: Array in buttons:
		var button: Button = UiKit.button(tr(entry[0]), layout, entry[2], entry[1])
		var target: Signal = entry[3]
		button.pressed.connect(func() -> void: target.emit())
		column.add_child(button)
	panel.resized.connect(func() -> void: panel.position = (layout.size - panel.size) / 2.0)
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2.ONE * 0.95
	modulate.a = 0.0
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.15)


## Atrás en Pausa equivale a Reanudar (FR-UX-040).
func handle_back() -> void:
	resume_pressed.emit()
