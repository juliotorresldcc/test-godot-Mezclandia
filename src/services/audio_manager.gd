extends Node
## Audio del juego (FR-AUD-001…005). Autoload «AudioManager».
## Degradación (FR-AUD-004): si un archivo no carga o no hay dispositivo, el juego sigue en silencio.

const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"
const SOUND_DIR: String = "res://assets/audio/"
## Identificador → prioridad (mayor = más importante al limitar voces, FR-AUD-005).
const SOUNDS: Dictionary[String, int] = {
	"pulse_empty": 0, "hit": 2, "hit_crystal": 3, "error_color": 3, "omission": 3,
	"combo_tier_up": 2, "combo_break": 2, "prism_start": 4, "prism_warning": 4, "prism_end": 4,
	"new_color": 3, "energy_critical": 4, "game_over": 5, "completed": 5, "record": 5,
	"ui_tap": 1, "ui_back": 1, "purchase": 3, "claim": 3,
}
const MUSIC_LAYERS: Array[String] = ["menu", "game_base", "game_intensity", "game_prism"]
const LAYER_FADE_SECONDS: float = 2.0
const SILENT_DB: float = -80.0

var _config: GameConfig = GameConfig.shared()
var _streams: Dictionary[String, AudioStream] = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_priority: Dictionary[AudioStreamPlayer, int] = {}
var _music: Dictionary[String, AudioStreamPlayer] = {}
var _layer_tweens: Dictionary[String, Tween] = {}
var _music_volume_percent: int = 70
var _ducked: bool = false
var _missing_reported: Dictionary[String, bool] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)
	for id: String in SOUNDS:
		_load_stream(id, SOUND_DIR + id + ".wav", false)
	for layer: String in MUSIC_LAYERS:
		_load_stream("music_" + layer, SOUND_DIR + "music_" + layer + ".wav", true)
		var player := AudioStreamPlayer.new()
		player.bus = BUS_MUSIC
		player.stream = _streams.get("music_" + layer)
		player.volume_db = SILENT_DB
		add_child(player)
		_music[layer] = player
	for i: int in _config.sfx_max_voices:
		var voice := AudioStreamPlayer.new()
		voice.bus = BUS_SFX
		add_child(voice)
		_voices.append(voice)


## Reproduce un efecto. Devuelve false si no se pudo (identificador o archivo inexistente).
func play(id: String, pitch_semitones: float = 0.0) -> bool:
	if not SOUNDS.has(id):
		push_warning("AudioManager: sonido desconocido %s" % id)
		return false
	var stream: AudioStream = _streams.get(id)
	if stream == null:
		return false
	var voice: AudioStreamPlayer = _pick_voice(SOUNDS[id])
	if voice == null:
		return false
	voice.stream = stream
	voice.pitch_scale = pow(2.0, pitch_semitones / 12.0)
	_voice_priority[voice] = SOUNDS[id]
	voice.play()
	return true


func play_menu_music() -> void:
	_start_layers(["menu"])


## Arranca las capas de partida sincronizadas; solo suena la base (FR-AUD-002).
func play_game_music() -> void:
	_start_layers(["game_base", "game_intensity", "game_prism"])
	_set_layer_level("game_intensity", false, 0.0)
	_set_layer_level("game_prism", false, 0.0)


func set_layer(layer: String, on: bool) -> void:
	_set_layer_level(layer, on, LAYER_FADE_SECONDS if layer == "game_intensity" else 0.4)


func stop_music() -> void:
	for player: AudioStreamPlayer in _music.values():
		player.stop()


## Volumen en % (0–100, pasos de 10) → dB = 20·log10(p/100); 0 silencia el bus (FR-AUD-003).
func set_music_volume(percent: int) -> void:
	_music_volume_percent = percent
	_apply_bus_volume(BUS_MUSIC, percent, _config.pause_music_duck_db if _ducked else 0.0)


func set_sfx_volume(percent: int) -> void:
	_apply_bus_volume(BUS_SFX, percent, 0.0)


func set_paused_duck(on: bool) -> void:
	_ducked = on
	set_music_volume(_music_volume_percent)


## Silencio total al perder el foco (NFR-PLAT-003).
func set_focus_mute(on: bool) -> void:
	AudioServer.set_bus_mute(0, on)


static func percent_to_db(percent: int) -> float:
	return linear_to_db(percent / 100.0) if percent > 0 else SILENT_DB


func is_loaded(id: String) -> bool:
	return _streams.get(id) != null


func _start_layers(layers: Array[String]) -> void:
	for layer: String in _music:
		var player: AudioStreamPlayer = _music[layer]
		if layer in layers:
			if not player.playing and player.stream != null:
				player.volume_db = 0.0
				player.play()
		else:
			player.stop()


func _set_layer_level(layer: String, on: bool, fade: float) -> void:
	var player: AudioStreamPlayer = _music.get(layer)
	if player == null:
		return
	if _layer_tweens.has(layer) and _layer_tweens[layer].is_valid():
		_layer_tweens[layer].kill()
	var target_db: float = 0.0 if on else SILENT_DB
	if fade <= 0.0 or not is_inside_tree():
		player.volume_db = target_db
		return
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", target_db, fade)
	_layer_tweens[layer] = tween


func _apply_bus_volume(bus_name: StringName, percent: int, offset_db: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(index, percent <= 0)
	AudioServer.set_bus_volume_db(index, percent_to_db(percent) + offset_db if percent > 0 else SILENT_DB)


func _pick_voice(priority: int) -> AudioStreamPlayer:
	for voice: AudioStreamPlayer in _voices:
		if not voice.playing:
			return voice
	# Todas ocupadas: se sustituye la de menor prioridad (la más avanzada si empatan).
	var candidate: AudioStreamPlayer = null
	for voice: AudioStreamPlayer in _voices:
		var voice_priority: int = _voice_priority.get(voice, 0)
		if voice_priority > priority:
			continue
		if candidate == null or voice_priority < _voice_priority.get(candidate, 0) \
				or (voice_priority == _voice_priority.get(candidate, 0) and voice.get_playback_position() > candidate.get_playback_position()):
			candidate = voice
	return candidate


func _load_stream(id: String, path: String, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		_report_missing(id, path)
		return
	var stream: AudioStreamWAV = load(path) as AudioStreamWAV
	if stream == null:
		_report_missing(id, path)
		return
	if loop:
		stream = stream.duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_streams[id] = stream


func _report_missing(id: String, path: String) -> void:
	if not _missing_reported.has(id):
		_missing_reported[id] = true
		push_warning("AudioManager: no se pudo cargar %s (%s); se continúa sin ese sonido." % [id, path])


func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")
