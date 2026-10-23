class_name Difficulty
extends RefCounted
## Curva de dificultad (FR-DIF-001…003). Funciones puras del tiempo de juego.


static func progress(config: GameConfig, t: float) -> float:
	return clampf(maxf(t, 0.0) / config.difficulty_ramp_time, 0.0, 1.0)


## Velocidad global de los orbes en R/s.
static func orb_speed(config: GameConfig, t: float) -> float:
	var u: float = progress(config, t)
	var speed: float = config.orb_speed_min + (config.orb_speed_max - config.orb_speed_min) * u
	return clampf(speed, config.orb_speed_min, config.orb_speed_max)


## Intervalo de aparición en s.
static func spawn_interval(config: GameConfig, t: float) -> float:
	var u: float = progress(config, t)
	var interval: float = config.spawn_interval_max - (config.spawn_interval_max - config.spawn_interval_min) * u
	# Límite explícito: el redondeo de coma flotante no puede bajar de spawn_interval_min (FR-DIF-002).
	return clampf(interval, config.spawn_interval_min, config.spawn_interval_max)


## Probabilidad de que un orbe nuevo sea del objetivo proyectado.
static func target_chance(config: GameConfig, t: float) -> float:
	var u: float = progress(config, t)
	var chance: float = config.target_chance_start - (config.target_chance_start - config.target_chance_end) * u
	return clampf(chance, config.target_chance_end, config.target_chance_start)


## Colores activos en el instante t (FR-COL-002).
static func active_colors(config: GameConfig, t: float) -> Array[OrbType.Kind]:
	if t >= config.fourth_color_time - 1e-9:
		return OrbType.ALL_COLORS.duplicate()
	return OrbType.BASE_COLORS.duplicate()
