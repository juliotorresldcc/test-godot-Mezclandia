class_name ModalDialog
extends Control
## Diálogo modal con mensaje y botones; bloquea la interacción de fondo.

signal chosen(index: int)


static func create(message: String, button_keys: Array[String], layout: Layout, primary_index: int = 0) -> ModalDialog:
	var dialog := ModalDialog.new()
	dialog.name = "Dialog"
	dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Palette.alpha(Palette.BG_NIGHT, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.add_child(dim)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(layout.px(320), 0)
	dialog.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", roundi(layout.px(16)))
	panel.add_child(column)
	var text: Label = UiKit.label(message, layout, 18)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(layout.px(280), 0)
	column.add_child(text)
	for i: int in button_keys.size():
		var choice: Button = UiKit.button(button_keys[i], layout, i == primary_index, "DialogButton%d" % i)
		choice.pressed.connect(dialog._choose.bind(i))
		column.add_child(choice)
	panel.resized.connect(func() -> void: panel.position = (layout.size - panel.size) / 2.0)
	return dialog


## Atrás en un diálogo equivale a su última opción (Cancelar o Aceptar).
func cancel() -> void:
	_choose(find_children("DialogButton*", "Button", true, false).size() - 1)


func _choose(index: int) -> void:
	chosen.emit(index)
	queue_free()
