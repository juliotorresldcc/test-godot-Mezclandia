class_name ScreenBase
extends Control
## Base de las pantallas: disposición común y manejo del botón Atrás (FR-UX-001).

var layout: Layout


func _init(screen_layout: Layout) -> void:
	layout = screen_layout
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Acción del botón Atrás del sistema; cada pantalla la define.
func handle_back() -> void:
	pass
