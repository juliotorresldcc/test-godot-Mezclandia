class_name ResultsScreen
extends ScreenBase
## Resultados (FR-UX-050/051, FR-RG-002).

signal retry_pressed
signal menu_pressed

var _stats: SessionStats
var _rewards: ProgressionSystem.SessionRewards
var _break_minutes: int
var _score_label: Label
var _count_tween: Tween


func _init(screen_layout: Layout, stats: SessionStats, rewards: ProgressionSystem.SessionRewards, break_minutes: int) -> void:
	super(screen_layout)
	name = "ResultsScreen"
	_stats = stats
	_rewards = rewards
	_break_minutes = break_minutes
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var column: VBoxContainer = UiKit.screen_column(self, layout, 10)
	var completed: bool = _stats.end_state == GameSession.State.COMPLETED
	column.add_child(UiKit.label(tr("RESULTS_COMPLETED" if completed else "RESULTS_GAME_OVER"), layout, 26, true))
	_score_label = UiKit.label("0", layout, 48, true)
	_score_label.name = "Score"
	column.add_child(_score_label)
	if _rewards.new_record:
		var record: Label = UiKit.label(tr("RESULTS_NEW_RECORD"), layout, 20, true, Palette.ORB_YELLOW)
		record.name = "NewRecord"
		column.add_child(record)
		AudioManager.play("record")
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", roundi(layout.px(16)))
	grid.add_theme_constant_override("v_separation", roundi(layout.px(4)))
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var rows: Array[Array] = [
		["RESULTS_DURATION", UiKit.format_time(_stats.duration)],
		["RESULTS_HITS", UiKit.format_int(_stats.hits)],
		["RESULTS_ACCURACY", "%d %%" % _stats.accuracy()],
		["RESULTS_BEST_COMBO", str(_stats.best_combo)],
		["RESULTS_PRISM", str(_stats.prism_activations)],
	]
	for row: Array in rows:
		var key: Label = UiKit.label(tr(row[0]), layout, 16, false, Palette.TEXT_SECONDARY)
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		grid.add_child(key)
		var value: Label = UiKit.label(row[1], layout, 16, true)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(value)
	column.add_child(grid)
	var crystals: Label = UiKit.label(tr("RESULTS_CRYSTALS") % _rewards.total(), layout, 20, true, Palette.ORB_CRYSTAL)
	crystals.name = "Crystals"
	column.add_child(crystals)
	var breakdown: Label = UiKit.label(tr("RESULTS_CRYSTALS_BREAKDOWN") % [_rewards.crystals_from_score, _rewards.crystals_from_orbs, _rewards.crystals_from_completion], layout, 14, false, Palette.TEXT_SECONDARY)
	breakdown.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(breakdown)
	if not _rewards.missions_completed.is_empty():
		column.add_child(UiKit.label(tr("RESULTS_MISSIONS"), layout, 16, true))
		for mission: Profile.MissionState in _rewards.missions_completed:
			var line: Label = UiKit.label(tr(MissionCatalog.description_key(mission.template_id)) % mission.target + " · " + tr("RESULTS_READY_TO_CLAIM"), layout, 14, false, Palette.TEXT_SECONDARY)
			line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			column.add_child(line)
	if _break_minutes > 0:
		var reminder: Label = UiKit.label(tr("RESULTS_BREAK_REMINDER") % _break_minutes, layout, 16, false, Palette.ORB_CYAN)
		reminder.name = "BreakReminder"
		reminder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(reminder)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var retry: Button = UiKit.button(tr("RESULTS_RETRY"), layout, true, "RetryButton")
	retry.pressed.connect(func() -> void: retry_pressed.emit())
	column.add_child(retry)
	var menu: Button = UiKit.button(tr("RESULTS_MENU"), layout, false, "MenuButton")
	menu.pressed.connect(func() -> void: menu_pressed.emit())
	column.add_child(menu)
	_count_tween = create_tween()
	_count_tween.tween_method(func(value: float) -> void: _score_label.text = UiKit.format_int(roundi(value)), 0.0, float(_stats.score), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## Un toque completa el recuento al instante (FR-UX-050).
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		complete_count()


func complete_count() -> void:
	if _count_tween != null and _count_tween.is_valid():
		_count_tween.kill()
	_score_label.text = UiKit.format_int(_stats.score)


func handle_back() -> void:
	menu_pressed.emit()
