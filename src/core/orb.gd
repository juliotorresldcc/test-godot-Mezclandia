class_name Orb
extends RefCounted
## Datos de un orbe en vuelo (spec §11). Sin nodo propio: la vista lo dibuja.

var id: int
var kind: OrbType.Kind
## Distancia al centro, en unidades R.
var radius: float
## Ángulo en grados [0, 360).
var angle_deg: float
var spawn_time: float
## Objetivo proyectado al aparecer (FR-SEQ-003); se usa para verificar FR-SEQ-005.
var projected_target: int
var entered_zone: bool = false


func _init(orb_id: int, orb_kind: OrbType.Kind, start_radius: float, angle: float, time: float, projected: int) -> void:
	id = orb_id
	kind = orb_kind
	radius = start_radius
	angle_deg = angle
	spawn_time = time
	projected_target = projected


## Dirección unitaria desde el centro hacia el orbe (eje y hacia abajo en pantalla).
func direction() -> Vector2:
	return Vector2.from_angle(deg_to_rad(angle_deg))
