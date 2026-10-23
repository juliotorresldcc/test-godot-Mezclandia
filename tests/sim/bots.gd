class_name SimBot
extends RefCounted
## Bots de verificación (parameters.md §7). Herramientas de prueba, no jugabilidad.

enum Kind { NOVICE, EXPERT, SPAM, PASSIVE, RANDOM }

const ERROR_RATES: Dictionary[Kind, float] = {Kind.NOVICE: 0.10, Kind.EXPERT: 0.02}

var kind: Kind
var _rng := RandomNumberGenerator.new()
var _seen: Dictionary[int, bool] = {}
## id de orbe → número de paso en el que el bot decide.
var _decisions: Dictionary[int, int] = {}


func _init(bot_kind: Kind, seed_value: int) -> void:
	kind = bot_kind
	_rng.seed = seed_value


## Se llama antes de cada paso de simulación.
func before_step(session: GameSession) -> void:
	match kind:
		Kind.PASSIVE:
			return
		Kind.SPAM:
			session.request_pulse()
			return
	var orb: Orb = session.orb_in_zone()
	if orb == null:
		return
	if not _seen.has(orb.id):
		_seen[orb.id] = true
		var speed: float = Difficulty.orb_speed(session.config, session.t)
		var window_steps: int = maxi(1, floori((session.config.zone_outer_radius - session.config.zone_inner_radius) / speed / session.config.sim_step))
		_decisions[orb.id] = session.steps + _rng.randi_range(0, window_steps - 1)
	if _decisions.get(orb.id, -1) != session.steps:
		return
	_decisions.erase(orb.id)
	var tap: bool
	if kind == Kind.RANDOM:
		tap = _rng.randf() < 0.5
	else:
		tap = session.capture_would_hit(orb)
		if _rng.randf() < ERROR_RATES[kind]:
			tap = not tap
	if tap:
		session.request_pulse()


## Juega una partida completa y devuelve la sesión terminada.
static func play(bot_kind: Kind, seed_value: int, config: GameConfig, debug_checks: bool = false) -> GameSession:
	var session := GameSession.new(config, seed_value)
	session.debug_checks = debug_checks
	var bot := SimBot.new(bot_kind, seed_value ^ 0x5bd1e995)
	session.start()
	while session.state == GameSession.State.PLAYING:
		bot.before_step(session)
		session.step()
	return session
