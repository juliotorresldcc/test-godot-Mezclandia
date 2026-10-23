class_name MissionCatalog
extends RefCounted
## Plantillas de misión (parameters.md §6, FR-MIS-*).

const TEMPLATE_IDS: Array[String] = [
	"M_HITS_SESSION", "M_COMBO", "M_SCORE_SESSION", "M_SURVIVE",
	"M_PRISM_TOTAL", "M_SESSIONS", "M_CRYSTAL_ORBS",
]
## Plantillas «en una partida»: progreso = mejor valor de una sola partida.
const PER_SESSION: Array[String] = ["M_HITS_SESSION", "M_COMBO", "M_SCORE_SESSION", "M_SURVIVE"]
## Misiones iniciales de un perfil nuevo (FR-MIS-006).
const INITIAL: Array[String] = ["M_HITS_SESSION", "M_COMBO", "M_SESSIONS"]


static func is_per_session(template_id: String) -> bool:
	return template_id in PER_SESSION


static func target(template_id: String, k: int, config: GameConfig) -> int:
	match template_id:
		"M_HITS_SESSION":
			return 20 + 10 * k
		"M_COMBO":
			return 10 + 5 * k
		"M_SCORE_SESSION":
			return 5000 + 2500 * k
		"M_SURVIVE":
			return mini(30 + 10 * k, floori(config.session_max_time))
		"M_PRISM_TOTAL", "M_CRYSTAL_ORBS":
			return 2 + k
		"M_SESSIONS":
			return 3 + k
	push_error("MissionCatalog: plantilla desconocida %s" % template_id)
	return 0


static func reward(k: int) -> int:
	return 10 + 2 * k


## Valor que aporta una partida terminada a la métrica de la plantilla.
static func session_value(template_id: String, stats: SessionStats) -> int:
	match template_id:
		"M_HITS_SESSION":
			return stats.hits
		"M_COMBO":
			return stats.best_combo
		"M_SCORE_SESSION":
			return stats.score
		"M_SURVIVE":
			return floori(stats.duration + 1e-6)
		"M_PRISM_TOTAL":
			return stats.prism_activations
		"M_SESSIONS":
			return 1
		"M_CRYSTAL_ORBS":
			return stats.crystal_orbs
	return 0


static func description_key(template_id: String) -> String:
	return "MISSION_" + template_id.trim_prefix("M_")
