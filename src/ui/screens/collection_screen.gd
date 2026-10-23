class_name CollectionScreen
extends ScreenBase
## Colección (FR-UX-060…062): pestañas Núcleos/Estelas, compra y equipamiento.

signal back_pressed
## Pide a GameManager que guarde tras un cambio (FR-SAV-002).
signal save_requested


class CosmeticPreview extends Control:
	var item_id: String
	var _layout: Layout
	var _time: float = 0.0
	var _highlight: GradientTexture2D = Glyphs.radial_texture(32, 0.85, 0.3)

	func _init(id: String, preview_layout: Layout) -> void:
		item_id = id
		_layout = preview_layout
		custom_minimum_size = Vector2.ONE * preview_layout.px(72)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var center: Vector2 = size / 2.0
		var radius: float = minf(size.x, size.y) * 0.3
		var highlight: GradientTexture2D = _highlight
		if CosmeticsCatalog.category_of(item_id) == CosmeticsCatalog.CATEGORY_CORE:
			Glyphs.sphere(self, center, radius, Palette.ORB_CYAN, highlight, 0.6)
			CosmeticArt.draw_core_skin(self, item_id, center, radius, 1.0, _time, false, _layout.px(2))
			Glyphs.draw(self, OrbType.Kind.CYAN, center, radius * 0.6, Palette.alpha(Palette.UI_GLYPH, 0.85))
		else:
			var orb_radius: float = radius * 0.55
			var at: Vector2 = center + Vector2(-radius * 0.6, radius * 0.4)
			CosmeticArt.draw_trail(self, item_id, at, Vector2(1, -0.6).normalized(), orb_radius, radius * 1.6, Palette.ORB_MAGENTA, 1.0, _time, false)
			Glyphs.sphere(self, at, orb_radius, Palette.ORB_MAGENTA, highlight, 0.5)


var _progression: ProgressionSystem
var _category: String = CosmeticsCatalog.CATEGORY_CORE
var _grid: GridContainer
var _balance: Label
var _tabs: Dictionary[String, Button] = {}


func _init(screen_layout: Layout, progression: ProgressionSystem) -> void:
	super(screen_layout)
	name = "CollectionScreen"
	_progression = progression


func _ready() -> void:
	var column: VBoxContainer = UiKit.screen_column(self, layout, 12)
	column.add_child(UiKit.header(tr("COLLECTION_TITLE"), layout, func() -> void: back_pressed.emit()))
	_balance = UiKit.label("", layout, 18, false, Palette.ORB_CRYSTAL)
	_balance.name = "Balance"
	column.add_child(_balance)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", roundi(layout.px(12)))
	for entry: Array in [[CosmeticsCatalog.CATEGORY_CORE, "COLLECTION_TAB_CORES", "CoresTab"], [CosmeticsCatalog.CATEGORY_TRAIL, "COLLECTION_TAB_TRAILS", "TrailsTab"]]:
		var tab: Button = UiKit.button(tr(entry[1]), layout, false, entry[2])
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.toggle_mode = true
		var category: String = entry[0]
		tab.pressed.connect(func() -> void: select_category(category))
		tabs.add_child(tab)
		_tabs[category] = tab
	column.add_child(tabs)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", roundi(layout.px(12)))
	_grid.add_theme_constant_override("v_separation", roundi(layout.px(12)))
	column.add_child(_grid)
	select_category(_category)


func select_category(category: String) -> void:
	_category = category
	for key: String in _tabs:
		_tabs[key].button_pressed = key == category
		_tabs[key].modulate = Color.WHITE if key == category else Palette.alpha(Color.WHITE, 0.6)
	_rebuild()


func handle_back() -> void:
	back_pressed.emit()


func _rebuild() -> void:
	_balance.text = tr("MENU_CRYSTALS") % UiKit.format_int(_progression.profile.crystals)
	# Se retiran del árbol antes de liberarlos para que los nombres nuevos no colisionen.
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for id: String in CosmeticsCatalog.items_in(_category):
		_grid.add_child(_card(id))


func _card(id: String) -> Button:
	var card := Button.new()
	card.name = "Item_" + id
	card.custom_minimum_size = Vector2(0, layout.px(150))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.pressed.connect(_on_item_pressed.bind(id))
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(box)
	var preview := CosmeticPreview.new(id, layout)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(preview)
	box.add_child(UiKit.label(tr(CosmeticsCatalog.name_key(id)), layout, 16, false))
	var state: ProgressionSystem.ItemState = _progression.item_state(id)
	var status_text: String
	var status_color: Color = Palette.TEXT_SECONDARY
	match state:
		ProgressionSystem.ItemState.EQUIPPED:
			status_text = tr("COLLECTION_EQUIPPED")
			status_color = Palette.UI_ACCENT
		ProgressionSystem.ItemState.OWNED:
			status_text = tr("COLLECTION_EQUIP")
			status_color = Palette.TEXT_PRIMARY
		ProgressionSystem.ItemState.AVAILABLE:
			status_text = tr("COLLECTION_PRICE") % CosmeticsCatalog.price_of(id)
			status_color = Palette.ORB_CRYSTAL
		ProgressionSystem.ItemState.INSUFFICIENT:
			status_text = tr("COLLECTION_PRICE") % CosmeticsCatalog.price_of(id)
			status_color = Palette.alpha(Palette.TEXT_SECONDARY, 0.6)
	var status: Label = UiKit.label(status_text, layout, 14, true, status_color)
	status.name = "Status"
	box.add_child(status)
	return card


func _on_item_pressed(id: String) -> void:
	match _progression.item_state(id):
		ProgressionSystem.ItemState.OWNED:
			_progression.equip(id)
			save_requested.emit()
			_rebuild()
		ProgressionSystem.ItemState.AVAILABLE:
			var message: String = tr("COLLECTION_CONFIRM") % [tr(CosmeticsCatalog.name_key(id)), CosmeticsCatalog.price_of(id)]
			var dialog: ModalDialog = ModalDialog.create(message, [tr("COLLECTION_BUY"), tr("COMMON_CANCEL")] as Array[String], layout)
			dialog.chosen.connect(func(index: int) -> void:
				if index == 0 and _progression.purchase(id):
					AudioManager.play("purchase")
					save_requested.emit()
				_rebuild())
			add_child(dialog)
		ProgressionSystem.ItemState.INSUFFICIENT:
			var missing: int = CosmeticsCatalog.price_of(id) - _progression.profile.crystals
			Toast.show_on(self, tr("COLLECTION_MISSING") % missing, layout, 2.0)
