extends SceneTree
## Ejecutor de pruebas (ADR 0008).
## Uso: godot --headless --path . --audio-driver Dummy --script res://tests/run_tests.gd [-- filtro]
## Termina con código 1 si alguna prueba falla o si un error de motor/script no esperado ocurre.

const UNIT_DIR: String = "res://tests/unit/"


class ErrorCounter extends Logger:
	var errors: int = 0
	var messages: PackedStringArray = []

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == Logger.ERROR_TYPE_WARNING:
			return
		errors += 1
		messages.append("%s (%s:%d %s) %s" % [code, file, line, function, rationale])


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var counter := ErrorCounter.new()
	OS.add_logger(counter)
	var filter: String = ""
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	if not user_args.is_empty():
		filter = user_args[0]
	var passed: int = 0
	var failed: int = 0
	var files: PackedStringArray = DirAccess.get_files_at(UNIT_DIR)
	files.sort()
	for file_name: String in files:
		if not file_name.begins_with("test_") or not file_name.ends_with(".gd"):
			continue
		var script: GDScript = load(UNIT_DIR + file_name) as GDScript
		if script == null or not script.can_instantiate():
			print("FAIL %s :: no se pudo cargar el script" % file_name)
			failed += 1
			continue
		var methods: Array[String] = []
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if method_name.begins_with("test_") and method_name not in methods:
				methods.append(method_name)
		for method_name: String in methods:
			var test_id: String = "%s::%s" % [file_name.get_basename(), method_name]
			if filter != "" and not test_id.contains(filter):
				continue
			var test: TestCase = script.new()
			test.tree = self
			var errors_before: int = counter.errors
			var messages_before: int = counter.messages.size()
			await test.call(method_name)
			var unexpected: int = counter.errors - errors_before - test.expected_errors
			if unexpected > 0:
				test.failures.append("%d error(es) de motor/script no esperados: %s" % [unexpected, " | ".join(counter.messages.slice(messages_before))])
			elif counter.errors - errors_before < test.expected_errors:
				test.failures.append("se esperaban %d error(es) y hubo %d" % [test.expected_errors, counter.errors - errors_before])
			if test.failures.is_empty():
				passed += 1
				print("PASS %s" % test_id)
			else:
				failed += 1
				print("FAIL %s" % test_id)
				for failure: String in test.failures:
					print("     - %s" % failure)
	print("\nRESULTADO: %d superadas, %d fallidas" % [passed, failed])
	quit(1 if failed > 0 or passed == 0 else 0)
