class_name CosmeticArt
extends RefCounted
## Dibujo de cosméticos (ART-060), compartido por la arena y las vistas previas de Colección.
## Solo cambian el patrón interior del núcleo y la estela; nunca colores ni símbolos de juego.


static func draw_core_skin(canvas: CanvasItem, skin: String, center: Vector2, radius: float, alpha: float, time: float, reduce_effects: bool, line_width: float) -> void:
	match skin:
		"core_pulsar":
			var phase: float = 0.5 if reduce_effects else fposmod(time, 1.0)
			canvas.draw_arc(center, radius * (0.25 + 0.65 * phase), 0, TAU, 48, Palette.alpha(Color.WHITE, 0.35 * (1.0 - phase) * alpha), line_width, true)
		"core_nebula":
			for i: int in 6:
				var angle: float = i * TAU / 6.0 + (0.0 if reduce_effects else time * 0.8)
				canvas.draw_circle(center + Vector2.from_angle(angle) * radius * 0.55, radius * 0.08, Palette.alpha(Color.WHITE, 0.35 * alpha))
		"core_singularity":
			var turn: float = 0.0 if reduce_effects else time * 1.5
			canvas.draw_arc(center, radius * 0.5, turn, turn + PI * 1.2, 32, Palette.alpha(Palette.BG_NIGHT, 0.45 * alpha), radius * 0.18, true)


## outward: dirección desde el centro de la arena hacia el orbe (la estela queda detrás del movimiento).
static func draw_trail(canvas: CanvasItem, skin: String, at: Vector2, outward: Vector2, orb_radius: float, length: float, color: Color, alpha: float, time: float, reduce_effects: bool) -> void:
	match skin:
		"trail_default":
			var side: Vector2 = outward.orthogonal() * orb_radius * 0.6
			canvas.draw_polygon(PackedVector2Array([at + side, at - side, at + outward * (orb_radius + length * 0.6)]),
				PackedColorArray([Palette.alpha(color, 0.3 * alpha), Palette.alpha(color, 0.3 * alpha), Palette.alpha(color, 0.0)]))
		"trail_spark":
			for i: int in 4:
				var offset: float = orb_radius + length * (i + 1) / 4.0
				canvas.draw_circle(at + outward * offset, orb_radius * (0.3 - i * 0.05), Palette.alpha(color, (0.4 - i * 0.08) * alpha))
		"trail_comet":
			var tail := PackedVector2Array([at + outward.orthogonal() * orb_radius * 0.9, at - outward.orthogonal() * orb_radius * 0.9, at + outward * (orb_radius + length)])
			canvas.draw_colored_polygon(tail, Palette.alpha(color, 0.3 * alpha))
		"trail_aurora":
			var points := PackedVector2Array()
			for i: int in 9:
				var along: float = orb_radius + length * i / 8.0
				var wave: float = 0.0 if reduce_effects else sin(time * 6.0 + i * 0.9) * orb_radius * 0.5
				points.append(at + outward * along + outward.orthogonal() * wave)
			canvas.draw_polyline(points, Palette.alpha(color, 0.4 * alpha), orb_radius * 0.35, true)
