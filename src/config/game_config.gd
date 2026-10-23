class_name GameConfig
extends Resource
## Parámetros ajustables del juego (NFR-MNT-001).
## Fuente documental: specs/001-prism-pop/parameters.md. tools/check_sync.py
## comprueba que los valores por defecto y los rangos coinciden con el documento.

# --- 2.1 Geometría (unidades R) ---
@export var spawn_radius: float = 1.0
@export var core_radius: float = 0.12
@export var zone_inner_radius: float = 0.17
@export var zone_outer_radius: float = 0.37
@export var orb_radius: float = 0.05
@export var orb_min_angle_gap: float = 40.0
@export var max_orbs_in_flight: int = 6
@export var min_radial_gap: float = 0.35

# --- 2.2 Simulación ---
@export var sim_step: float = 1.0 / 60.0

# --- 2.3 Dificultad ---
@export var difficulty_ramp_time: float = 60.0
@export var orb_speed_min: float = 0.35
@export var orb_speed_max: float = 0.80
@export var spawn_interval_max: float = 1.10
@export var spawn_interval_min: float = 0.45
@export var target_chance_start: float = 0.55
@export var target_chance_end: float = 0.40
@export var pity_max_non_target: int = 3
@export var fourth_color_time: float = 20.0
@export var new_color_notice_duration: float = 1.0

# --- 2.4 Entrada ---
@export var pulse_cooldown: float = 0.15

# --- 2.5 Puntuación y combos ---
@export var score_base: int = 100
@export var combo_step: int = 5
@export var mult_step: float = 0.5
@export var mult_max: float = 4.0
@export var prism_score_factor: float = 2.0
@export var combo_broken_feedback: float = 0.5

# --- 2.6 Energía ---
@export var energy_max: int = 100
@export var energy_start: int = 100
@export var energy_error_cost: int = 35
@export var energy_hit_gain: int = 1

# --- 2.7 Modo PRISM ---
@export var prism_charge_max: int = 100
@export var prism_charge_per_hit: int = 4
@export var prism_charge_per_crystal: int = 20
@export var prism_duration: float = 6.0
@export var prism_warning_time: float = 1.5

# --- 2.8 Orbe cristal ---
@export var crystal_min_time: float = 10.0
@export var crystal_spawn_chance: float = 0.04
@export var crystal_cooldown: float = 8.0
@export var crystal_max_per_session: int = 5
@export var crystal_orb_reward: int = 3

# --- 2.9 Sesión ---
@export var session_max_time: float = 90.0
@export var resume_countdown: float = 1.5
@export var end_sequence_duration: float = 1.0

# --- 4 Presentación, audio, progresión y UX ---
@export var splash_min_time: float = 1.0
@export var onboarding_sessions: int = 3
@export var break_reminder_interval: int = 30
@export var pause_music_duck_db: float = -12.0
@export var sfx_max_voices: int = 12
@export var haptic_hit_ms: int = 15
@export var haptic_error_ms: int = 50
@export var haptic_prism_ms: int = 80
@export var crystals_score_divisor: int = 1000
@export var crystals_completion_bonus: int = 5
@export var crystals_balance_cap: int = 999999
@export var mission_slots: int = 3
@export var mission_tier_cap: int = 10

## Rangos permitidos de parameters.md (mínimo, máximo). Los límites que dependen
## de otro parámetro («energy_start ≤ energy_max») se comprueban aparte.
const RANGES: Dictionary[String, Vector2] = {
	"spawn_radius": Vector2(1.0, 1.0),
	"core_radius": Vector2(0.08, 0.16),
	"zone_inner_radius": Vector2(0.14, 0.25),
	"zone_outer_radius": Vector2(0.30, 0.50),
	"orb_radius": Vector2(0.035, 0.07),
	"orb_min_angle_gap": Vector2(0.0, 90.0),
	"max_orbs_in_flight": Vector2(3, 12),
	"min_radial_gap": Vector2(0.25, 0.60),
	"sim_step": Vector2(1.0 / 120.0, 1.0 / 30.0),
	"difficulty_ramp_time": Vector2(30.0, 120.0),
	"orb_speed_min": Vector2(0.20, 0.60),
	"orb_speed_max": Vector2(0.50, 1.20),
	"spawn_interval_max": Vector2(0.60, 2.00),
	"spawn_interval_min": Vector2(0.30, 1.00),
	"target_chance_start": Vector2(0.30, 0.80),
	"target_chance_end": Vector2(0.25, 0.70),
	"pity_max_non_target": Vector2(1, 6),
	"fourth_color_time": Vector2(0.0, 60.0),
	"new_color_notice_duration": Vector2(0.5, 2.0),
	"pulse_cooldown": Vector2(0.05, 0.30),
	"score_base": Vector2(10, 1000),
	"combo_step": Vector2(1, 20),
	"mult_step": Vector2(0.1, 1.0),
	"mult_max": Vector2(1.0, 10.0),
	"prism_score_factor": Vector2(1.0, 5.0),
	"combo_broken_feedback": Vector2(0.2, 1.0),
	"energy_max": Vector2(100, 100),
	"energy_start": Vector2(1, 100),
	"energy_error_cost": Vector2(10, 100),
	"energy_hit_gain": Vector2(0, 10),
	"prism_charge_max": Vector2(100, 100),
	"prism_charge_per_hit": Vector2(1, 20),
	"prism_charge_per_crystal": Vector2(0, 100),
	"prism_duration": Vector2(3.0, 12.0),
	"prism_warning_time": Vector2(0.5, 3.0),
	"crystal_min_time": Vector2(0.0, 60.0),
	"crystal_spawn_chance": Vector2(0.0, 0.20),
	"crystal_cooldown": Vector2(2.0, 30.0),
	"crystal_max_per_session": Vector2(0, 10),
	"crystal_orb_reward": Vector2(0, 20),
	"session_max_time": Vector2(60.0, 180.0),
	"resume_countdown": Vector2(0.0, 3.0),
	"end_sequence_duration": Vector2(0.5, 2.0),
	"splash_min_time": Vector2(0.0, 3.0),
	"onboarding_sessions": Vector2(0, 10),
	"break_reminder_interval": Vector2(15, 120),
	"pause_music_duck_db": Vector2(-40.0, 0.0),
	"sfx_max_voices": Vector2(4, 32),
	"haptic_hit_ms": Vector2(0, 50),
	"haptic_error_ms": Vector2(0, 150),
	"haptic_prism_ms": Vector2(0, 200),
	"crystals_score_divisor": Vector2(100, 10000),
	"crystals_completion_bonus": Vector2(0, 50),
	"crystals_balance_cap": Vector2(999999, 999999),
	"mission_slots": Vector2(1, 5),
	"mission_tier_cap": Vector2(0, 50),
}

const _EPS: float = 1e-9

static var _shared: GameConfig


## Configuración compartida por la aplicación (valores por defecto aprobados).
static func shared() -> GameConfig:
	if _shared == null:
		_shared = GameConfig.new()
	return _shared


## Producto v(u)·Δ(u) para u en [0, 1] (restricción C4).
func radial_gap_at(u: float) -> float:
	var speed: float = orb_speed_min + (orb_speed_max - orb_speed_min) * u
	var interval: float = spawn_interval_max - (spawn_interval_max - spawn_interval_min) * u
	return speed * interval


## Mínimo de v·Δ en [0, 1]: extremos y vértice de la parábola (parameters.md C4).
func min_radial_gap_over_ramp() -> float:
	var candidates: Array[float] = [radial_gap_at(0.0), radial_gap_at(1.0)]
	var a: float = -(orb_speed_max - orb_speed_min) * (spawn_interval_max - spawn_interval_min)
	var b: float = (orb_speed_max - orb_speed_min) * spawn_interval_max - orb_speed_min * (spawn_interval_max - spawn_interval_min)
	if absf(a) > _EPS:
		var vertex: float = -b / (2.0 * a)
		if vertex > 0.0 and vertex < 1.0:
			candidates.append(radial_gap_at(vertex))
	return candidates.min()


## Devuelve la lista de restricciones incumplidas; vacía si la configuración es válida (FR-FAIR-005).
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	for key: String in RANGES:
		var value: float = float(get(key))
		var limits: Vector2 = RANGES[key]
		if value < limits.x - _EPS or value > limits.y + _EPS:
			errors.append("Rango: %s = %s fuera de [%s, %s]" % [key, value, limits.x, limits.y])
	if not (core_radius < zone_inner_radius and zone_inner_radius < zone_outer_radius and zone_outer_radius < spawn_radius):
		errors.append("C1: radios no ordenados")
	if core_radius + orb_radius > zone_inner_radius + _EPS:
		errors.append("C2: core_radius + orb_radius > zone_inner_radius")
	if orb_speed_min > orb_speed_max or spawn_interval_min > spawn_interval_max or target_chance_end > target_chance_start:
		errors.append("C3: mínimos/máximos invertidos")
	if min_radial_gap_over_ramp() < min_radial_gap - _EPS:
		errors.append("C4: v·Δ mínimo %.4f < min_radial_gap" % min_radial_gap_over_ramp())
	if min_radial_gap <= zone_outer_radius - zone_inner_radius or min_radial_gap < 2.0 * orb_radius - _EPS:
		errors.append("C5: min_radial_gap insuficiente")
	if pity_max_non_target < 1:
		errors.append("C6: pity_max_non_target < 1")
	if prism_warning_time >= prism_duration:
		errors.append("C7: prism_warning_time >= prism_duration")
	if energy_start < 1 or energy_start > energy_max:
		errors.append("C8: energy_start fuera de [1, energy_max]")
	if mult_max < 1.0 or mult_step <= 0.0:
		errors.append("C9: multiplicador inválido")
	var travel: float = spawn_radius - zone_inner_radius
	var max_in_flight: float = travel / min_radial_gap_over_ramp()
	if max_orbs_in_flight < ceili(max_in_flight - _EPS) + 1:
		errors.append("C10: max_orbs_in_flight < %d" % (ceili(max_in_flight - _EPS) + 1))
	if pulse_cooldown >= (zone_outer_radius - zone_inner_radius) / orb_speed_max:
		errors.append("C11: pulse_cooldown >= ventana mínima en zona")
	if fourth_color_time >= session_max_time:
		errors.append("C12: fourth_color_time >= session_max_time")
	if mission_slots > MissionCatalog.TEMPLATE_IDS.size() - 1:
		errors.append("mission_slots > plantillas − 1")
	return errors
