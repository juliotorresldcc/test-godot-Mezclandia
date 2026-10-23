class_name ArenaView
extends Node2D
## Dibujo de la arena (ART-011…016, ART-030…044, ART-050…053, ART-060).
## Solo lee la partida y reacciona a sus señales; no contiene reglas (ADR 0003).

const CORE_FACET_SPEED: float = 0.25
const PRISM_CORE_CYCLE: float = 1.0

## Pide a la pantalla el destello único de la barra de energía (ART-036/037).
signal energy_flash

var session: GameSession
var layout: Layout
var show_symbols: bool = true
var reduce_effects: bool = false
var core_skin: String = "core_default"
var trail_skin: String = "trail_default"

var _glow := Node2D.new()
var _soft: GradientTexture2D = Glyphs.radial_texture(128, 1.0, 0.45)
var _highlight: GradientTexture2D = Glyphs.radial_texture(64, 0.85, 0.3)
var _particles := ParticleBuffer.new()
var _flashes := FlashLimiter.new()
var _rng := RandomNumberGenerator.new()
var _popups: Array[Dictionary] = []
var _time: float = 0.0
var _core_flash: float = 0.0
var _shake: float = 0.0
var _glitch: float = 0.0
var _ripple: float = 0.0
var _prism_wave: float = -1.0
var _end_time: float = -1.0
var _center: Vector2
var _ring_mesh: ArrayMesh


func setup(game_session: GameSession, game_layout: Layout) -> void:
	session = game_session
	layout = game_layout
	_center = layout.arena_center
	position = _center
	_rng.seed = session.session_seed
	session.orb_resolved.connect(_on_orb_resolved)
	session.pulse_empty.connect(_on_pulse_empty)
	session.prism_started.connect(_on_prism_started)
	session.state_changed.connect(_on_state_changed)


func _ready() -> void:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = additive
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_glow.show_behind_parent = true


func _process(delta: float) -> void:
	if session == null:
		return
	var running: bool = session.state == GameSession.State.PLAYING or session.is_terminal()
	_time += delta
	if running:
		_particles.update(delta)
		for popup: Dictionary in _popups:
			popup["age"] += delta
		_popups = _popups.filter(func(popup: Dictionary) -> bool: return popup["age"] < 0.5)
		_core_flash = maxf(0.0, _core_flash - delta)
		_shake = maxf(0.0, _shake - delta)
		_glitch = maxf(0.0, _glitch - delta)
		_ripple = maxf(0.0, _ripple - delta)
		if _prism_wave >= 0.0:
			_prism_wave += delta
			if _prism_wave > 0.4:
				_prism_wave = -1.0
		if _end_time >= 0.0:
			_end_time += delta
	var offset := Vector2.ZERO
	if _shake > 0.0 and not reduce_effects:
		var amplitude: float = layout.px(6) * _shake / 0.2
		offset = Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)) * amplitude
	position = _center + offset
	queue_redraw()
	_glow.queue_redraw()


func particle_count() -> int:
	return _particles.count


# --- Respuestas a la partida ---

func _on_orb_resolved(orb: Orb, result: GameSession.Result, points: int) -> void:
	var at: Vector2 = orb.direction() * orb.radius * layout.arena_radius
	var color: Color = Palette.orb(orb.kind)
	var amount: int = 12
	match result:
		GameSession.Result.HIT, GameSession.Result.HIT_CRYSTAL:
			_emit(amount, at, color, 0.6, 0.35)
			if _flashes.try_flash(_time):
				_core_flash = 0.10
			_popups.append({"position": at, "text": "+%d" % points, "age": 0.0})
		GameSession.Result.ERROR_COLOR:
			_emit(6, at, Palette.TEXT_PRIMARY, 0.45, 0.30)
			_shake = 0.2
			_flash_energy()
		GameSession.Result.OMISSION:
			_glitch = 0.25
			_ripple = 0.15
			_flash_energy()


func _on_pulse_empty() -> void:
	_ripple = 0.15


func _on_prism_started() -> void:
	if _flashes.try_flash(_time):
		_prism_wave = 0.0


func _on_state_changed(_from: GameSession.State, to: GameSession.State) -> void:
	if to == GameSession.State.GAME_OVER or to == GameSession.State.COMPLETED:
		_end_time = 0.0
		if to == GameSession.State.COMPLETED and _flashes.try_flash(_time):
			_prism_wave = 0.0


func _flash_energy() -> void:
	if _flashes.try_flash(_time):
		energy_flash.emit()


func _emit(amount: int, at: Vector2, color: Color, speed_r: float, life: float) -> void:
	var count: int = floori(amount * 0.5) if reduce_effects else amount
	_particles.emit(count, at, color, speed_r * layout.arena_radius, life, layout.px(3), _rng)


# --- Dibujo ---

func _target_color() -> Color:
	if session.prism.active:
		if reduce_effects:
			return Palette.ORB_CRYSTAL
		var phase: float = fposmod(_time / PRISM_CORE_CYCLE, 1.0) * 4.0
		var index: int = floori(phase)
		return Palette.orb(index).lerp(Palette.orb((index + 1) % 4), phase - index)
	return Palette.orb(session.sequence.current())


func _end_fade() -> float:
	if _end_time < 0.0:
		return 1.0
	return clampf(1.0 - _end_time / session.config.end_sequence_duration, 0.0, 1.0)


func _draw() -> void:
	if session == null:
		return
	var radius: float = layout.arena_radius
	var config: GameConfig = session.config
	var fade: float = _end_fade()
	# Círculo de aparición (ART-013)
	draw_arc(Vector2.ZERO, config.spawn_radius * radius, 0, TAU, 128, Palette.alpha(Palette.TEXT_PRIMARY, 0.08 * fade), layout.px(1), true)
	# Zona de captura (ART-012)
	var occupied: bool = session.orb_in_zone() != null
	_draw_ring(config.zone_inner_radius * radius, config.zone_outer_radius * radius, Palette.alpha(Palette.TEXT_PRIMARY, (0.08 if occupied else 0.04) * fade))
	var border_alpha: float = (0.60 if occupied else 0.25) * fade
	if _ripple > 0.0:
		border_alpha = maxf(border_alpha, 0.15 + 0.45 * _ripple / 0.15)
	for r: float in [config.zone_inner_radius, config.zone_outer_radius]:
		draw_arc(Vector2.ZERO, r * radius, 0, TAU, 128, Palette.alpha(Palette.TEXT_PRIMARY, border_alpha), layout.px(2), true)
	# Orbes (ART-015/016) y estelas (ART-060)
	for orb: Orb in session.orbs:
		_draw_orb(orb, fade)
	_draw_core(fade)
	# Textos emergentes (ART-030); las partículas se dibujan en la capa aditiva.
	var font: Font = UiKit.font(UiKit.FONT_TITLE)
	var font_size: int = layout.font_px(18)
	for popup: Dictionary in _popups:
		var age: float = popup["age"]
		var alpha: float = 1.0 if age < 0.3 else 1.0 - (age - 0.3) / 0.2
		var at: Vector2 = popup["position"] + Vector2(0, -0.08 * radius * age / 0.5)
		draw_string(font, at + Vector2(-layout.px(24), 0), popup["text"], HORIZONTAL_ALIGNMENT_CENTER, layout.px(48), font_size, Palette.alpha(Palette.TEXT_PRIMARY, alpha))
	_draw_next(fade)


## Corona rellena sin costura: un arco grueso cerrado solapa sus extremos y deja una línea más opaca.
## La malla se construye una vez (los radios no cambian durante la partida) para no triangular en cada fotograma.
func _draw_ring(inner: float, outer: float, color: Color) -> void:
	if _ring_mesh == null:
		_ring_mesh = _build_ring_mesh(inner, outer)
	draw_mesh(_ring_mesh, null, Transform2D.IDENTITY, color)


static func _build_ring_mesh(inner: float, outer: float) -> ArrayMesh:
	const SEGMENTS: int = 96
	var vertices := PackedVector2Array()
	for i: int in SEGMENTS:
		var a: Vector2 = Vector2.from_angle(TAU * i / SEGMENTS)
		var b: Vector2 = Vector2.from_angle(TAU * (i + 1) / SEGMENTS)
		vertices.append_array([a * inner, a * outer, b * outer, a * inner, b * outer, b * inner])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _draw_orb(orb: Orb, fade: float) -> void:
	var radius: float = layout.arena_radius
	var at: Vector2 = orb.direction() * orb.radius * radius
	var orb_radius: float = session.config.orb_radius * radius
	var color: Color = Palette.orb(orb.kind)
	_draw_trail(orb, at, orb_radius, color, fade)
	if orb.kind == OrbType.Kind.CRYSTAL:
		draw_circle(at, orb_radius, Palette.alpha(Palette.ORB_CRYSTAL, 0.85 * fade), true, -1.0, true)
		var shimmer: float = 0.0 if reduce_effects else fposmod(_time / 1.2, 1.0) * 4.0
		var tint: Color = Palette.orb(floori(shimmer) % 4)
		draw_arc(at, orb_radius * 0.7, shimmer, shimmer + PI * 0.8, 24, Palette.alpha(tint, 0.6 * fade), layout.px(3), true)
		draw_arc(at, orb_radius, 0, TAU, 48, Palette.alpha(Palette.TEXT_PRIMARY, fade), layout.px(2), true)
	else:
		Glyphs.sphere(self, at, orb_radius, Color(color, fade), _highlight, 0.5 * fade)
	if show_symbols or orb.kind == OrbType.Kind.CRYSTAL:
		Glyphs.draw(self, orb.kind, at, orb_radius * 0.6, Palette.alpha(Palette.UI_GLYPH, 0.85 * fade))


func _draw_trail(orb: Orb, at: Vector2, orb_radius: float, color: Color, fade: float) -> void:
	CosmeticArt.draw_trail(self, trail_skin, at, orb.direction(), orb_radius, 0.15 * layout.arena_radius, color, fade, _time, reduce_effects)


func _draw_core(fade: float) -> void:
	var radius: float = session.config.core_radius * layout.arena_radius
	var color: Color = _target_color()
	if _core_flash > 0.0:
		color = color.lerp(Color.WHITE, 0.4)
	var core_fade: float = fade if session.state != GameSession.State.COMPLETED else 1.0
	var offset := Vector2.ZERO
	if _glitch > 0.0:
		offset = Vector2(layout.px(3), 0)
		draw_circle(-offset, radius, Palette.alpha(Palette.ORB_MAGENTA, 0.5 * core_fade), true, -1.0, true)
	Glyphs.sphere(self, offset, radius, Color(color, core_fade), _highlight, 0.6 * core_fade)
	_draw_core_skin(radius, core_fade)
	# Facetas (ART-011.5): arcos que giran; estáticos con «Reducir efectos».
	var spin: float = 0.0 if reduce_effects else _time * CORE_FACET_SPEED * TAU
	for i: int in 3:
		var start: float = spin + i * TAU / 3.0
		draw_arc(offset, radius * 0.78, start, start + 0.6, 12, Palette.alpha(Color.WHITE, 0.35 * core_fade), layout.px(2), true)
	draw_arc(offset, radius, 0, TAU, 64, Palette.alpha(Palette.TEXT_PRIMARY, 0.6 * core_fade), 0.015 * layout.arena_radius, true)
	if show_symbols and not session.prism.active:
		Glyphs.draw(self, session.sequence.current(), offset, radius * 0.6, Palette.alpha(Palette.UI_GLYPH, 0.85 * core_fade))


func _draw_core_skin(radius: float, alpha: float) -> void:
	CosmeticArt.draw_core_skin(self, core_skin, Vector2.ZERO, radius, alpha, _time, reduce_effects, layout.px(2))


func _draw_next(fade: float) -> void:
	var radius: float = layout.arena_radius
	var next_radius: float = 0.04 * radius
	var at := Vector2(0, layout.arena_bounds_radius() + layout.px(12) + next_radius)
	var kind: OrbType.Kind = session.sequence.next()
	Glyphs.sphere(self, at, next_radius, Color(Palette.orb(kind), fade), _highlight, 0.4 * fade)
	if show_symbols:
		Glyphs.draw(self, kind, at, next_radius * 0.6, Palette.alpha(Palette.UI_GLYPH, 0.85 * fade))
	var font: Font = UiKit.font(UiKit.FONT_BODY_BOLD)
	var font_size: int = layout.font_px(14)
	var label: String = tr("HUD_NEXT")
	draw_string(font, at + Vector2(-layout.px(80), next_radius + layout.px(4) + font_size), label, HORIZONTAL_ALIGNMENT_CENTER, layout.px(160), font_size, Palette.alpha(Palette.TEXT_SECONDARY, fade))


func _draw_glow() -> void:
	if session == null:
		return
	var radius: float = layout.arena_radius
	var fade: float = _end_fade()
	for orb: Orb in session.orbs:
		var at: Vector2 = orb.direction() * orb.radius * radius
		var halo: float = 1.6 * session.config.orb_radius * radius
		var tint: Color = Palette.orb(orb.kind)
		if session.prism.active and not reduce_effects:
			tint = tint.lerp(Palette.orb(floori(fposmod(_time * 4.0, 4.0))), 0.5)
		_glow.draw_texture_rect(_soft, Rect2(at - Vector2(halo, halo), Vector2(halo, halo) * 2.0), false, Palette.alpha(tint, 0.35 * fade))
	# Halo del núcleo según energía (ART-011.4) y pulso crítico (ART-034).
	var energy_ratio: float = float(session.energy) / session.config.energy_max
	var core_alpha: float = 0.15 + 0.20 * energy_ratio
	if session.is_energy_critical():
		core_alpha *= 0.6 + 0.4 * (0.5 + 0.5 * sin(TAU * _time))
	var halo_radius: float = 0.22 * radius
	var core_fade: float = fade if session.state != GameSession.State.COMPLETED else 1.0
	_glow.draw_texture_rect(_soft, Rect2(-Vector2(halo_radius, halo_radius), Vector2(halo_radius, halo_radius) * 2.0), false, Palette.alpha(_target_color(), core_alpha * core_fade))
	# Aviso de fin de PRISM: el brillo pulsa ±20 % a 2 Hz (ART-032).
	if session.prism.active and session.prism.time_left <= session.config.prism_warning_time:
		var pulse: float = 0.2 * sin(TAU * 2.0 * _time)
		_glow.draw_texture_rect(_soft, Rect2(-Vector2(halo_radius, halo_radius), Vector2(halo_radius, halo_radius) * 2.0), false, Palette.alpha(Color.WHITE, maxf(0.0, pulse)))
	# Onda prismática (ART-031/044).
	if _prism_wave >= 0.0:
		var progress: float = _prism_wave / 0.4
		for i: int in 4:
			_glow.draw_arc(Vector2.ZERO, radius * progress * (1.0 - i * 0.04), 0, TAU, 96, Palette.alpha(Palette.orb(i), 0.5 * (1.0 - progress)), layout.px(6), true)
	_particles.draw(_glow)
