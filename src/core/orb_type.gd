class_name OrbType
extends RefCounted
## Tipos de orbe (FR-COL-001). CRYSTAL es el evento especial (FR-EVT-001) y nunca es objetivo.

enum Kind { CYAN, MAGENTA, YELLOW, VIOLET, CRYSTAL }

## Colores activos desde el inicio; VIOLET se añade en fourth_color_time (FR-COL-002).
const BASE_COLORS: Array[Kind] = [Kind.CYAN, Kind.MAGENTA, Kind.YELLOW]
const ALL_COLORS: Array[Kind] = [Kind.CYAN, Kind.MAGENTA, Kind.YELLOW, Kind.VIOLET]


static func is_color(kind: int) -> bool:
	return kind != Kind.CRYSTAL


## Clave de traducción del nombre del tipo.
static func name_key(kind: int) -> String:
	return ["ORB_CYAN", "ORB_MAGENTA", "ORB_YELLOW", "ORB_VIOLET", "ORB_CRYSTAL"][kind]
