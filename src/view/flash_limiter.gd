class_name FlashLimiter
extends RefCounted
## Limita los destellos a 3 en cualquier ventana de 1 s (ART-052, NFR-A11Y-003).

const MAX_FLASHES: int = 3
const WINDOW_SECONDS: float = 1.0

var _times: Array[float] = []


## Devuelve true y registra el destello si está permitido en el instante «now» (s).
func try_flash(now: float) -> bool:
	while not _times.is_empty() and now - _times[0] >= WINDOW_SECONDS:
		_times.pop_front()
	if _times.size() >= MAX_FLASHES:
		return false
	_times.append(now)
	return true
