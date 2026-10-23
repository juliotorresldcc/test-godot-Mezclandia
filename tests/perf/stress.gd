extends SceneTree
## Escenario de estrés (NFR-PERF-001/004, T23). Medición INDICATIVA en el entorno disponible;
## no sustituye la medición en el dispositivo de referencia.
## Uso: xvfb-run godot --path . --rendering-driver opengl3 --resolution 1080x1920 --audio-driver Dummy --script res://tests/perf/stress.gd

var _director: RefCounted


func _initialize() -> void:
	_director = (load("res://tests/perf/stress_director.gd") as GDScript).new()
	_director.call_deferred("start", self)
