extends RefCounted
## Director de capturas (art-direction §9, T20). Lo carga capture.gd en tiempo de ejecución,
## cuando los autoloads ya existen.

var tree: SceneTree
var _out: String
var _prefix: String
var _full: bool
var gm: GameManager


func start(scene_tree: SceneTree) -> void:
	tree = scene_tree
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else "res://docs/visual"
	_prefix = args[1] if args.size() > 1 else "9x16"
	_full = args.size() < 3 or args[2] == "full"
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://capture"))
	GameManager.save_path_override = "user://capture/profile.json"
	if FileAccess.file_exists(GameManager.save_path_override):
		DirAccess.remove_absolute(GameManager.save_path_override)
	gm = (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	gm.instant_transitions = true
	tree.root.add_child(gm)
	await _wait(0.5)
	await _shot("01_inicio")
	(gm.current_screen as SplashScreen)._finish()
	gm.progression.profile.crystals = 180
	gm.progression.profile.stats["best_score"] = 18450
	gm.show_menu()
	await _wait(0.4)
	await _shot("02_menu")
	gm.start_game()
	await _wait(0.3)
	await _shot("03_pre_start")
	var screen: GameScreen = gm.current_screen as GameScreen
	var session: GameSession = screen.session
	screen.set_physics_process(false)
	session.start()
	_advance_until_zone(session)
	await _wait(0.2)
	await _shot("04_playing_orbe_en_zona")
	if not _full:
		_finish()
		return
	for i: int in 12:
		session.combo.on_hit()
	session.score = 4350
	_advance_until_zone(session)
	await _wait(0.1)
	await _shot("05_combo")
	session.steps = int(25.0 / session.config.sim_step)
	session.fourth_color_active = true
	session.prism.charge = session.config.prism_charge_max
	session.step()
	_advance_until_zone(session)
	await _wait(0.25)
	await _shot("06_prism")
	session.prism.end()
	session.energy = 30
	await _wait(0.2)
	await _shot("07_energia_critica")
	gm.progression.profile.settings.color_symbols = false
	gm.progression.profile.settings.reduce_effects = true
	screen.arena.show_symbols = false
	screen.arena.reduce_effects = true
	await _wait(0.1)
	await _shot("08_sin_simbolos_reducir_efectos")
	screen.arena.show_symbols = true
	screen.arena.reduce_effects = false
	screen.request_pause()
	await _wait(0.3)
	await _shot("09_pausa")
	gm._close_overlays()
	var stats := SessionStats.new()
	stats.score = 21730
	stats.duration = 74.4
	stats.hits = 81
	stats.color_errors = 2
	stats.omissions = 1
	stats.best_combo = 34
	stats.prism_activations = 2
	stats.crystal_orbs = 2
	stats.crystals_from_orbs = 6
	stats.end_state = GameSession.State.GAME_OVER
	gm.progression.profile.missions[0].progress = 0
	var rewards: ProgressionSystem.SessionRewards = gm.progression.apply_session(stats)
	gm.show_results(stats, rewards, 0)
	await _wait(1.0)
	await _shot("10_resultados_record")
	gm.show_collection()
	await _wait(0.3)
	await _shot("11_coleccion")
	gm.show_missions()
	await _wait(0.3)
	await _shot("12_misiones")
	gm.show_settings(false)
	await _wait(0.3)
	await _shot("13_ajustes")
	_finish()


func _advance_until_zone(session: GameSession) -> void:
	for i: int in 2000:
		session.step()
		if session.state != GameSession.State.PLAYING:
			return
		var orb: Orb = session.orb_in_zone()
		if orb != null and session.orbs.size() >= 3 and orb.radius < session.config.zone_outer_radius - 0.05:
			return


func _wait(seconds: float) -> void:
	await tree.create_timer(seconds).timeout


func _shot(name: String) -> void:
	await tree.process_frame
	await RenderingServer.frame_post_draw
	var image: Image = tree.root.get_texture().get_image()
	var path: String = ProjectSettings.globalize_path(_out).path_join("%s_%s.png" % [_prefix, name])
	var error: Error = image.save_png(path)
	print("%s %s (%dx%d)" % ["OK" if error == OK else "ERROR", path, image.get_width(), image.get_height()])


func _finish() -> void:
	gm.queue_free()
	GameManager.save_path_override = ""
	tree.quit(0)
