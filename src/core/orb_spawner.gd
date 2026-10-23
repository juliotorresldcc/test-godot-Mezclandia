class_name OrbSpawner
extends RefCounted
## Cuándo, dónde y de qué tipo aparece cada orbe (FR-ORB-002…005, FR-SEQ-004, FR-EVT-002).

var non_target_streak: int = 0
var crystals_spawned: int = 0

var _config: GameConfig
var _rng: RandomNumberGenerator
var _next_spawn_time: float = 0.0
var _last_angle: float = -1.0
var _last_crystal_time: float = -INF
var _next_id: int = 0
var _warned_full: bool = false


func _init(config: GameConfig, rng: RandomNumberGenerator) -> void:
	_config = config
	_rng = rng


## Intenta generar un orbe en el instante t. Devuelve null si no corresponde.
func try_spawn(t: float, orbs_in_flight: Array[Orb], sequence: TargetSequence, prism_active: bool) -> Orb:
	if t + 1e-9 < _next_spawn_time:
		return null
	if orbs_in_flight.size() >= _config.max_orbs_in_flight:
		if not _warned_full:
			_warned_full = true
			push_warning("OrbSpawner: max_orbs_in_flight alcanzado; revisa la configuración (FR-ORB-004).")
		return null
	_next_spawn_time = t + Difficulty.spawn_interval(_config, t)
	var projected: OrbType.Kind = sequence.projected(orbs_in_flight)
	var kind: OrbType.Kind = _choose_kind(t, projected, prism_active)
	var orb := Orb.new(_next_id, kind, _config.spawn_radius, _next_angle(), t, projected)
	_next_id += 1
	return orb


func _next_angle() -> float:
	var angle: float
	if _last_angle < 0.0:
		angle = 360.0 * _rng.randf()
	else:
		var gap: float = _config.orb_min_angle_gap
		angle = fposmod(_last_angle + gap + _rng.randf() * (360.0 - 2.0 * gap), 360.0)
	_last_angle = angle
	return angle


func _choose_kind(t: float, projected: OrbType.Kind, prism_active: bool) -> OrbType.Kind:
	if non_target_streak >= _config.pity_max_non_target:
		non_target_streak = 0
		return projected
	if _crystal_eligible(t, prism_active) and _rng.randf() < _config.crystal_spawn_chance:
		crystals_spawned += 1
		_last_crystal_time = t
		return OrbType.Kind.CRYSTAL
	if _rng.randf() < Difficulty.target_chance(_config, t):
		non_target_streak = 0
		return projected
	var others: Array[OrbType.Kind] = Difficulty.active_colors(_config, t)
	others.erase(projected)
	non_target_streak += 1
	return others[_rng.randi_range(0, others.size() - 1)]


func _crystal_eligible(t: float, prism_active: bool) -> bool:
	return (t >= _config.crystal_min_time - 1e-9
		and not prism_active
		and t - _last_crystal_time >= _config.crystal_cooldown - 1e-9
		and crystals_spawned < _config.crystal_max_per_session)
