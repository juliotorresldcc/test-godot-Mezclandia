class_name MissionsScreen
extends ScreenBase
## Misiones y estadísticas (FR-UX-070/071, FR-STAT-011).

signal back_pressed
signal save_requested

const STAT_ROWS: Array[String] = [
	"best_score", "sessions_finished", "sessions_completed", "total_hits", "best_combo",
	"total_prism_activations", "total_crystal_orbs", "total_play_seconds", "crystals_earned",
]

var _progression: ProgressionSystem
var _list: VBoxContainer


func _init(screen_layout: Layout, progression: ProgressionSystem) -> void:
	super(screen_layout)
	name = "MissionsScreen"
	_progression = progression


func _ready() -> void:
	var column: VBoxContainer = UiKit.screen_column(self, layout, 12)
	column.add_child(UiKit.header(tr("MISSIONS_TITLE"), layout, func() -> void: back_pressed.emit()))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", roundi(layout.px(12)))
	scroll.add_child(_list)
	_rebuild()


func handle_back() -> void:
	back_pressed.emit()


func _rebuild() -> void:
	# Se retiran del árbol antes de liberarlos para que los nombres nuevos no colisionen.
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	for slot: int in _progression.profile.missions.size():
		_list.add_child(_mission_card(slot))
	_list.add_child(UiKit.label(tr("STATS_TITLE"), layout, 20, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.name = "Stats"
	grid.add_theme_constant_override("h_separation", roundi(layout.px(16)))
	for key: String in STAT_ROWS:
		var name_label: Label = UiKit.label(tr("STAT_" + key.to_upper()), layout, 14, false, Palette.TEXT_SECONDARY)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(name_label)
		var value: int = _progression.profile.stats[key]
		var text: String = UiKit.format_time(value) if key == "total_play_seconds" else UiKit.format_int(value)
		var value_label: Label = UiKit.label(text, layout, 14, true)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(value_label)
	_list.add_child(grid)


func _mission_card(slot: int) -> PanelContainer:
	var mission: Profile.MissionState = _progression.profile.missions[slot]
	var card := PanelContainer.new()
	card.name = "Mission%d" % slot
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", roundi(layout.px(8)))
	card.add_child(box)
	var description: Label = UiKit.label(tr(MissionCatalog.description_key(mission.template_id)) % mission.target, layout, 16, false)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(description)
	var progress := ProgressBar.new()
	progress.show_percentage = false
	progress.max_value = mission.target
	progress.value = mini(mission.progress, mission.target)
	progress.custom_minimum_size = Vector2(0, layout.px(8))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Palette.UI_ACCENT
	var track := StyleBoxFlat.new()
	track.bg_color = Palette.alpha(Palette.TEXT_PRIMARY, 0.15)
	progress.add_theme_stylebox_override("fill", fill)
	progress.add_theme_stylebox_override("background", track)
	box.add_child(progress)
	var row := HBoxContainer.new()
	var counter: Label = UiKit.label("%s/%s" % [UiKit.format_int(mini(mission.progress, mission.target)), UiKit.format_int(mission.target)], layout, 14, false, Palette.TEXT_SECONDARY)
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(counter)
	if mission.is_completed():
		var claim: Button = UiKit.button(tr("MISSIONS_CLAIM") % mission.reward, layout, true, "ClaimButton")
		claim.pressed.connect(_on_claim.bind(slot))
		row.add_child(claim)
	else:
		row.add_child(UiKit.label(tr("MISSIONS_REWARD") % mission.reward, layout, 14, true, Palette.ORB_CRYSTAL))
	box.add_child(row)
	return card


func _on_claim(slot: int) -> void:
	if _progression.claim(slot) >= 0:
		AudioManager.play("claim")
		save_requested.emit()
	_rebuild()
