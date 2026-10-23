class_name Toast
extends Label
## Aviso breve no bloqueante (FR-UX-060, FR-SAV-005).


static func show_on(parent: Control, message: String, layout: Layout, seconds: float) -> Toast:
	var toast := Toast.new()
	toast.name = "Toast"
	toast.text = message
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_font_size_override("font_size", layout.font_px(16))
	toast.add_theme_color_override("font_color", Palette.TEXT_PRIMARY)
	var box := StyleBoxFlat.new()
	box.bg_color = Palette.BG_SURFACE_ALT
	box.set_corner_radius_all(roundi(layout.px(12)))
	box.set_content_margin_all(layout.px(12))
	toast.add_theme_stylebox_override("normal", box)
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.size = Vector2(layout.px(320), 0)
	toast.position = Vector2((layout.size.x - layout.px(320)) / 2.0, layout.safe.end.y - layout.px(160))
	parent.add_child(toast)
	var tween: Tween = toast.create_tween()
	tween.tween_interval(maxf(seconds - 0.3, 0.0))
	tween.tween_property(toast, "modulate:a", 0.0, 0.3)
	tween.tween_callback(toast.queue_free)
	return toast
