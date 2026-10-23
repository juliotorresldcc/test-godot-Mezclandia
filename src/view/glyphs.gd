class_name Glyphs
extends RefCounted
## Símbolos de color (ART-002) y dibujo de esferas compartido por la arena y la interfaz.


## Dibuja el símbolo del tipo en «canvas». size = semilado del símbolo.
static func draw(canvas: CanvasItem, kind: int, center: Vector2, size: float, color: Color) -> void:
	match kind:
		OrbType.Kind.CYAN:
			canvas.draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -size), center + Vector2(size * 0.866, size * 0.5), center + Vector2(-size * 0.866, size * 0.5)]), color)
		OrbType.Kind.MAGENTA:
			var half: float = size * 0.72
			canvas.draw_rect(Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0), color)
		OrbType.Kind.YELLOW:
			var bar: float = size * 0.42
			canvas.draw_rect(Rect2(center - Vector2(bar / 2.0, size), Vector2(bar, size * 2.0)), color)
			canvas.draw_rect(Rect2(center - Vector2(size, bar / 2.0), Vector2(size * 2.0, bar)), color)
		OrbType.Kind.VIOLET:
			var points := PackedVector2Array()
			for i: int in 10:
				var radius: float = size if i % 2 == 0 else size * 0.42
				points.append(center + Vector2.from_angle(-PI / 2.0 + i * PI / 5.0) * radius)
			canvas.draw_colored_polygon(points, color)
		OrbType.Kind.CRYSTAL:
			var diamond := PackedVector2Array([center + Vector2(0, -size), center + Vector2(size, 0), center + Vector2(0, size), center + Vector2(-size, 0), center + Vector2(0, -size)])
			canvas.draw_polyline(diamond, color, maxf(1.5, size * 0.18), true)


## Esfera con gradiente: base de color + brillo blanco (ART-011/015).
static func sphere(canvas: CanvasItem, center: Vector2, radius: float, color: Color, highlight: Texture2D, highlight_alpha: float) -> void:
	canvas.draw_circle(center, radius, color, true, -1.0, true)
	canvas.draw_texture_rect(highlight, Rect2(center - Vector2(radius, radius) * 0.9 + Vector2(-radius, -radius) * 0.15, Vector2(radius, radius) * 1.8), false, Color(1, 1, 1, highlight_alpha))


## Textura de gradiente radial blanco → transparente.
static func radial_texture(size: int, inner_alpha: float, falloff: float) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, inner_alpha))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(falloff, Color(1, 1, 1, inner_alpha * 0.35))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = size
	texture.height = size
	return texture
