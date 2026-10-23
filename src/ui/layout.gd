class_name Layout
extends RefCounted
## Disposición en coordenadas de lienzo (art-direction ART-010…026, CR-001).

const REFERENCE_WIDTH_DP: float = 411.0
const TOP_BAND_DP: float = 136.0
const BOTTOM_BAND_DP: float = 64.0
const NEXT_BLOCK_DP: float = 36.0
const FIT_MARGIN_DP: float = 52.0
const MARGIN_DP: float = 16.0
const TOUCH_TARGET_DP: float = 48.0
const MIN_TEXT_DP: float = 14.0

var size: Vector2
var safe: Rect2
var dp: float
var arena_radius: float
var arena_center: Vector2


func _init(visible_size: Vector2, safe_rect: Rect2 = Rect2()) -> void:
	size = visible_size
	safe = safe_rect if safe_rect.has_area() else Rect2(Vector2.ZERO, visible_size)
	dp = size.x / REFERENCE_WIDTH_DP
	var top_band: float = TOP_BAND_DP * dp
	var bottom_band: float = BOTTOM_BAND_DP * dp
	var safe_height: float = safe.size.y
	arena_radius = minf(minf(0.42 * size.x, 0.30 * safe_height), (safe_height - top_band - bottom_band - FIT_MARGIN_DP * dp) / 2.18)
	var free_height: float = safe_height - top_band - bottom_band - next_block_height()
	arena_center = Vector2(size.x / 2.0, safe.position.y + top_band + free_height / 2.0)


## Disposición a partir del viewport y del área segura del dispositivo.
static func from_viewport(viewport: Viewport) -> Layout:
	var visible: Vector2 = viewport.get_visible_rect().size
	var window_size: Vector2 = Vector2(DisplayServer.window_get_size())
	var safe_area: Rect2 = Rect2(DisplayServer.get_display_safe_area())
	var canvas_safe := Rect2()
	if window_size.x > 0.0 and safe_area.has_area():
		var scale: Vector2 = visible / window_size
		canvas_safe = Rect2(safe_area.position * scale, safe_area.size * scale).intersection(Rect2(Vector2.ZERO, visible))
	return Layout.new(visible, canvas_safe)


func px(value_dp: float) -> float:
	return value_dp * dp


func font_px(value_dp: float) -> int:
	return roundi(maxf(value_dp, MIN_TEXT_DP) * dp)


func next_block_height() -> float:
	return NEXT_BLOCK_DP * dp + 0.08 * arena_radius


## Círculo reservado de la arena (1.05 R).
func arena_bounds_radius() -> float:
	return 1.05 * arena_radius


func top_band_rect() -> Rect2:
	return Rect2(safe.position, Vector2(safe.size.x, TOP_BAND_DP * dp))


func bottom_band_rect() -> Rect2:
	var height: float = BOTTOM_BAND_DP * dp
	return Rect2(Vector2(safe.position.x, safe.end.y - height), Vector2(safe.size.x, height))


func next_block_rect() -> Rect2:
	var top: float = arena_center.y + arena_bounds_radius()
	var width: float = 160.0 * dp
	return Rect2(Vector2(arena_center.x - width / 2.0, top), Vector2(width, next_block_height()))


func pause_rect() -> Rect2:
	var side: float = TOUCH_TARGET_DP * dp
	return Rect2(Vector2(safe.end.x - MARGIN_DP * dp - side, safe.position.y + MARGIN_DP * dp), Vector2(side, side))


## Verdadero si el rectángulo invade el círculo reservado de la arena (FR-FAIR-006).
func intersects_arena(rect: Rect2) -> bool:
	var closest := Vector2(clampf(arena_center.x, rect.position.x, rect.end.x), clampf(arena_center.y, rect.position.y, rect.end.y))
	return closest.distance_to(arena_center) < arena_bounds_radius()
