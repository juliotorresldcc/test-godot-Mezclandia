extends RefCounted
## Director del escenario de estrés: PRISM activo, máximo de orbes y presupuesto de partículas lleno.

const FRAMES: int = 300
const WARMUP_FRAMES: int = 60

var tree: SceneTree


func start(scene_tree: SceneTree) -> void:
	tree = scene_tree
	# El modo headless duerme 6.9 ms por fotograma (low_processor_mode); se desactiva para medir CPU real.
	OS.low_processor_usage_mode = false
	OS.low_processor_usage_mode_sleep_usec = 0
	GameManager.save_path_override = "user://perf/profile.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://perf"))
	var gm: GameManager = (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	gm.instant_transitions = true
	tree.root.add_child(gm)
	await tree.process_frame
	gm.start_game()
	await tree.process_frame
	var screen: GameScreen = gm.current_screen as GameScreen
	var session: GameSession = screen.session
	session.start()
	session.steps = int(70.0 / session.config.sim_step)
	session.fourth_color_active = true
	var frame_ms: Array[float] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var last: int = Time.get_ticks_usec()
	for frame: int in WARMUP_FRAMES + FRAMES:
		# Mantiene PRISM activo, energía y el máximo de orbes en vuelo.
		session.energy = session.config.energy_max
		if not session.prism.active:
			session.prism.charge = session.config.prism_charge_max
		while session.orbs.size() < session.config.max_orbs_in_flight:
			var orb: Orb = session.inject_orb(OrbType.ALL_COLORS[rng.randi_range(0, 3)], rng.randf_range(0.4, 1.0))
			orb.angle_deg = rng.randf() * 360.0
		screen.arena._emit(12, Vector2.ZERO, Palette.ORB_CYAN, 0.6, 0.35)
		await tree.process_frame
		var now: int = Time.get_ticks_usec()
		if frame >= WARMUP_FRAMES:
			frame_ms.append((now - last) / 1000.0)
		last = now
	frame_ms.sort()
	print("PERF frames=%d partículas=%d orbes=%d" % [FRAMES, screen.arena.particle_count(), session.orbs.size()])
	# Con --headless no hay renderizado: el tiempo de pared es el coste de CPU (scripts + registro de dibujo).
	# Con Xvfb incluye el renderizado por software (llvmpipe), mucho más lento que una GPU real.
	print("PERF modo=%s tiempo de fotograma: p50=%.2f ms p95=%.2f ms máx=%.2f ms" % [DisplayServer.get_name(), frame_ms[FRAMES / 2], frame_ms[FRAMES * 95 / 100], frame_ms.back()])
	print("PERF memoria estática: %.1f MB; objetos: %d; nodos: %d" % [Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, Performance.get_monitor(Performance.OBJECT_COUNT), Performance.get_monitor(Performance.OBJECT_NODE_COUNT)])
	gm.queue_free()
	GameManager.save_path_override = ""
	tree.quit(0)
