class_name TestCase
extends RefCounted
## Base de las pruebas (ADR 0008). Cada método «test_*» es una prueba.

var failures: PackedStringArray = []
## Errores de motor/script esperados en la prueba actual (p. ej. push_error deliberado).
var expected_errors: int = 0
var tree: SceneTree


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if typeof(actual) != typeof(expected) and not (actual is float and expected is int) and not (actual is int and expected is float):
		failures.append("%s: tipo %s ≠ %s (%s vs %s)" % [message, type_string(typeof(actual)), type_string(typeof(expected)), actual, expected])
	elif actual != expected:
		failures.append("%s: obtenido %s, esperado %s" % [message, actual, expected])


func check_near(actual: float, expected: float, tolerance: float = 1e-6, message: String = "") -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s: obtenido %.9f, esperado %.9f (±%g)" % [message, actual, expected, tolerance])


## Espera n fotogramas (pruebas de interfaz).
func frames(n: int = 1) -> void:
	for i: int in n:
		await tree.process_frame
