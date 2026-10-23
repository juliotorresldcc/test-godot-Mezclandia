class_name Strings
extends RefCounted
## Tabla de traducción (FR-UX-004). v1: solo español (M-07). Para añadir un idioma,
## se añade otra tabla con las mismas claves y se registra en install().

const ES: Dictionary[String, String] = {
	"APP_TITLE": "PRISM POP",
	"APP_TAGLINE": "Captura la luz del color correcto",
	"COMMON_OK": "Aceptar",
	"COMMON_CANCEL": "Cancelar",
	"COMMON_CLOSE": "Cerrar",
	"LOAD_ERROR": "No se pudo leer tu progreso. Se ha guardado una copia de seguridad y se empezará un progreso nuevo.",
	"SAVE_FAILED": "No se pudo guardar el progreso",
	"EXIT_CONFIRM": "¿Salir del juego?",
	"EXIT_QUIT": "Salir",
	"MENU_PLAY": "JUGAR",
	"MENU_COLLECTION": "Colección",
	"MENU_MISSIONS": "Misiones",
	"MENU_MISSIONS_BADGE": "Misiones  (%d)",
	"MENU_SETTINGS": "Ajustes",
	"MENU_RECORD": "RÉCORD  %s",
	"MENU_CRYSTALS": "◆ %s",
	"GAME_TAP_TO_START": "Toca para empezar",
	"GAME_ONBOARDING_HINT": "Toca cuando un orbe del color del núcleo esté dentro del anillo",
	"HUD_NEXT": "SIGUIENTE",
	"HUD_ENERGY": "ENERGÍA",
	"HUD_PRISM": "PRISM",
	"HUD_COMBO": "COMBO %d",
	"HUD_NEW_COLOR": "NUEVO COLOR",
	"DEBUG_SEED": "semilla %d",
	"PAUSE_TITLE": "PAUSA",
	"PAUSE_RESUME": "Reanudar",
	"PAUSE_RESTART": "Reiniciar",
	"PAUSE_SETTINGS": "Ajustes",
	"PAUSE_QUIT": "Salir al menú",
	"RESULTS_GAME_OVER": "FIN DE LA PARTIDA",
	"RESULTS_COMPLETED": "¡PRISMA ESTABLE!",
	"RESULTS_NEW_RECORD": "NUEVO RÉCORD",
	"RESULTS_DURATION": "Duración",
	"RESULTS_HITS": "Aciertos",
	"RESULTS_ACCURACY": "Precisión",
	"RESULTS_BEST_COMBO": "Mejor combo",
	"RESULTS_PRISM": "Modo PRISM",
	"RESULTS_CRYSTALS": "+%d cristales",
	"RESULTS_CRYSTALS_BREAKDOWN": "Puntuación %d · Orbes cristal %d · Compleción %d",
	"RESULTS_MISSIONS": "Misiones completadas",
	"RESULTS_READY_TO_CLAIM": "Lista para reclamar",
	"RESULTS_BREAK_REMINDER": "Llevas %d minutos jugando. ¿Qué tal un descanso?",
	"RESULTS_RETRY": "Reintentar",
	"RESULTS_MENU": "Menú",
	"COLLECTION_TITLE": "Colección",
	"COLLECTION_TAB_CORES": "Núcleos",
	"COLLECTION_TAB_TRAILS": "Estelas",
	"COLLECTION_EQUIPPED": "EQUIPADO",
	"COLLECTION_EQUIP": "EQUIPAR",
	"COLLECTION_PRICE": "◆ %d",
	"COLLECTION_CONFIRM": "¿Comprar %s por %d cristales?",
	"COLLECTION_BUY": "Comprar",
	"COLLECTION_MISSING": "Te faltan %d cristales",
	"MISSIONS_TITLE": "Misiones",
	"MISSIONS_CLAIM": "Reclamar +%d",
	"MISSIONS_REWARD": "◆ %d",
	"MISSION_HITS_SESSION": "Acierta %d orbes en una partida",
	"MISSION_COMBO": "Alcanza un combo de %d",
	"MISSION_SCORE_SESSION": "Consigue %d puntos en una partida",
	"MISSION_SURVIVE": "Aguanta %d segundos en una partida",
	"MISSION_PRISM_TOTAL": "Activa el modo PRISM %d veces",
	"MISSION_SESSIONS": "Termina %d partidas",
	"MISSION_CRYSTAL_ORBS": "Captura %d orbes cristal",
	"STATS_TITLE": "Estadísticas",
	"STAT_BEST_SCORE": "Récord",
	"STAT_SESSIONS_FINISHED": "Partidas terminadas",
	"STAT_SESSIONS_COMPLETED": "Partidas completadas",
	"STAT_TOTAL_HITS": "Aciertos totales",
	"STAT_BEST_COMBO": "Mejor combo",
	"STAT_TOTAL_PRISM_ACTIVATIONS": "Activaciones PRISM",
	"STAT_TOTAL_CRYSTAL_ORBS": "Orbes cristal",
	"STAT_TOTAL_PLAY_SECONDS": "Tiempo de juego",
	"STAT_CRYSTALS_EARNED": "Cristales ganados",
	"SETTINGS_TITLE": "Ajustes",
	"SETTINGS_MUSIC": "Música: %d %%",
	"SETTINGS_SFX": "Efectos de sonido: %d %%",
	"SETTINGS_VIBRATION": "Vibración",
	"SETTINGS_NOT_AVAILABLE": "No disponible en este dispositivo",
	"SETTINGS_SYMBOLS": "Símbolos de color",
	"SETTINGS_REDUCE_EFFECTS": "Reducir efectos",
	"SETTINGS_BREAK_REMINDER": "Recordatorio de descanso",
	"SETTINGS_RESET": "Restablecer progreso",
	"SETTINGS_RESET_CONFIRM": "Esto borrará cristales, desbloqueos, misiones, estadísticas y récord. Los ajustes se conservan. No se puede deshacer.",
	"SETTINGS_RESET_DELETE": "Borrar",
	"SETTINGS_RESET_DONE": "Progreso restablecido",
	"SETTINGS_CREDITS": "Créditos y licencias",
	"SETTINGS_VERSION": "Versión %s",
	"CREDITS_TEXT": "PRISM POP\nDiseño, código, arte procedimental y audio sintetizado: generados en este proyecto (tools/gen_audio.py).\n\nTipografías\n· Orbitron — Copyright 2018 The Orbitron Project Authors. SIL Open Font License 1.1.\n· Exo 2 — Copyright 2013 The Exo 2 Project Authors. SIL Open Font License 1.1.\nTexto completo de la licencia en assets/fonts/.\n\nMotor\nEste juego usa Godot Engine, disponible bajo la siguiente licencia:",
	"ORB_CYAN": "Cian",
	"ORB_MAGENTA": "Magenta",
	"ORB_YELLOW": "Amarillo",
	"ORB_VIOLET": "Violeta",
	"ORB_CRYSTAL": "Cristal",
	"COSMETIC_CORE_DEFAULT": "Núcleo Estándar",
	"COSMETIC_CORE_PULSAR": "Púlsar",
	"COSMETIC_CORE_NEBULA": "Nebulosa",
	"COSMETIC_CORE_SINGULARITY": "Singularidad",
	"COSMETIC_TRAIL_DEFAULT": "Estela Básica",
	"COSMETIC_TRAIL_SPARK": "Chispa",
	"COSMETIC_TRAIL_COMET": "Cometa",
	"COSMETIC_TRAIL_AURORA": "Aurora",
}

static var _installed: bool = false


static func install() -> void:
	if _installed:
		return
	var translation := Translation.new()
	translation.locale = "es"
	for key: String in ES:
		translation.add_message(key, ES[key])
	TranslationServer.add_translation(translation)
	TranslationServer.set_locale("es")
	_installed = true


## Créditos completos: texto propio + licencia del motor (obligatoria por la licencia MIT de Godot).
static func credits() -> String:
	var components: PackedStringArray = []
	for info: Dictionary in Engine.get_copyright_info():
		components.append(info["name"])
	return "%s\n\n%s\n\nComponentes de terceros incluidos en el motor: %s." % [
		TranslationServer.translate("CREDITS_TEXT"), Engine.get_license_text(), ", ".join(components)]
