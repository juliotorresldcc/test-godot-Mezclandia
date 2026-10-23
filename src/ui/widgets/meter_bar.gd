class_name MeterBar
extends Control
## Barra de energía o PRISM con etiqueta (ART-022, ART-034).

var label_text: String = ""
var fraction: float = 1.0
var fill_color: Color = Palette.UI_ACCENT
## Parpadeo de la barra en Hz (0 = sin parpadeo); se usa en el aviso de PRISM (ART-032).
var blink_hz: float = 0.0
## Destello blanco único (ART-036/037), en segundos restantes.
var flash_left: float = 0.0
var _layout: Layout
var _time: float = 0.0


func _init(text: String, layout: Layout) -> void:
	label_text = text
	_layout = layout
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	flash_left = maxf(0.0, flash_left - delta)
	queue_redraw()


func _draw() -> void:
	var font: Font = UiKit.font(UiKit.FONT_BODY_BOLD)
	var font_size: int = _layout.font_px(14)
	draw_string(font, Vector2(0, font_size), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Palette.TEXT_SECONDARY)
	var bar_height: float = _layout.px(8)
	var bar := Rect2(Vector2(0, size.y - bar_height), Vector2(size.x, bar_height))
	draw_rect(bar, Palette.alpha(Palette.TEXT_PRIMARY, 0.15))
	var color: Color = fill_color
	if blink_hz > 0.0:
		color.a = 0.45 + 0.55 * (0.5 + 0.5 * cos(TAU * blink_hz * _time))
	if flash_left > 0.0:
		color = Palette.TEXT_PRIMARY
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(fraction, 0.0, 1.0), bar_height)), color)
