class_name UiKit
extends RefCounted
## Tema y fábricas de controles (ART-023…025, ART-070). Todo texto pasa por tr() (FR-UX-004).

const FONT_TITLE: String = "res://assets/fonts/orbitron-latin-700-normal.woff2"
const FONT_TITLE_REGULAR: String = "res://assets/fonts/orbitron-latin-400-normal.woff2"
const FONT_BODY: String = "res://assets/fonts/exo-2-latin-400-normal.woff2"
const FONT_BODY_BOLD: String = "res://assets/fonts/exo-2-latin-700-normal.woff2"
const NBSP: String = "\u00A0"

static var _fonts: Dictionary[String, Font] = {}


static func font(path: String) -> Font:
	if not _fonts.has(path):
		var base: FontFile = load(path) as FontFile
		if base == null:
			push_error("UiKit: no se pudo cargar la fuente %s" % path)
			_fonts[path] = ThemeDB.fallback_font
		else:
			# Exo 2 como respaldo de glifos que Orbitron no tenga.
			if path != FONT_BODY:
				base.fallbacks = [load(FONT_BODY) as Font]
			_fonts[path] = base
	return _fonts[path]


static func build_theme(layout: Layout) -> Theme:
	var theme := Theme.new()
	theme.default_font = font(FONT_BODY)
	theme.default_font_size = layout.font_px(16)
	theme.set_color("font_color", "Label", Palette.TEXT_PRIMARY)
	for type: String in ["Button", "CheckButton"]:
		theme.set_color("font_color", type, Palette.TEXT_PRIMARY)
		theme.set_color("font_hover_color", type, Palette.TEXT_PRIMARY)
		theme.set_color("font_pressed_color", type, Palette.TEXT_PRIMARY)
		theme.set_color("font_focus_color", type, Palette.TEXT_PRIMARY)
		theme.set_color("font_disabled_color", type, Palette.alpha(Palette.TEXT_SECONDARY, 0.5))
		theme.set_font("font", type, font(FONT_BODY_BOLD))
		theme.set_font_size("font_size", type, layout.font_px(18))
	var secondary: StyleBoxFlat = _box(Palette.BG_SURFACE_ALT, layout, 16)
	for state: String in ["normal", "hover", "focus", "disabled"]:
		theme.set_stylebox(state, "Button", secondary)
	theme.set_stylebox("pressed", "Button", _box(Palette.BG_SURFACE, layout, 16))
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_stylebox("panel", "Panel", _box(Palette.BG_SURFACE, layout, 24))
	theme.set_stylebox("panel", "PanelContainer", _box(Palette.BG_SURFACE, layout, 24, 20))
	for state: String in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		theme.set_stylebox(state, "CheckButton", StyleBoxEmpty.new())
	var track := _box(Palette.BG_SURFACE_ALT, layout, 4)
	track.content_margin_top = layout.px(4)
	track.content_margin_bottom = layout.px(4)
	theme.set_stylebox("slider", "HSlider", track)
	theme.set_stylebox("grabber_area", "HSlider", _box(Palette.UI_ACCENT, layout, 4))
	theme.set_stylebox("grabber_area_highlight", "HSlider", _box(Palette.UI_ACCENT, layout, 4))
	var grabber: ImageTexture = _circle_texture(roundi(layout.px(24)), Palette.TEXT_PRIMARY)
	theme.set_icon("grabber", "HSlider", grabber)
	theme.set_icon("grabber_highlight", "HSlider", grabber)
	theme.set_icon("checked", "CheckButton", _switch_texture(layout, true))
	theme.set_icon("unchecked", "CheckButton", _switch_texture(layout, false))
	theme.set_icon("checked_disabled", "CheckButton", _switch_texture(layout, true, 0.4))
	theme.set_icon("unchecked_disabled", "CheckButton", _switch_texture(layout, false, 0.4))
	theme.set_stylebox("scroll", "VScrollBar", StyleBoxEmpty.new())
	theme.set_stylebox("grabber", "VScrollBar", _box(Palette.alpha(Palette.TEXT_SECONDARY, 0.35), layout, 4))
	return theme


static func button(text_key: String, layout: Layout, primary: bool = false, node_name: String = "") -> Button:
	var result := Button.new()
	result.text = text_key
	result.custom_minimum_size = Vector2(0, layout.px(56))
	if node_name != "":
		result.name = node_name
	if primary:
		result.add_theme_stylebox_override("normal", _box(Palette.UI_ACCENT, layout, 16))
		result.add_theme_stylebox_override("hover", _box(Palette.UI_ACCENT, layout, 16))
		result.add_theme_stylebox_override("pressed", _box(Palette.UI_ACCENT.darkened(0.15), layout, 16))
		for color_name: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			result.add_theme_color_override(color_name, Palette.TEXT_ON_ACCENT)
		result.add_theme_font_override("font", font(FONT_TITLE))
	result.button_down.connect(func() -> void: result.pivot_offset = result.size / 2.0; result.scale = Vector2(0.96, 0.96))
	result.button_up.connect(func() -> void: result.scale = Vector2.ONE)
	result.pressed.connect(func() -> void: AudioManager.play("ui_tap"))
	return result


static func label(text: String, layout: Layout, size_dp: float, title: bool = false, color: Color = Palette.TEXT_PRIMARY) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", layout.font_px(size_dp))
	result.add_theme_color_override("font_color", color)
	if title:
		result.add_theme_font_override("font", font(FONT_TITLE))
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


## Contenedor vertical de pantalla con márgenes laterales (ART-023) y área segura.
static func screen_column(screen: Control, layout: Layout, separation_dp: float = 12.0) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", roundi(layout.safe.position.x + layout.px(24)))
	margin.add_theme_constant_override("margin_right", roundi(layout.size.x - layout.safe.end.x + layout.px(24)))
	margin.add_theme_constant_override("margin_top", roundi(layout.safe.position.y + layout.px(16)))
	margin.add_theme_constant_override("margin_bottom", roundi(layout.size.y - layout.safe.end.y + layout.px(16)))
	screen.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", roundi(layout.px(separation_dp)))
	margin.add_child(column)
	return column


## Cabecera con botón Atrás y título.
static func header(title_key: String, layout: Layout, on_back: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", roundi(layout.px(12)))
	var back := IconButton.new(IconButton.Icon.BACK, layout)
	back.name = "BackButton"
	back.pressed.connect(on_back)
	row.add_child(back)
	var title: Label = label(title_key, layout, 24, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)
	return row


static func format_int(value: int) -> String:
	var digits: String = str(absi(value))
	var groups: PackedStringArray = []
	while digits.length() > 3:
		groups.insert(0, digits.substr(digits.length() - 3))
		digits = digits.substr(0, digits.length() - 3)
	groups.insert(0, digits)
	return ("-" if value < 0 else "") + NBSP.join(groups)


## m:ss. round_up para el tiempo restante del HUD (FR-UX-030); hacia abajo para duraciones.
static func format_time(seconds: float, round_up: bool = false) -> String:
	var total: int = ceili(maxf(seconds, 0.0) - 1e-6) if round_up else floori(maxf(seconds, 0.0) + 1e-6)
	return "%d:%02d" % [total / 60, total % 60]


static func _box(color: Color, layout: Layout, radius_dp: float, padding_dp: float = 12.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(roundi(layout.px(radius_dp)))
	box.set_content_margin_all(layout.px(padding_dp))
	box.anti_aliasing = true
	return box


static func _circle_texture(diameter: int, color: Color) -> ImageTexture:
	var image := Image.create_empty(diameter, diameter, false, Image.FORMAT_RGBA8)
	var radius: float = diameter / 2.0
	for y: int in diameter:
		for x: int in diameter:
			var distance: float = Vector2(x + 0.5, y + 0.5).distance_to(Vector2(radius, radius))
			image.set_pixel(x, y, Color(color, clampf(radius - distance, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)


static func _switch_texture(layout: Layout, on: bool, opacity: float = 1.0) -> ImageTexture:
	var width: int = roundi(layout.px(48))
	var height: int = roundi(layout.px(28))
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	var track: Color = Palette.UI_ACCENT if on else Palette.BG_SURFACE_ALT
	var knob: Color = Palette.TEXT_ON_ACCENT if on else Palette.TEXT_SECONDARY
	var radius: float = height / 2.0
	var knob_center := Vector2(width - radius if on else radius, radius)
	for y: int in height:
		for x: int in width:
			var p := Vector2(x + 0.5, y + 0.5)
			var nearest := Vector2(clampf(p.x, radius, width - radius), radius)
			var color := Color(track, clampf(radius - p.distance_to(nearest), 0.0, 1.0))
			var knob_alpha: float = clampf(radius * 0.7 - p.distance_to(knob_center), 0.0, 1.0)
			color = color.blend(Color(knob, knob_alpha))
			image.set_pixel(x, y, Color(color, color.a * opacity))
	return ImageTexture.create_from_image(image)
