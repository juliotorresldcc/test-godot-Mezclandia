# Diseño de componentes: PRISM POP v1

- **Versión:** 1.0.0 · **Fecha:** 2026-10-23 · **Base:** `spec.md` 0.2.0, `plan.md` 1.0.0

## 1. Correspondencia con la lista del mandato

| Componente del mandato | Implementación | Motivo del cambio |
|------------------------|----------------|-------------------|
| GameManager | `GameManager` (`src/ui/main.gd`) | — |
| GameSession | `GameSession` (`src/core/game_session.gd`) | Orquesta el paso de simulación (FR-SIM-001). |
| CoreController | **Combinado:** lógica del objetivo en `TargetSequence`; aspecto en `ArenaView` | El núcleo no tiene lógica propia más allá del objetivo. |
| OrbSpawner | `OrbSpawner` | — |
| Orb | `Orb` (datos) | Sin nodo por orbe: la vista los dibuja (NFR-PERF-004). |
| ComboSystem | `ComboTracker` | — |
| ScoreSystem | `ScoreRules` (funciones estáticas) | Sin estado propio: la puntuación vive en `GameSession`. |
| DifficultyController | `Difficulty` (funciones estáticas de `t`) | Sin estado: la dificultad es función pura del tiempo. |
| PrismModeController | `PrismController` | — |
| ProgressionSystem | `ProgressionSystem` + `CosmeticsCatalog` + `MissionCatalog` + `Profile` | Catálogos separados de las reglas. |
| SaveSystem | `SaveSystem` | — |
| AudioManager | `AudioManager` (autoload) | — |
| HapticsService | `Haptics` (autoload) | — |
| UIController | **Dividido:** `GameManager` (navegación) + una clase por pantalla + `ArenaView` | Una responsabilidad por pantalla. |
| *(nuevo)* GameConfig | `GameConfig` | NFR-MNT-001. |
| *(nuevo)* Layout, Palette, Strings | Utilidades de presentación | ART-010…026, FR-UX-004. |

**Fuente única de cada dato de partida:** `GameSession` posee `t`, `E`, `c` (vía `ComboTracker`), `Q` (vía `PrismController`), puntuación, `seq/idx` (vía `TargetSequence`) y los orbes. La vista y el HUD solo leen o reciben señales; nunca guardan copias que puedan divergir (los valores mostrados se leen en cada fotograma o al recibir la señal).

## 2. Contratos

### 2.1 GameConfig (`Resource`)
1. **Responsabilidad:** contener todos los parámetros de `parameters.md` y validarlos.
2. **Entradas:** valores por defecto; modificaciones en pruebas.
3. **Salidas:** propiedades tipadas; `validate() -> PackedStringArray` (lista de errores C1–C12, vacía si es válida).
4. **Señales:** ninguna. 5. **Estado:** los parámetros.
6. **Dependencias:** ninguna.
7. **Errores:** configuración inválida → lista no vacía; `GameSession` se niega a iniciar (FR-FAIR-005) con `push_error`.
8. **Inicio/fin:** inmutable durante una partida.
9. **Pruebas:** TEST-CFG-01 (por defecto válida), TEST-CFG-02 (cada restricción detecta su violación), `check_sync.py`.

### 2.2 Difficulty / ScoreRules (estáticas)
1. Fórmulas FR-DIF-001/002 y FR-SCO-001/002, FR-CMB-002, FR-STAT-002.
2. `t`, `c`, `prism_active`, `config`. 3. Valores numéricos. 4–5. Sin señales ni estado. 6. `GameConfig`. 7. `t < 0` → se trata como 0.
9. TEST-DIF-01/02, TEST-SCO-01/02/03.

### 2.3 TargetSequence
1. Secuencia perezosa `seq`, índice `idx`, regla de avance y proyección (FR-SEQ-001…003).
2. `rng`, colores activos en el momento de generar, orbes consumidos. 3. `current()`, `next()`, `projected(orbs_in_flight)`, `on_consumed(type) -> bool` (avanzó).
4–5. Sin señales; estado `seq`, `idx`. 6. RNG de la partida.
9. TEST-SEQ-01 (sin repeticiones consecutivas, 100 000), TEST-SEQ-02 (sin violeta antes de 20 s), TEST-SEQ-03 (ejemplo de proyección), TEST-SEQ-04 (avance).

### 2.4 OrbSpawner
1. Cuándo, dónde y de qué tipo aparece cada orbe (FR-ORB-002…005, FR-SEQ-004, FR-EVT-002).
2. `t`, orbes en vuelo, proyección, PRISM activo, RNG. 3. `Orb` nuevo o nada en cada paso.
5. Estado: instante de la última aparición, último ángulo, racha no objetivo, cristales aparecidos, instante del último cristal.
7. Límite de orbes alcanzado → retraso + `push_warning` (FR-ORB-004).
9. TEST-SPN-01 (primera aparición en t=0 e intervalo), TEST-SPN-02 (separación angular ≥ 40°), TEST-SPN-03 (racha máxima), TEST-SPN-04 (condiciones del cristal).

### 2.5 ComboTracker
1. Estados `COMBO_IDLE/ACTIVE/BROKEN` (FR-CMB-001), mejor combo.
2. `on_hit()`, `on_error()`, `advance(dt)`. 3. `count`, `state`, `tier`, `best`.
9. TEST-CMB-01…05 (una por transición).

### 2.6 PrismController
1. Carga, activación, aviso y fin de PRISM (FR-PRM-001…006).
2. `on_hit()`, `on_crystal_hit()`, `on_error()`, `advance(dt) -> int` (eventos: aviso/fin), `try_activate() -> bool`.
3. `charge`, `active`, `time_left`, `activations`.
9. TEST-PRM-01…05.

### 2.7 GameSession (`RefCounted`)
1. Estados y transiciones (FR-GS-*), paso de simulación (FR-SIM-001), resolución (FR-RES-001), energía y fin (FR-ENE-*), estadísticas (FR-STAT-001).
2. **Entradas:** `start()`, `request_pulse()`, `step()`, `pause()`, `resume()`, `update_real_time(dt)`, `abandon()`. Ganchos de prueba documentados: `set_spawning_enabled(bool)`, `inject_orb(type, r)`, `debug_checks` (activa aserciones de invariantes).
3. **Salidas (lectura):** `state`, `t`, `energy`, `score`, `combo`, `prism`, `sequence`, `orbs`, `stats`, `seed`, `resume_time_left`.
4. **Señales:** `state_changed(from, to)`, `orb_spawned(orb)`, `orb_resolved(orb, result, points)`, `pulse_empty()`, `combo_changed(count, tier, tier_up)`, `combo_broken(previous)`, `energy_changed(value, critical)`, `prism_charge_changed(value)`, `prism_started()`, `prism_warning()`, `prism_ended()`, `target_changed(current, next)`, `new_color_activated()`, `crystal_collected(amount)`.
5. **Estado:** el de la partida (fuente única, §1).
6. **Dependencias:** `GameConfig`, colaboradores 2.2–2.6.
7. **Errores:** transición no permitida → ignorada + `push_warning` en depuración (FR-GS-002); configuración inválida → no inicia; violación de invariante con `debug_checks` → `push_error` y contador `invariant_violations`.
8. **Inicio:** `PRE_START` al crearse; **fin:** estado terminal; tras él ignora toda entrada.
9. **Pruebas:** TEST-GS-01…10 (transiciones), TEST-RES-01…09 (filas de FR-RES-001), TEST-INP-01…03, TEST-ENE-01…04, TEST-SIM-01 (determinismo), TEST-FAIR-01 (invariantes en 500 partidas), SIM-SC001, SIM-SC002, SIM-E17.

Diagrama de estados (FR-GS-002):
```
PRE_START --toque--> PLAYING --E=0--> GAME_OVER
PRE_START <--reanudar-- PAUSED <--pausa/foco-- PLAYING --t≥max--> COMPLETED
PAUSED --reanudar--> RESUMING --cuenta atrás--> PLAYING
RESUMING --pausa/foco--> PAUSED --reiniciar/salir--> ABANDONED
```

### 2.8 Profile / CosmeticsCatalog / MissionCatalog / ProgressionSystem
1. Datos persistentes (FR-SAV-001) y reglas de progresión §7.
2. Resultado de partida (`SessionStats` + motivo), compras, equipamiento, reclamos, restablecimiento.
3. `SessionRewards` (cristales con desglose, récord nuevo, misiones completadas en esta partida).
4. `ProgressionSystem.changed()`.
5. Estado: el `Profile` (fuente única del progreso).
7. Compra sin saldo → devuelve `false` sin cambios (FR-PRG-012); id desconocido → `false` + `push_warning`.
9. TEST-PRG-01…08, TEST-MIS-01…06.

### 2.9 SaveSystem
1. Leer y escribir `Profile` + ajustes (FR-SAV-*).
2. Ruta (inyectable en pruebas). 3. `load() -> LoadResult` (perfil, `recovered_from_error: bool`), `save(profile) -> bool`.
7. Lectura imposible/versión futura/valores fuera de rango → copia de seguridad + perfil nuevo; escritura fallida → `false` (el llamador muestra FR-SAV-005).
9. TEST-SAV-01…06.

### 2.10 AudioManager / Haptics (autoloads)
1. Sonidos por identificador (FR-AUD-001), música por capas (FR-AUD-002), volúmenes (FR-AUD-003), degradación (FR-AUD-004), límite de voces (FR-AUD-005); vibración (FR-HAP-*).
2. `play(id)`, `play_music(track)`, `set_layer(layer, on)`, `set_music_volume(p)`, `set_sfx_volume(p)`, `set_paused_duck(bool)`; `Haptics.vibrate(kind)`, `Haptics.is_available()`.
7. Archivo inexistente → `push_warning` una vez, el juego continúa.
9. TEST-AUD-01/02, TEST-HAP-01.

### 2.11 GameManager y pantallas
1. Navegación FR-UX-001, Atrás y foco (NFR-PLAT-003), aplicación de resultados antes de Resultados (FR-UX-051), aviso de guardado (FR-SAV-005), recordatorio de descanso (FR-RG-002).
2. Señales de cada pantalla (`play_pressed`, `back_pressed`, …). 3. Pantalla visible.
7. Fallo de carga → diálogo FR-UX-012.
9. TEST-UI-01 (matriz de botones), TEST-UI-02 (Atrás), TEST-LAY-01 (disposición en 5 resoluciones), capturas visuales.

### 2.12 ArenaView
1. Dibujo de fondo de arena, núcleo, zona, orbes, partículas, textos emergentes, indicador SIGUIENTE (ART-011…016, ART-030…044), limitador de destellos (ART-052), reducir efectos (ART-050).
2. `GameSession` (lectura + señales), `Layout`, ajustes, cosméticos equipados.
7. Presupuesto de partículas agotado → se reduce la emisión (ART-051).
9. TEST-VIS-01 (limitador de destellos), TEST-VIS-02 (presupuesto de partículas), capturas.
