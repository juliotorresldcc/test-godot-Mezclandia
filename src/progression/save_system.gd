class_name SaveSystem
extends RefCounted
## Persistencia local atómica y versionada (FR-SAV-001…006, ADR 0007).

const DEFAULT_PATH: String = "user://profile.json"


class LoadResult:
	var profile: Profile
	## true si el guardado existía pero no se pudo usar (se hizo copia de seguridad).
	var recovered_from_error: bool = false
	var backup_path: String = ""


var path: String
## Gancho de prueba: falla tras escribir el temporal y antes de sustituir el principal.
var fail_before_replace_for_test: bool = false
var _config: GameConfig


func _init(game_config: GameConfig, save_path: String = DEFAULT_PATH) -> void:
	_config = game_config
	path = save_path


func load_profile(new_seed: int) -> LoadResult:
	var result := LoadResult.new()
	if not FileAccess.file_exists(path):
		result.profile = Profile.create_new(new_seed, _config)
		return result
	var profile: Profile = _read(FileAccess.get_file_as_string(path))
	if profile == null:
		result.recovered_from_error = true
		result.backup_path = _backup()
		push_warning("SaveSystem: guardado ilegible; copia en %s y perfil nuevo." % result.backup_path)
		profile = Profile.create_new(new_seed, _config)
	result.profile = profile
	return result


## Escritura atómica: temporal completo y renombrado. Devuelve false si falla.
func save(profile: Profile) -> bool:
	var temp_path: String = path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: no se pudo abrir %s (%s)" % [temp_path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(JSON.stringify(profile.to_dict(), "\t"))
	file.close()
	if fail_before_replace_for_test:
		return false
	var error: Error = DirAccess.rename_absolute(temp_path, path)
	if error != OK:
		push_warning("SaveSystem: no se pudo sustituir el guardado (%s)" % error_string(error))
		return false
	return true


func _read(text: String) -> Profile:
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		return null
	var version: Variant = data.get("schema_version")
	if not (version is float or version is int) or int(version) < 1 or int(version) > Profile.SCHEMA_VERSION:
		return null
	data = _migrate(data, int(version))
	return Profile.from_dict(data, _config)


## Migraciones en orden desde la versión leída hasta la actual. v1 es la primera versión.
func _migrate(data: Dictionary, _from_version: int) -> Dictionary:
	return data


func _backup() -> String:
	var backup_path: String = path.get_basename() + ".corrupt-%d.json" % int(Time.get_unix_time_from_system())
	var error: Error = DirAccess.copy_absolute(path, backup_path)
	if error != OK:
		push_warning("SaveSystem: no se pudo copiar la copia de seguridad (%s)" % error_string(error))
	return backup_path
