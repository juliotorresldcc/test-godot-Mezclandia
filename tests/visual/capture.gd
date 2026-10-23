extends SceneTree
## Capturas reales para la revisión visual (art-direction §9, T20).
## Uso: xvfb-run -s "-screen 0 1600x2600x24" godot --path . --rendering-driver opengl3 \
##        --resolution 1080x1920 --audio-driver Dummy --script res://tests/visual/capture.gd -- <dir> [prefijo] [full|partial]
## El director se carga en tiempo de ejecución: este script se compila antes de que existan los autoloads.

var _director: RefCounted


func _initialize() -> void:
	_director = (load("res://tests/visual/capture_director.gd") as GDScript).new()
	_director.call_deferred("start", self)
