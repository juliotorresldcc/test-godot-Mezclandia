class_name GameSession
extends RefCounted
## Partida: estados (FR-GS-*), paso de simulación (FR-SIM-001), resolución (FR-RES-001),
## energía y fin (FR-ENE-*), estadísticas (FR-STAT-001). Fuente única del estado de partida.

enum State { PRE_START, PLAYING, PAUSED, RESUMING, GAME_OVER, COMPLETED, ABANDONED }
enum Result { HIT, HIT_CRYSTAL, ERROR_COLOR, OMISSION, DISCARD }

const _EPS: float = 1e-9
## Transiciones permitidas (FR-GS-002), por estado de origen.
const _ALLOWED: Dictionary[int, Array] = {
	State.PRE_START: [State.PLAYING, State.PAUSED],
	State.PLAYING: [State.PAUSED, State.GAME_OVER, State.COMPLETED],
	State.PAUSED: [State.RESUMING, State.PRE_START, State.ABANDONED],
	State.RESUMING: [State.PLAYING, State.PAUSED],
}

signal state_changed(from: State, to: State)
signal orb_spawned(orb: Orb)
signal orb_resolved(orb: Orb, result: Result, points: int)
signal pulse_empty
signal combo_changed(count: int, tier: int, tier_up: bool)
signal combo_broken(previous: int)
signal energy_changed(value: int, critical: bool)
signal prism_charge_changed(value: int)
signal prism_started
signal prism_warning
signal prism_ended
signal target_changed(current: OrbType.Kind, next: OrbType.Kind)
signal new_color_activated
signal crystal_collected(amount: int)

var config: GameConfig
var session_seed: int
var state: State = State.PRE_START
## Número de pasos de simulación en PLAYING; t = steps · sim_step (sin acumulación de error).
var steps: int = 0
var energy: int = 0
var score: int = 0
var combo: ComboTracker
var prism: PrismController
var sequence: TargetSequence
var spawner: OrbSpawner
## Orbes en vuelo en orden de aparición (= orden de llegada, FR-ORB-001).
var orbs: Array[Orb] = []
var stats := SessionStats.new()
var resume_time_left: float = 0.0
var fourth_color_active: bool = false
## Activa la comprobación de invariantes FR-FAIR-001 y FR-SEQ-005 en cada paso (pruebas).
var debug_checks: bool = false
var invariant_violations: int = 0
var config_errors: PackedStringArray

var _rng := RandomNumberGenerator.new()
var _pause_origin: State = State.PRE_START
var _pulse_pending: bool = false
var _last_pulse_time: float = -INF
var _spawning_enabled: bool = true
var _critical: bool = false


func _init(game_config: GameConfig, seed_value: int) -> void:
	config = game_config
	session_seed = seed_value
	_rng.seed = seed_value
	config_errors = config.validate()
	if not config_errors.is_empty():
		push_error("GameSession: configuración inválida (FR-FAIR-005): %s" % "; ".join(config_errors))
	combo = ComboTracker.new(config)
	prism = PrismController.new(config)
	sequence = TargetSequence.new(_rng, _current_active_colors)
	spawner = OrbSpawner.new(config, _rng)
	energy = config.energy_start


var t: float:
	get:
		return steps * config.sim_step


func is_terminal() -> bool:
	return state in [State.GAME_OVER, State.COMPLETED, State.ABANDONED]


func is_energy_critical() -> bool:
	return energy > 0 and energy <= config.energy_error_cost


## T01: primer toque en PRE_START. Ese toque no genera pulso.
func start() -> bool:
	if not config_errors.is_empty() or state != State.PRE_START:
		return false
	_transition(State.PLAYING)
	_spawn_if_due()
	target_changed.emit(sequence.current(), sequence.next())
	energy_changed.emit(energy, is_energy_critical())
	return true


## Solicitud de pulso (FR-INP-002/003). Devuelve true si se aceptó.
func request_pulse() -> bool:
	if state != State.PLAYING or _pulse_pending:
		return false
	if t - _last_pulse_time < config.pulse_cooldown - _EPS:
		return false
	_pulse_pending = true
	return true


## Un paso de simulación en el orden exacto de FR-SIM-001.
func step() -> void:
	if state != State.PLAYING:
		return
	# 1. Pulso
	if _pulse_pending:
		_pulse_pending = false
		_last_pulse_time = t
		_resolve_pulse()
	# 2. Tiempo
	steps += 1
	var dt: float = config.sim_step
	combo.advance(dt)
	match prism.advance(dt):
		PrismController.Event.WARNING:
			prism_warning.emit()
		PrismController.Event.ENDED:
			prism_ended.emit()
	if not fourth_color_active and t >= config.fourth_color_time - _EPS:
		fourth_color_active = true
		new_color_activated.emit()
	# 3. Movimiento
	var speed: float = Difficulty.orb_speed(config, t)
	for orb: Orb in orbs:
		orb.radius -= speed * dt
		if not orb.entered_zone and orb.radius <= config.zone_outer_radius:
			orb.entered_zone = true
			if debug_checks:
				_check_zone_entry(orb)
	# 4. Impactos
	while not orbs.is_empty() and orbs[0].radius <= config.zone_inner_radius + _EPS:
		_resolve_impact(orbs.pop_front())
	# 5. Aparición
	_spawn_if_due()
	# 6. Activación PRISM
	if prism.try_activate():
		prism_started.emit()
		prism_charge_changed.emit(prism.charge)
	# 7. Fin
	if energy <= 0:
		_finish(State.GAME_OVER)
	elif t >= config.session_max_time - _EPS:
		_finish(State.COMPLETED)


## T02/T03/T07.
func pause() -> bool:
	if state not in [State.PRE_START, State.PLAYING, State.RESUMING]:
		return false
	_pause_origin = State.PRE_START if state == State.PRE_START else State.PLAYING
	_pulse_pending = false
	return _transition(State.PAUSED)


## T04/T05.
func resume() -> bool:
	if state != State.PAUSED:
		return false
	if _pause_origin == State.PRE_START:
		return _transition(State.PRE_START)
	resume_time_left = config.resume_countdown
	_transition(State.RESUMING)
	if resume_time_left <= 0.0:
		_transition(State.PLAYING)
	return true


## Cuenta atrás de RESUMING en tiempo real (FR-GS-004).
func update_real_time(delta: float) -> void:
	if state != State.RESUMING:
		return
	resume_time_left -= delta
	if resume_time_left <= _EPS:
		resume_time_left = 0.0
		_transition(State.PLAYING)


## T10: Reiniciar o Salir al menú desde PAUSED.
func abandon() -> bool:
	if state != State.PAUSED:
		return false
	orbs.clear()
	stats.duration = t
	stats.end_state = State.ABANDONED
	return _transition(State.ABANDONED)


## Orbe cuyo centro está en la zona de captura, o null (FR-FAIR-001: como máximo uno).
func orb_in_zone() -> Orb:
	for orb: Orb in orbs:
		if orb.radius > config.zone_inner_radius and orb.radius <= config.zone_outer_radius:
			return orb
	return null


## Indica si capturar ahora el orbe dado sería un acierto (usado por los bots de verificación).
func capture_would_hit(orb: Orb) -> bool:
	return prism.active or orb.kind == OrbType.Kind.CRYSTAL or orb.kind == sequence.current()


# --- Ganchos de prueba (design.md §2.7) ---

func set_spawning_enabled(enabled: bool) -> void:
	_spawning_enabled = enabled


func inject_orb(kind: OrbType.Kind, radius: float) -> Orb:
	var orb := Orb.new(1000 + orbs.size(), kind, radius, 0.0, t, sequence.projected(orbs))
	orb.entered_zone = radius <= config.zone_outer_radius
	orbs.append(orb)
	return orb


# --- Implementación ---

func _current_active_colors() -> Array[OrbType.Kind]:
	return Difficulty.active_colors(config, t)


func _transition(to: State) -> bool:
	var allowed: Array = _ALLOWED.get(state, [])
	if to not in allowed:
		if OS.is_debug_build():
			push_warning("GameSession: transición no permitida %s → %s" % [State.keys()[state], State.keys()[to]])
		return false
	var from: State = state
	state = to
	state_changed.emit(from, to)
	return true


func _spawn_if_due() -> void:
	if not _spawning_enabled:
		return
	var orb: Orb = spawner.try_spawn(t, orbs, sequence, prism.active)
	if orb != null:
		orbs.append(orb)
		orb_spawned.emit(orb)


func _resolve_pulse() -> void:
	var orb: Orb = orb_in_zone()
	if orb == null:
		stats.empty_pulses += 1
		pulse_empty.emit()
		return
	orbs.erase(orb)
	var was_target: bool = OrbType.is_color(orb.kind) and orb.kind == sequence.current()
	var advanced: bool = sequence.on_consumed(orb.kind)
	if prism.active or orb.kind == OrbType.Kind.CRYSTAL or was_target:
		_register_hit(orb)
	else:
		_register_error(orb, Result.ERROR_COLOR)
	if advanced:
		target_changed.emit(sequence.current(), sequence.next())


func _resolve_impact(orb: Orb) -> void:
	var advanced: bool = sequence.on_consumed(orb.kind)
	if advanced and not prism.active:
		_register_error(orb, Result.OMISSION)
	else:
		stats.discards += 1
		orb_resolved.emit(orb, Result.DISCARD, 0)
	if advanced:
		target_changed.emit(sequence.current(), sequence.next())


func _register_hit(orb: Orb) -> void:
	var tier_up: bool = combo.on_hit()
	var gained: int = ScoreRules.points(config, combo.count, prism.active)
	score += gained
	stats.hits += 1
	stats.best_combo = combo.best
	energy = mini(config.energy_max, energy + config.energy_hit_gain)
	var result: Result = Result.HIT
	if orb.kind == OrbType.Kind.CRYSTAL:
		result = Result.HIT_CRYSTAL
		stats.crystal_orbs += 1
		stats.crystals_from_orbs += config.crystal_orb_reward
		prism.on_crystal_hit()
		crystal_collected.emit(config.crystal_orb_reward)
	else:
		prism.on_hit()
	orb_resolved.emit(orb, result, gained)
	combo_changed.emit(combo.count, combo.tier(), tier_up)
	energy_changed.emit(energy, is_energy_critical())
	prism_charge_changed.emit(prism.charge)


func _register_error(orb: Orb, result: Result) -> void:
	var previous: int = combo.on_error()
	energy = clampi(energy - config.energy_error_cost, 0, config.energy_max)
	prism.on_error()
	if result == Result.ERROR_COLOR:
		stats.color_errors += 1
	else:
		stats.omissions += 1
	orb_resolved.emit(orb, result, 0)
	if previous > 0:
		combo_broken.emit(previous)
	combo_changed.emit(combo.count, combo.tier(), false)
	energy_changed.emit(energy, is_energy_critical())
	prism_charge_changed.emit(prism.charge)


func _finish(end_state: State) -> void:
	prism.end()
	orbs.clear()
	stats.score = score
	stats.duration = t
	stats.best_combo = combo.best
	stats.prism_activations = prism.activations
	stats.end_state = end_state
	_transition(end_state)


func _check_zone_entry(orb: Orb) -> void:
	var in_zone: int = 0
	for other: Orb in orbs:
		if other.radius > config.zone_inner_radius and other.radius <= config.zone_outer_radius:
			in_zone += 1
	if in_zone > 1:
		invariant_violations += 1
		push_error("Invariante FR-FAIR-001 violado: %d orbes en zona" % in_zone)
	if OrbType.is_color(orb.kind) and sequence.current() != orb.projected_target:
		invariant_violations += 1
		push_error("Invariante FR-SEQ-005 violado en el orbe %d" % orb.id)
