class_name Profile
extends RefCounted
## Datos persistentes del jugador (FR-SAV-001): progreso, estadísticas y ajustes.
## to_dict/from_dict definen el esquema v1 del guardado (ADR 0007).

const SCHEMA_VERSION: int = 1
## Estadísticas acumuladas (FR-STAT-010).
const STAT_KEYS: Array[String] = [
	"best_score", "sessions_finished", "sessions_abandoned", "sessions_completed",
	"total_hits", "total_errors", "best_combo", "total_prism_activations",
	"total_crystal_orbs", "total_play_seconds", "crystals_earned", "crystals_spent",
	"crystals_overflow", "sessions_started",
]


class Settings:
	var music_volume: int = 70
	var sfx_volume: int = 80
	var vibration: bool = true
	var color_symbols: bool = true
	var reduce_effects: bool = false
	var break_reminder: bool = true

	func to_dict() -> Dictionary:
		return {
			"music_volume": music_volume, "sfx_volume": sfx_volume, "vibration": vibration,
			"color_symbols": color_symbols, "reduce_effects": reduce_effects, "break_reminder": break_reminder,
		}


class MissionState:
	var template_id: String
	var tier: int
	var target: int
	var reward: int
	var progress: int = 0

	func is_completed() -> bool:
		return progress >= target

	func to_dict() -> Dictionary:
		return {"template": template_id, "tier": tier, "target": target, "reward": reward, "progress": progress}


var crystals: int = 0
var owned: Array[String] = []
var equipped: Dictionary[String, String] = {}
var missions: Array[MissionState] = []
var template_tiers: Dictionary[String, int] = {}
var mission_rng_seed: int = 0
var mission_rng_state: int = 0
var stats: Dictionary[String, int] = {}
var settings := Settings.new()


## Perfil inicial: elementos por defecto poseídos y equipados, misiones iniciales (FR-MIS-006).
static func create_new(rng_seed: int, config: GameConfig) -> Profile:
	var profile := Profile.new()
	for category: String in CosmeticsCatalog.CATEGORIES:
		var id: String = CosmeticsCatalog.default_for(category)
		profile.owned.append(id)
		profile.equipped[category] = id
	for template_id: String in MissionCatalog.TEMPLATE_IDS:
		profile.template_tiers[template_id] = 0
	for key: String in STAT_KEYS:
		profile.stats[key] = 0
	profile.mission_rng_seed = rng_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	profile.mission_rng_state = rng.state
	for template_id: String in MissionCatalog.INITIAL.slice(0, config.mission_slots):
		profile.missions.append(new_mission(template_id, 0, config))
	return profile


static func new_mission(template_id: String, tier: int, config: GameConfig) -> MissionState:
	var mission := MissionState.new()
	mission.template_id = template_id
	mission.tier = tier
	mission.target = MissionCatalog.target(template_id, tier, config)
	mission.reward = MissionCatalog.reward(tier)
	return mission


func to_dict() -> Dictionary:
	var mission_list: Array[Dictionary] = []
	for mission: MissionState in missions:
		mission_list.append(mission.to_dict())
	return {
		"schema_version": SCHEMA_VERSION,
		"crystals": crystals,
		"owned": owned.duplicate(),
		"equipped": equipped.duplicate(),
		"missions": mission_list,
		"template_tiers": template_tiers.duplicate(),
		# Enteros de 64 bits como texto: JSON los convertiría a coma flotante (AN-02).
		"mission_rng_seed": str(mission_rng_seed),
		"mission_rng_state": str(mission_rng_state),
		"stats": stats.duplicate(),
		"settings": settings.to_dict(),
	}


## Reconstruye y valida un perfil de esquema v1. Devuelve null si algo es inválido (FR-SAV-004).
static func from_dict(data: Dictionary, config: GameConfig) -> Profile:
	var profile := Profile.new()
	var crystals_value: Variant = _int_in(data.get("crystals"), 0, config.crystals_balance_cap)
	if crystals_value == null:
		return null
	profile.crystals = crystals_value

	var owned_data: Variant = data.get("owned")
	if not owned_data is Array:
		return null
	for id: Variant in owned_data:
		if not id is String or not CosmeticsCatalog.exists(id) or id in profile.owned:
			return null
		profile.owned.append(id)

	var equipped_data: Variant = data.get("equipped")
	if not equipped_data is Dictionary:
		return null
	for category: String in CosmeticsCatalog.CATEGORIES:
		var id: Variant = equipped_data.get(category)
		if not id is String or id not in profile.owned or CosmeticsCatalog.category_of(id) != category:
			return null
		profile.equipped[category] = id

	var tiers_data: Variant = data.get("template_tiers")
	if not tiers_data is Dictionary:
		return null
	for template_id: String in MissionCatalog.TEMPLATE_IDS:
		var tier: Variant = _int_in(tiers_data.get(template_id), 0, config.mission_tier_cap)
		if tier == null:
			return null
		profile.template_tiers[template_id] = tier

	var missions_data: Variant = data.get("missions")
	if not missions_data is Array or missions_data.size() != config.mission_slots:
		return null
	var seen: Array[String] = []
	for entry: Variant in missions_data:
		if not entry is Dictionary:
			return null
		var template_id: Variant = entry.get("template")
		if not template_id is String or template_id not in MissionCatalog.TEMPLATE_IDS or template_id in seen:
			return null
		seen.append(template_id)
		var tier: Variant = _int_in(entry.get("tier"), 0, config.mission_tier_cap)
		var progress: Variant = _int_in(entry.get("progress"), 0, 1 << 53)
		if tier == null or progress == null:
			return null
		var mission: MissionState = new_mission(template_id, tier, config)
		if _int_in(entry.get("target"), mission.target, mission.target) == null or _int_in(entry.get("reward"), mission.reward, mission.reward) == null:
			return null
		mission.progress = mini(progress, mission.target)
		profile.missions.append(mission)

	var seed_text: Variant = data.get("mission_rng_seed")
	var state_text: Variant = data.get("mission_rng_state")
	if not seed_text is String or not state_text is String or not seed_text.is_valid_int() or not state_text.is_valid_int():
		return null
	profile.mission_rng_seed = seed_text.to_int()
	profile.mission_rng_state = state_text.to_int()

	var stats_data: Variant = data.get("stats")
	if not stats_data is Dictionary:
		return null
	for key: String in STAT_KEYS:
		var value: Variant = _int_in(stats_data.get(key), 0, 1 << 53)
		if value == null:
			return null
		profile.stats[key] = value

	var settings_data: Variant = data.get("settings")
	if not settings_data is Dictionary:
		return null
	var music: Variant = _int_in(settings_data.get("music_volume"), 0, 100)
	var sfx: Variant = _int_in(settings_data.get("sfx_volume"), 0, 100)
	if music == null or sfx == null or music % 10 != 0 or sfx % 10 != 0:
		return null
	profile.settings.music_volume = music
	profile.settings.sfx_volume = sfx
	for key: String in ["vibration", "color_symbols", "reduce_effects", "break_reminder"]:
		var flag: Variant = settings_data.get(key)
		if not flag is bool:
			return null
		profile.settings.set(key, flag)
	return profile


## Entero de JSON (llega como float) dentro de [min_value, max_value]; null si no lo es.
static func _int_in(value: Variant, min_value: int, max_value: int) -> Variant:
	if not (value is float or value is int):
		return null
	var number: float = value
	if number != floorf(number) or number < min_value or number > max_value:
		return null
	return int(number)
