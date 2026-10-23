class_name SplashScreen
extends ScreenBase
## Inicio (FR-UX-010…012): logotipo animado y paso al menú.

signal finished

var _min_time: float
var _elapsed: float = 0.0
var _done: bool = false


func _init(screen_layout: Layout, min_time: float) -> void:
	super(screen_layout)
	name = "SplashScreen"
	_min_time = min_time
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var title: Label = UiKit.label(tr("APP_TITLE"), layout, 48, true)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title.size = Vector2(layout.size.x, layout.px(80))
	title.position = Vector2(0, layout.size.y / 2.0 - layout.px(40))
	title.visible_ratio = 0.0
	add_child(title)
	var tween: Tween = create_tween()
	tween.tween_property(title, "visible_ratio", 1.0, minf(1.0, _min_time))
	var tagline: Label = UiKit.label(tr("APP_TAGLINE"), layout, 16, false, Palette.TEXT_SECONDARY)
	tagline.size = Vector2(layout.size.x, layout.px(32))
	tagline.position = title.position + Vector2(0, layout.px(84))
	add_child(tagline)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _min_time:
		_finish()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_finish()


func _finish() -> void:
	if not _done:
		_done = true
		finished.emit()
