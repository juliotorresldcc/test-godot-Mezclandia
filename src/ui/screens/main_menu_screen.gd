class_name MainMenuScreen
extends ScreenBase
## Menú principal (FR-UX-020/021).

signal play_pressed
signal collection_pressed
signal missions_pressed
signal settings_pressed
signal exit_requested

var _progression: ProgressionSystem


func _init(screen_layout: Layout, progression: ProgressionSystem) -> void:
	super(screen_layout)
	name = "MainMenuScreen"
	_progression = progression


func _ready() -> void:
	var column: VBoxContainer = UiKit.screen_column(self, layout, 12)
	var balance: Label = UiKit.label(tr("MENU_CRYSTALS") % UiKit.format_int(_progression.profile.crystals), layout, 18, false, Palette.ORB_CRYSTAL)
	balance.name = "Balance"
	balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(balance)
	var spacer_top := Control.new()
	spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer_top)
	column.add_child(UiKit.label(tr("APP_TITLE"), layout, 44, true))
	var best: int = _progression.profile.stats["best_score"]
	var record_text: String = tr("MENU_RECORD") % (UiKit.format_int(best) if best > 0 else "—")
	var record: Label = UiKit.label(record_text, layout, 20, false, Palette.TEXT_SECONDARY)
	record.name = "Record"
	column.add_child(record)
	var spacer_mid := Control.new()
	spacer_mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer_mid)
	var play: Button = UiKit.button(tr("MENU_PLAY"), layout, true, "PlayButton")
	play.custom_minimum_size.y = layout.px(72)
	play.add_theme_font_size_override("font_size", layout.font_px(26))
	play.pressed.connect(func() -> void: play_pressed.emit())
	column.add_child(play)
	var collection: Button = UiKit.button(tr("MENU_COLLECTION"), layout, false, "CollectionButton")
	collection.pressed.connect(func() -> void: collection_pressed.emit())
	column.add_child(collection)
	var claimable: int = _progression.claimable_count()
	var missions_text: String = tr("MENU_MISSIONS") if claimable == 0 else tr("MENU_MISSIONS_BADGE") % claimable
	var missions: Button = UiKit.button(missions_text, layout, false, "MissionsButton")
	missions.pressed.connect(func() -> void: missions_pressed.emit())
	column.add_child(missions)
	var settings: Button = UiKit.button(tr("MENU_SETTINGS"), layout, false, "SettingsButton")
	settings.pressed.connect(func() -> void: settings_pressed.emit())
	column.add_child(settings)


func handle_back() -> void:
	exit_requested.emit()
