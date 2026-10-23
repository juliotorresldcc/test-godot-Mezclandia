# Verificación en dispositivo (pendiente: no ejecutable en el entorno de desarrollo)

Procedimiento para el propietario. Registra los resultados en `specs/001-prism-pop/test-report.md` §5.

## 1. Dispositivo de referencia (M-08)

Android de gama media de 2021: 4 GB de RAM, GPU de clase Adreno 610 / Mali-G52.

## 2. Rendimiento (NFR-PERF-001…005, SC-003)

1. Exporta una compilación de depuración (`docs/export-android.md`) e instálala.
2. Escenario de estrés: juega hasta el modo PRISM con dificultad máxima (t ≥ 60 s). Activa el monitor de rendimiento de Godot por depuración remota (*Debugger → Monitors*: `Time/FPS`, `Time/Process`) o usa `adb shell dumpsys gfxinfo`.
3. Criterios: p95 del tiempo de fotograma ≤ 16,7 ms y ningún fotograma > 33,3 ms tras los 2 primeros segundos; arranque en frío hasta el menú ≤ 3 s (cronómetro); memoria residente ≤ 300 MB (`adb shell dumpsys meminfo com.prismpop.game`); tamaño del APK ≤ 80 MB.
4. Referencia indicativa medida en el contenedor (sin GPU): coste de CPU de scripts y dibujo p95 ≈ 1 ms por fotograma (`tests/perf/stress.gd` en headless).

## 3. Vibración (FR-HAP-001)

Con «Vibración» activada: un acierto vibra 15 ms, un error 50 ms y la activación de PRISM 80 ms. Con el ajuste desactivado no debe vibrar nada.

## 4. Pruebas con jugadores (SC-004, SC-001 manual, NFR-A11Y-006, R-01, R-08)

- Al menos 5 jugadores nuevos, sin explicación previa. Mide: aciertos en la primera partida (SC-004: ≥ 80 % con ≥ 5 aciertos), duración de las 5 primeras partidas (objetivo 30–90 s) y si juegan con una sola mano.
- Recalibra las tasas de error de los bots (parameters §7) con los datos obtenidos.

## 5. Revisión visual y sonora en movimiento

Completa la rúbrica de `specs/001-prism-pop/visual-review.md` §4 y revisa VR-01…VR-04. Escucha la entrada de la capa de intensidad (t ≥ 30 s) y de la capa PRISM.
