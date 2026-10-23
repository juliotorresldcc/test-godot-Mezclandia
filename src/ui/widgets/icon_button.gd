class_name IconButton
extends Button
## Botón de icono lineal (ART-070) con área táctil ≥ 48 dp (NFR-A11Y-004).

enum Icon { PAUSE, BACK, CLOSE }

var icon_kind: Icon
var _layout: Layout


func _init(kind: Icon, layout: Layout) -> void:
	icon_kind = kind
	_layout = layout
	custom_minimum_size = Vector2.ONE * layout.px(Layout.TOUCH_TARGET_DP)
	flat = true
	focus_mode = Control.FOCUS_NONE
	for state: String in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	pressed.connect(func() -> void: AudioManager.play("ui_back" if kind == Icon.BACK else "ui_tap"))


func _draw() -> void:
	var center: Vector2 = size / 2.0
	var s: float = _layout.px(12)
	var width: float = _layout.px(2)
	var color: Color = Palette.TEXT_PRIMARY if not button_pressed else Palette.TEXT_SECONDARY
	match icon_kind:
		Icon.PAUSE:
			draw_rect(Rect2(center + Vector2(-s * 0.6, -s), Vector2(s * 0.4, s * 2)), color)
			draw_rect(Rect2(center + Vector2(s * 0.2, -s), Vector2(s * 0.4, s * 2)), color)
		Icon.BACK:
			draw_polyline(PackedVector2Array([center + Vector2(s * 0.4, -s), center + Vector2(-s * 0.5, 0), center + Vector2(s * 0.4, s)]), color, width, true)
		Icon.CLOSE:
			draw_line(center + Vector2(-s, -s) * 0.8, center + Vector2(s, s) * 0.8, color, width, true)
			draw_line(center + Vector2(s, -s) * 0.8, center + Vector2(-s, s) * 0.8, color, width, true)
