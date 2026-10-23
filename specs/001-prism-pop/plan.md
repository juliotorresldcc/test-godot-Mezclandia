# Plan técnico: PRISM POP v1

- **Versión:** 1.0.0 · **Fecha:** 2026-10-23 · **Base:** `spec.md` 0.2.0 (aprobada)
- ADR: `docs/adr/`. Diseño de componentes: `design.md`. Tareas: `tasks.md`.

## 1. Entorno verificado

| Elemento | Valor | Evidencia |
|----------|-------|-----------|
| Motor | Godot **4.7.2-stable** oficial, commit `ed1daf0bf` | `godot --version` → `4.7.2.stable.official.ed1daf0bf` (2026-10-23) |
| SHA-256 del binario Linux | `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e` | `sha256sum` |
| Java | OpenJDK 21.0.12 | `java -version` |
| Renderizado de capturas | Xvfb + OpenGL por software (llvmpipe) | `/usr/bin/xvfb-run` |
| SDK de Android | **No disponible**: `dl.google.com` bloqueado por la política de red | `curl` → `CONNECT tunnel failed, response 403` |
| Fuentes | Orbitron y Exo 2 (OFL-1.1) de `@fontsource/*` 5.3.0 vía npm | `npm pack` |

## 2. Decisiones técnicas

| Tema | Decisión | Justificación / consecuencias | ADR |
|------|----------|-------------------------------|-----|
| Lenguaje | GDScript con tipado estático; advertencias de tipos no declarados como error en el proyecto | Sin dependencias externas; exportación móvil nativa. C# descartado (exportación móvil limitada). | 0001 |
| Renderizador | **Compatibility** (OpenGL ES 3 / GL 3.3) | Máxima compatibilidad Android (incluidos dispositivos sin Vulkan); funciona con llvmpipe para capturas. Sin efectos de posprocesado 3D: el brillo se consigue con capas aditivas 2D. | 0002 |
| Arquitectura | Núcleo de reglas en clases `RefCounted` puras (sin nodos), presentación en nodos | Permite pruebas unitarias y simulaciones masivas headless (NFR-MNT-002, SC-001/002). | 0003 |
| Simulación | Paso fijo en `_physics_process` con `physics_ticks_per_second = 1 / sim_step` (60); `t = pasos · sim_step` (entero de pasos, sin acumulación de error) | Determinismo FR-SIM-002. | 0003 |
| Aleatoriedad | Un `RandomNumberGenerator` por partida con semilla; otro por perfil para misiones (estado guardado como texto, porque es de 64 bits) | Reproducibilidad. | 0003 |
| Parámetros | `GameConfig` (`Resource`) con los valores por defecto de `parameters.md` como fuente en código; `tools/check_sync.py` verifica que coinciden con `parameters.md` | Una fuente de verdad documental y una comprobación automática de la copia en código. | 0004 |
| Interfaz | Construida por código (no `.tscn` complejos), con un `Theme` generado; textos en una tabla de traducción cargada en `TranslationServer` (locale `es`) | Escenas de texto a mano son frágiles; el código tipado es revisable y comprobable. | 0005 |
| Arte | Procedimental: dibujo 2D (`_draw`), capa aditiva (`CanvasItemMaterial` ADD) para halos, texturas de gradiente radial generadas en tiempo de ejecución, partículas propias en un búfer fijo de 300 | D-04 A; presupuesto ART-051 garantizado por construcción. | 0002 |
| Audio | WAV generados por `tools/gen_audio.py` (síntesis con la biblioteca estándar de Python, reproducible) y versionados en `assets/audio/`; buses `Music` y `SFX` creados al iniciar; bucles configurados por código | D-04 A; sin licencias de terceros. | 0006 |
| Entrada | Pulsos desde `InputEventScreenTouch` (cualquier dedo) y `InputEventMouseButton` no emulado (escritorio); se ignoran los eventos de ratón emulados desde táctil; se excluye el rectángulo del botón Pausa | FR-INP-001; evita pulsos duplicados por la emulación de ratón. | 0005 |
| Resolución | Base 1080×1920 vertical, `stretch_mode = canvas_items`, `aspect = expand`; disposición calculada por `Layout` en unidades dp (`W/411`) y con área segura | ART-010…026, NFR-PLAT-002. | 0005 |
| Persistencia | JSON en `user://profile.json`, escritura en `profile.json.tmp` y renombrado; versión de esquema 1; copia de seguridad `profile.corrupt-<unix>.json` | FR-SAV-*. | 0007 |
| Pruebas | Ejecutor propio en GDScript (`tests/run_tests.gd`, `SceneTree`), sin complementos de terceros; simulaciones en `tests/sim/run_sim.gd`; capturas en `tests/visual/` con Xvfb | Sin dependencias; ejecutable headless en CI. | 0008 |
| Exportación | Android (`export_presets.cfg`), arm64-v8a + armeabi-v7a, permiso `VIBRATE`, orientación vertical. Exportación **no ejecutable en este entorno** (sin SDK de Android). | NFR-PLAT-001. | 0009 |

## 3. Escenas y sistemas

```
scenes/main.tscn  (Control raíz con main.gd = GameManager)
 ├─ Background (gradiente + estrellas)
 ├─ ScreenHost (pantalla actual: Splash, MainMenu, Game, Results, Collection, Missions, Settings)
 ├─ OverlayHost (Pausa, diálogos, avisos)
autoloads: AudioManager, Haptics
```

Ciclo de vida: `GameManager` crea y destruye pantallas al navegar; la pantalla Game posee la `GameSession` y la `ArenaView`; al terminar la partida, `GameManager` aplica el resultado con `ProgressionSystem`, guarda con `SaveSystem` y después muestra Resultados (FR-UX-051).

## 4. Objetivos de rendimiento y memoria

- Sin asignaciones por orbe o partícula en el bucle: orbes en un `Array[Orb]` pequeño (≤ 6), partículas en `PackedFloat32Array` y `PackedColorArray` preasignados (NFR-PERF-004).
- Dibujo: un `queue_redraw()` por fotograma en dos capas; ≈ 30 llamadas de dibujo por orbe como máximo.
- Medición en el entorno: tiempo de proceso por fotograma en un escenario de estrés bajo Xvfb (indicativo, **no sustituye** al dispositivo de referencia; NFR-PERF-001 queda pendiente de dispositivo).

## 5. Estrategia de pruebas

| Nivel | Herramienta | Requisitos |
|-------|-------------|-----------|
| Documentos | `tools/spec_lint.py`, `tools/palette_check.py`, `tools/check_sync.py` | Coherencia, ART-003/004, NFR-MNT-001 |
| Unitarias | `tests/run_tests.gd` (headless, `--audio-driver Dummy`) | Reglas §3, progresión §7, guardado, cadenas, referencias |
| Integración de interfaz | `tests/unit/test_ui_flow.gd` instancia `main.tscn` y pulsa cada botón | §4, SC-005 |
| Simulación | `tests/sim/run_sim.gd` | SC-001, SC-002, E17 |
| Visual | `tests/visual/capture.gd` bajo Xvfb → `docs/visual/` | art-direction §9 |
| Dispositivo | Manual (propietario) | NFR-PERF, FR-HAP, SC-004 |

## 6. Ejecución y exportación

Ver `README.md` §Ejecución (comandos exactos). Exportación Android: requiere Android SDK (build-tools, platform-tools), plantillas de exportación 4.7.2 y un keystore; pasos en `docs/export-android.md`.

## 7. Limitaciones conocidas

- Exportación Android y pruebas en dispositivo no ejecutables en este entorno (R-02).
- La música sintetizada es sencilla (R-05).
- El determinismo se garantiza en la misma plataforma y compilación (R-07).
