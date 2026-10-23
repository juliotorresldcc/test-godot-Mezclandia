class_name Background
extends Control
## Fondo: gradiente bg.deep → bg.night y estrellas estáticas (ART-053); rotación de tono en PRISM (ART-031).

const STAR_COUNT: int = 90
const PRISM_HUE_SHIFT: float = 30.0 / 360.0
const PRISM_CYCLE_SECONDS: float = 2.0

var prism_active: bool = false
var reduce_effects: bool = false
var _stars := PackedVector3Array()
var _time: float = 0.0
var _gradient := GradientTexture2D.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i: int in STAR_COUNT:
		_stars.append(Vector3(rng.randf(), rng.randf(), rng.randf_range(0.6, 1.8)))
	_gradient.gradient = Gradient.new()
	_gradient.fill_from = Vector2(0.5, 0.0)
	_gradient.fill_to = Vector2(0.5, 1.0)
	_gradient.width = 4
	_gradient.height = 256
	_update_gradient(0.0)


func _process(delta: float) -> void:
	if prism_active and not reduce_effects:
		_time += delta
		_update_gradient(PRISM_HUE_SHIFT * sin(TAU * _time / PRISM_CYCLE_SECONDS))
		queue_redraw()
	elif _time != 0.0:
		_time = 0.0
		_update_gradient(PRISM_HUE_SHIFT if prism_active else 0.0)
		queue_redraw()


func set_prism(active: bool) -> void:
	prism_active = active
	_update_gradient(PRISM_HUE_SHIFT if active and reduce_effects else 0.0)
	queue_redraw()


func _update_gradient(hue_shift: float) -> void:
	var top: Color = Palette.BG_DEEP
	top.h = fposmod(top.h + hue_shift, 1.0)
	_gradient.gradient.set_color(0, top)
	_gradient.gradient.set_color(1, Palette.BG_NIGHT)


func _draw() -> void:
	draw_texture_rect(_gradient, Rect2(Vector2.ZERO, size), false)
	var dot: float = size.x / 411.0
	for star: Vector3 in _stars:
		draw_circle(Vector2(star.x * size.x, star.y * size.y), star.z * dot * 0.6, Palette.alpha(Palette.TEXT_PRIMARY, 0.12 + 0.13 * (star.z - 0.6) / 1.2))
