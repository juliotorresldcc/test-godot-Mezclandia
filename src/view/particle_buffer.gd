class_name ParticleBuffer
extends RefCounted
## Partículas en búfer fijo, sin asignaciones durante la partida (ART-051, NFR-PERF-004).

const CAPACITY: int = 300

var count: int = 0
var _position := PackedVector2Array()
var _velocity := PackedVector2Array()
var _life := PackedFloat32Array()
var _max_life := PackedFloat32Array()
var _size := PackedFloat32Array()
var _color := PackedColorArray()


func _init() -> void:
	_position.resize(CAPACITY)
	_velocity.resize(CAPACITY)
	_life.resize(CAPACITY)
	_max_life.resize(CAPACITY)
	_size.resize(CAPACITY)
	_color.resize(CAPACITY)


## Emite hasta «amount» partículas; se recorta si el presupuesto se agotaría. Devuelve las emitidas.
func emit(amount: int, origin: Vector2, color: Color, speed: float, life: float, particle_size: float, rng: RandomNumberGenerator) -> int:
	var emitted: int = mini(amount, CAPACITY - count)
	for i: int in emitted:
		var angle: float = TAU * i / maxf(emitted, 1) + rng.randf_range(-0.3, 0.3)
		_position[count] = origin
		_velocity[count] = Vector2.from_angle(angle) * speed * rng.randf_range(0.6, 1.0)
		_life[count] = life
		_max_life[count] = life
		_size[count] = particle_size
		_color[count] = color
		count += 1
	return emitted


func update(delta: float) -> void:
	var i: int = 0
	while i < count:
		_life[i] -= delta
		if _life[i] <= 0.0:
			count -= 1
			_position[i] = _position[count]
			_velocity[i] = _velocity[count]
			_life[i] = _life[count]
			_max_life[i] = _max_life[count]
			_size[i] = _size[count]
			_color[i] = _color[count]
			continue
		_position[i] += _velocity[i] * delta
		_velocity[i] *= 0.92
		i += 1


func draw(canvas: CanvasItem) -> void:
	for i: int in count:
		var ratio: float = _life[i] / _max_life[i]
		canvas.draw_circle(_position[i], _size[i] * (0.4 + 0.6 * ratio), Color(_color[i], ratio))


func clear() -> void:
	count = 0
