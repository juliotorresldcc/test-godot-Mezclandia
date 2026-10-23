class_name ProgressionSystem
extends RefCounted
## Reglas de progresión (spec §7): cristales, récord, estadísticas, cosméticos y misiones.

signal changed

enum ItemState { EQUIPPED, OWNED, AVAILABLE, INSUFFICIENT }


## Recompensas de una partida terminada (FR-PRG-001, FR-SCO-004).
class SessionRewards:
	var crystals_from_score: int = 0
	var crystals_from_orbs: int = 0
	var crystals_from_completion: int = 0
	var crystals_credited: int = 0
	var new_record: bool = false
	var missions_completed: Array[Profile.MissionState] = []

	func total() -> int:
		return crystals_from_score + crystals_from_orbs + crystals_from_completion


var profile: Profile
var config: GameConfig


func _init(player_profile: Profile, game_config: GameConfig) -> void:
	profile = player_profile
	config = game_config


## Cuenta las partidas iniciadas (indicación de aprendizaje, FR-UX-031).
func register_session_started() -> void:
	profile.stats["sessions_started"] += 1


func should_show_onboarding() -> bool:
	return profile.stats["sessions_started"] <= config.onboarding_sessions


## Partida abandonada: solo cuenta la estadística (FR-GS-006).
func register_abandoned() -> void:
	profile.stats["sessions_abandoned"] += 1
	changed.emit()


## Aplica una partida terminada en GAME_OVER o COMPLETED (FR-PRG-001, FR-STAT-010, FR-MIS-003).
func apply_session(stats: SessionStats) -> SessionRewards:
	var rewards := SessionRewards.new()
	var completed: bool = stats.end_state == GameSession.State.COMPLETED
	if stats.end_state != GameSession.State.GAME_OVER and not completed:
		push_error("ProgressionSystem.apply_session: la partida no terminó (estado %d)" % stats.end_state)
		return rewards
	rewards.crystals_from_score = floori(float(stats.score) / config.crystals_score_divisor)
	rewards.crystals_from_orbs = stats.crystals_from_orbs
	rewards.crystals_from_completion = config.crystals_completion_bonus if completed else 0
	rewards.crystals_credited = _credit(rewards.total())
	profile.stats["crystals_earned"] += rewards.total()

	rewards.new_record = stats.score > profile.stats["best_score"]
	if rewards.new_record:
		profile.stats["best_score"] = stats.score
	profile.stats["sessions_finished"] += 1
	if completed:
		profile.stats["sessions_completed"] += 1
	profile.stats["total_hits"] += stats.hits
	profile.stats["total_errors"] += stats.color_errors + stats.omissions
	profile.stats["best_combo"] = maxi(profile.stats["best_combo"], stats.best_combo)
	profile.stats["total_prism_activations"] += stats.prism_activations
	profile.stats["total_crystal_orbs"] += stats.crystal_orbs
	profile.stats["total_play_seconds"] += floori(stats.duration)

	for mission: Profile.MissionState in profile.missions:
		if mission.is_completed():
			continue
		var value: int = MissionCatalog.session_value(mission.template_id, stats)
		if MissionCatalog.is_per_session(mission.template_id):
			mission.progress = maxi(mission.progress, value)
		else:
			mission.progress += value
		mission.progress = mini(mission.progress, mission.target)
		if mission.is_completed():
			rewards.missions_completed.append(mission)
	changed.emit()
	return rewards


func item_state(id: String) -> ItemState:
	if profile.equipped.get(CosmeticsCatalog.category_of(id)) == id:
		return ItemState.EQUIPPED
	if id in profile.owned:
		return ItemState.OWNED
	if CosmeticsCatalog.price_of(id) <= profile.crystals:
		return ItemState.AVAILABLE
	return ItemState.INSUFFICIENT


## Compra atómica y equipamiento (FR-PRG-012, FR-UX-060).
func purchase(id: String) -> bool:
	if not CosmeticsCatalog.exists(id):
		push_warning("ProgressionSystem.purchase: id desconocido %s" % id)
		return false
	if id in profile.owned or CosmeticsCatalog.price_of(id) > profile.crystals:
		return false
	profile.crystals -= CosmeticsCatalog.price_of(id)
	profile.stats["crystals_spent"] += CosmeticsCatalog.price_of(id)
	profile.owned.append(id)
	profile.equipped[CosmeticsCatalog.category_of(id)] = id
	changed.emit()
	return true


func equip(id: String) -> bool:
	if not CosmeticsCatalog.exists(id) or id not in profile.owned:
		return false
	profile.equipped[CosmeticsCatalog.category_of(id)] = id
	changed.emit()
	return true


func claimable_count() -> int:
	var count: int = 0
	for mission: Profile.MissionState in profile.missions:
		if mission.is_completed():
			count += 1
	return count


## Reclama la misión del hueco indicado y lo rellena (FR-UX-070, FR-MIS-002/005).
## Devuelve los cristales acreditados o -1 si no se puede reclamar.
func claim(slot: int) -> int:
	if slot < 0 or slot >= profile.missions.size() or not profile.missions[slot].is_completed():
		return -1
	var mission: Profile.MissionState = profile.missions[slot]
	var credited: int = _credit(mission.reward)
	profile.stats["crystals_earned"] += mission.reward
	profile.template_tiers[mission.template_id] = mini(config.mission_tier_cap, profile.template_tiers[mission.template_id] + 1)
	var active: Array[String] = []
	for i: int in profile.missions.size():
		if i != slot:
			active.append(profile.missions[i].template_id)
	var candidates: Array[String] = []
	for template_id: String in MissionCatalog.TEMPLATE_IDS:
		if template_id not in active:
			candidates.append(template_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = profile.mission_rng_seed
	rng.state = profile.mission_rng_state
	var chosen: String = candidates[rng.randi_range(0, candidates.size() - 1)]
	profile.mission_rng_state = rng.state
	profile.missions[slot] = Profile.new_mission(chosen, profile.template_tiers[chosen], config)
	changed.emit()
	return credited


## Restablece el progreso conservando los ajustes (FR-UX-081).
func reset(rng_seed: int) -> void:
	var settings: Profile.Settings = profile.settings
	var fresh: Profile = Profile.create_new(rng_seed, config)
	profile.crystals = fresh.crystals
	profile.owned = fresh.owned
	profile.equipped = fresh.equipped
	profile.missions = fresh.missions
	profile.template_tiers = fresh.template_tiers
	profile.mission_rng_seed = fresh.mission_rng_seed
	profile.mission_rng_state = fresh.mission_rng_state
	profile.stats = fresh.stats
	profile.settings = settings
	changed.emit()


## Suma cristales respetando el límite; el excedente se registra (FR-PRG-002).
func _credit(amount: int) -> int:
	var room: int = config.crystals_balance_cap - profile.crystals
	var credited: int = mini(amount, room)
	profile.crystals += credited
	profile.stats["crystals_overflow"] += amount - credited
	return credited
