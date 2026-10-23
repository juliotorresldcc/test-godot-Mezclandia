# Tareas: PRISM POP v1

- **Versión:** 1.0.0 · **Fecha:** 2026-10-23 · **Base:** `spec.md` 0.2.0, `plan.md` 1.0.0, `design.md` 1.0.0
- **Definición de terminado (común a todas):** código tipado sin advertencias nuevas en la validación headless; pruebas de la tarea añadidas y superadas con salida registrada en `test-report.md`; documentación afectada actualizada; sin valores mágicos (parámetros en `GameConfig`).
- **Estado:** ☐ pendiente · ◐ en curso · ☑ terminada con evidencia · ⊘ bloqueada (motivo).

| ID | Requisitos | Objetivo | Archivos | Depende de | Criterios de aceptación | Pruebas |
|----|-----------|----------|----------|-----------|--------------------------|---------|
| T01 | NFR-PLAT-002, plan §2 | Crear el proyecto Godot: `project.godot` (Compatibility, 1080×1920 vertical, `canvas_items`/`expand`, 60 ticks, `untyped_declaration` = error, sin salida con Atrás), `scenes/main.tscn`, estructura de carpetas, fuentes OFL con licencias | `project.godot`, `scenes/main.tscn`, `assets/fonts/*` | — | `godot --headless --import` termina sin errores | Validación headless |
| T02 | NFR-MNT-001, FR-FAIR-005, parameters §2–§4 | `GameConfig` con todos los parámetros y `validate()` (C1–C12); `tools/check_sync.py` compara con `parameters.md` | `src/config/game_config.gd`, `tools/check_sync.py` | T01 | Configuración por defecto válida; cada restricción detecta su violación; `check_sync.py` sin diferencias | TEST-CFG-01/02, `check_sync.py` |
| T03 | plan §5 | Ejecutor de pruebas headless con código de salida | `tests/run_tests.gd`, `tests/test_case.gd` | T01 | Un fallo provoca código de salida 1 | Ejecución con prueba fallida de control |
| T04 | FR-DIF-001…003, FR-SCO-001…004, FR-CMB-002, FR-STAT-002 | Funciones de dificultad y puntuación | `src/core/difficulty.gd`, `src/core/score_rules.gd` | T02, T03 | Valores exactos de las tablas de la spec | TEST-DIF-01/02, TEST-SCO-01…03 |
| T05 | FR-COL-001/002, FR-SEQ-001…003 | Secuencia de objetivos con proyección | `src/core/orb_type.gd`, `src/core/target_sequence.gd` | T04 | Sin repeticiones; sin violeta antes de 20 s; ejemplo de FR-SEQ-003 | TEST-SEQ-01…04 |
| T06 | FR-CMB-001/003 | Implementar las transiciones `COMBO_IDLE → ACTIVE → BROKEN → IDLE/ACTIVE` | `src/core/combo_tracker.gd` | T04 | Cada transición de FR-CMB-001 | TEST-CMB-01…05 |
| T07 | FR-PRM-001…006 | Carga, activación automática, aviso y fin de PRISM | `src/core/prism_controller.gd` | T02 | Ejemplos de FR-PRM-001; activación a 100; fin a 6 s | TEST-PRM-01…05 |
| T08 | FR-ORB-001…005, FR-SEQ-004, FR-EVT-001/002, FR-FAIR-002 | Generador de orbes (tiempo, ángulo, tipo, cristal, racha) | `src/core/orb.gd`, `src/core/orb_spawner.gd` | T05, T07 | Primera aparición en t=0; separación ≥ 40°; racha ≤ 3; condiciones del cristal | TEST-SPN-01…04 |
| T09 | FR-ARENA-*, FR-GS-*, FR-SIM-*, FR-RES-*, FR-ENE-*, FR-INP-002…005, FR-STAT-001, FR-SEQ-005, FR-FAIR-001/003/004, FR-CORE-001/003, NFR-MNT-002 | `GameSession`: estados, paso de simulación, resolución, energía, fin, estadísticas, señales | `src/core/game_session.gd`, `src/core/session_stats.gd` | T06, T07, T08 | Todas las filas de FR-GS-002 y FR-RES-001; determinismo | TEST-GS-*, TEST-RES-*, TEST-INP-*, TEST-ENE-*, TEST-SIM-01, TEST-FAIR-01 |
| T10 | SC-001, SC-002, E17, parameters §7 | Bots y simulaciones masivas | `tests/sim/bots.gd`, `tests/sim/run_sim.gd` | T09 | Medianas de SC-001; 0 violaciones en 10 000 partidas; SPAM < NOVATO | SIM-SC001, SIM-SC002, SIM-E17 |
| T11 | FR-PRG-*, FR-MIS-*, FR-STAT-010, FR-SCO-004, FR-GS-006 | Perfil, catálogos y `ProgressionSystem` | `src/progression/*.gd` | T09 | Ejemplo de FR-PRG-001; compra exacta; misiones únicas; abandono sin efectos | TEST-PRG-*, TEST-MIS-* |
| T12 | FR-SAV-001…006, NFR-SEC-001, SC-006 | `SaveSystem` atómico con versiones y recuperación | `src/progression/save_system.gd` | T11 | Ida y vuelta; corrupto; versión futura; fuera de rango; escritura interrumpida | TEST-SAV-01…06 |
| T13 | FR-UX-004, ART-001…004, ART-010…026, ART-070, NFR-A11Y-001/002/004/005 | Textos en tabla de traducción, paleta, `Layout` (dp, área segura, arena), `Theme` | `src/i18n/strings_es.gd`, `src/ui/palette.gd`, `src/ui/layout.gd`, `src/ui/theme_factory.gd` | T01 | Paleta igual a ART-001 (`check_sync.py`); claves de texto completas; tamaños mínimos | TEST-STR-01, TEST-LAY-01, `check_sync.py` |
| T14 | FR-AUD-001…005 | Generar audio y `AudioManager` | `tools/gen_audio.py`, `assets/audio/*.wav`, `src/services/audio_manager.gd` | T01 | Todos los identificadores con archivo; funciona con `--audio-driver Dummy` | TEST-AUD-01/02 |
| T15 | FR-HAP-001…003 | `Haptics` con detección de plataforma | `src/services/haptics.gd` | T01 | En Linux: no disponible y sin llamadas | TEST-HAP-01 |
| T16 | FR-CORE-002/003, FR-ART-002/003, ART-002, ART-011…016, ART-030…044, ART-050…053, ART-060, NFR-A11Y-003/007 | `ArenaView` (dibujo, partículas, destellos, cosméticos) | `src/view/*.gd` | T09, T13 | Limitador ≤ 3 destellos/s; ≤ 300 partículas | TEST-VIS-01/02, capturas |
| T17 | FR-UX-030…040, FR-INP-001/006, NFR-PLAT-003, FR-HAP-001 | Pantalla de partida: HUD, entrada, pausa, cuenta atrás | `src/ui/screens/game_screen.gd`, `src/ui/screens/pause_overlay.gd` | T14, T15, T16 | El botón Pausa no genera pulso; foco perdido → pausa | TEST-UI-01, TEST-INP-04 |
| T18 | FR-UX-001…081, FR-STAT-011, FR-RG-001/002, FR-SAV-005 | `GameManager` y pantallas restantes, diálogos y avisos | `src/ui/main.gd`, `src/ui/screens/*.gd`, `src/ui/widgets/*.gd` | T11, T12, T17 | Cada fila de FR-UX-001 | TEST-UI-01/02 |
| T19 | SC-005, FR-FAIR-006, SC-007 | Pruebas de flujo de interfaz, disposición y referencias | `tests/unit/test_ui_flow.gd`, `tests/unit/test_layout.gd`, `tests/unit/test_resources.gd` | T18 | 100 % de botones; ninguna invasión de la arena en 5 resoluciones; 0 referencias rotas | TEST-UI-*, TEST-LAY-*, TEST-RSC-01 |
| T20 | FR-ART-001, NFR-A11Y-006, SC-004, art-direction §9 | Capturas reales con Xvfb y revisión visual | `tests/visual/capture.gd`, `docs/visual/*.png`, `specs/001-prism-pop/visual-review.md` | T18 | Capturas de todos los estados de §9; lista objetiva completada | Revisión registrada |
| T21 | NFR-PLAT-001, NFR-PRIV-001 | Preset de exportación Android e instrucciones | `export_presets.cfg`, `docs/export-android.md` | T18 | Preset válido para el editor; APK ⊘ sin SDK | Validación del preset (si es posible) |
| T23 | NFR-PERF-001…005, SC-003 | Escenario de estrés con medición de tiempos de fotograma y memoria en el entorno (indicativo) y procedimiento para dispositivo | `tests/perf/stress.gd`, `docs/perf-device.md` | T17 | Medición registrada; verificación en dispositivo ⊘ (sin dispositivo) | PERF-01 |
| T22 | Todos | Matriz de trazabilidad, informe de pruebas, convergencia | `traceability.md`, `test-report.md` | T01…T21, T23 | Cada requisito con prueba y evidencia o excepción documentada | `tools/trace_check.py` |

## Estado de las tareas (2026-10-23)

| Tarea | Estado | Evidencia |
|-------|--------|-----------|
| T01 | ☑ | Importación headless sin errores |
| T02 | ☑ | TEST-CFG-01/02; `check_sync.py` APROBADO |
| T03 | ☑ | Prueba de control: código de salida 1 ante un fallo y ante un error de script |
| T04–T09 | ☑ | test-report §1 (TEST-DIF/SCO/SEQ/CMB/PRM/SPN/GS/RES/INP/ENE/SIM/FAIR) |
| T10 | ☑ | test-report §2 (1 000 partidas por bot; 14 000 con invariantes) |
| T11–T12 | ☑ | TEST-PRG/MIS/SAV |
| T13 | ☑ | TEST-STR-01, TEST-LAY-01/02, `check_sync.py`; CR-001 aplicado |
| T14–T15 | ☑ | TEST-AUD-01…03, TEST-HAP-01 (la escucha y la vibración reales quedan pendientes de dispositivo) |
| T16–T18 | ☑ | TEST-UI-01…09, TEST-VIS-01/02; capturas reales |
| T19 | ☑ | TEST-UI-*, TEST-LAY-03, TEST-RSC-01 |
| T20 | ◐ | Capturas y lista objetiva hechas (`visual-review.md`); rúbrica del propietario y SC-004 pendientes |
| T21 | ◐ | APK de depuración generado y verificado (`docs/export-android.md` §1 bis); instalación en dispositivo y build de release pendientes |
| T22 | ☑ | `traceability.md`, `test-report.md`; `trace_check.py --tests` APROBADO |
| T23 | ◐ | Medición indicativa registrada; verificación en dispositivo pendiente (`docs/perf-device.md`) |
