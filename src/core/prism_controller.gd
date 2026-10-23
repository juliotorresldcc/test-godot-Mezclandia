class_name PrismController
extends RefCounted
## Carga, activación, aviso y fin del modo PRISM (FR-PRM-001…006).

enum Event { NONE, WARNING, ENDED }

var charge: int = 0
var active: bool = false
var time_left: float = 0.0
var activations: int = 0

var _config: GameConfig
var _warned: bool = false


func _init(config: GameConfig) -> void:
	_config = config


func on_hit() -> void:
	if not active:
		charge = mini(_config.prism_charge_max, charge + _config.prism_charge_per_hit)


func on_crystal_hit() -> void:
	if not active:
		charge = mini(_config.prism_charge_max, charge + _config.prism_charge_per_crystal)


func on_error() -> void:
	charge = floori(charge / 2.0)


## Activación automática cuando la carga está llena (FR-PRM-002).
func try_activate() -> bool:
	if active or charge < _config.prism_charge_max:
		return false
	active = true
	charge = 0
	time_left = _config.prism_duration
	activations += 1
	_warned = false
	return true


func advance(dt: float) -> Event:
	if not active:
		return Event.NONE
	time_left -= dt
	if time_left <= 1e-9:
		active = false
		time_left = 0.0
		return Event.ENDED
	if not _warned and time_left <= _config.prism_warning_time + 1e-9:
		_warned = true
		return Event.WARNING
	return Event.NONE


func end() -> void:
	active = false
	time_left = 0.0
