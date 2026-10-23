# Catálogo de parámetros: PRISM POP v1

- **Versión:** 0.1.0 (aprobada el 2026-10-23)
- **Fecha:** 2026-10-23
- **Fuente de verdad de:** todos los valores ajustables del juego. `spec.md` define las reglas usando estos nombres; aquí se definen valores, tipos, unidades y rangos.
- **Estado:** todos los valores son **propuestas `[P]`** salvo indicación. Pendientes de aprobación del propietario y de calibración mediante simulación y pruebas con jugadores.

## 1. Convenciones

- **R:** unidad de distancia de la arena (radio del círculo de aparición).
- **s:** segundos de **tiempo de juego** (no avanza en pausa) salvo que se indique «tiempo real».
- **Rango permitido:** intervalo dentro del cual el valor puede ajustarse sin modificar la especificación (constitución §3.4). Salir del rango es un cambio de especificación.
- **Fijo:** el valor forma parte de la definición del sistema y no es ajustable.
- La implementación debe leer cada parámetro de un único recurso de configuración (NFR-MNT-001) y validar las restricciones de §3 al cargar (FR-FAIR-005).

## 2. Parámetros de juego

### 2.1 Geometría

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto en la jugabilidad | Dependencias |
|-----------|------|--------|---------|-----|-----|--------------------------|--------------|
| `spawn_radius` | float | R | 1.0 | 1.0 | 1.0 | Fijo. Define la unidad R. | — |
| `core_radius` | float | R | 0.12 | 0.08 | 0.16 | Tamaño visual del núcleo. | C1, C2 |
| `zone_inner_radius` | float | R | 0.17 | 0.14 | 0.25 | Radio de impacto y borde interior de la zona. | C1, C2, C5 |
| `zone_outer_radius` | float | R | 0.37 | 0.30 | 0.50 | Borde exterior de la zona. Mayor → ventana de captura más larga (más fácil). | C1, C5 |
| `orb_radius` | float | R | 0.05 | 0.035 | 0.07 | Tamaño de los orbes; legibilidad y área visual. | C2, C5 |
| `orb_min_angle_gap` | float | grados | 40 | 0 | 90 | Separación angular mínima entre orbes consecutivos (claridad visual). | — |
| `max_orbs_in_flight` | int | orbes | 6 | 3 | 12 | Límite de seguridad; no debe alcanzarse con la configuración válida. | C10 |
| `min_radial_gap` | float | R | 0.35 | 0.25 | 0.60 | Separación radial mínima entre orbes consecutivos; garantiza un solo orbe en zona. | C4, C5 |

### 2.2 Simulación

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `sim_step` | float | s | 1/60 | 1/120 | 1/30 | Duración del paso fijo de simulación. Determina la precisión temporal del pulso. | Plan técnico (frecuencia de física) |

### 2.3 Dificultad

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `difficulty_ramp_time` | float | s | 60 | 30 | 120 | Tiempo hasta la dificultad máxima. | SC-001 |
| `orb_speed_min` | float | R/s | 0.35 | 0.20 | 0.60 | Velocidad inicial. | C3, C4 |
| `orb_speed_max` | float | R/s | 0.80 | 0.50 | 1.20 | Velocidad máxima. | C3, C4 |
| `spawn_interval_max` | float | s | 1.10 | 0.60 | 2.00 | Intervalo de aparición inicial. | C3, C4 |
| `spawn_interval_min` | float | s | 0.45 | 0.30 | 1.00 | Intervalo de aparición mínimo. | C3, C4 |
| `target_chance_start` | float | prob. | 0.55 | 0.30 | 0.80 | Probabilidad inicial de orbe objetivo. Mayor → más aciertos posibles, menos señuelos. | C3 |
| `target_chance_end` | float | prob. | 0.40 | 0.25 | 0.70 | Probabilidad final de orbe objetivo. | C3 |
| `pity_max_non_target` | int | orbes | 3 | 1 | 6 | Máximo de orbes de color no objetivo seguidos. | C6 |
| `fourth_color_time` | float | s | 20 | 0 | 60 | Instante de aparición del cuarto color (violeta). | C12 |
| `new_color_notice_duration` | float | s | 1.0 | 0.5 | 2.0 | Duración del aviso «NUEVO COLOR». | — |

### 2.4 Entrada

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `pulse_cooldown` | float | s | 0.15 | 0.05 | 0.30 | Tiempo mínimo entre pulsos. Mayor → castiga más los toques anticipados y el «spam». | Debe ser < ventana en zona mínima (C11) |

### 2.5 Puntuación y combos

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `score_base` | int | puntos | 100 | 10 | 1000 | Puntos por acierto con `m = 1`. | — |
| `combo_step` | int | aciertos | 5 | 1 | 20 | Aciertos por nivel de multiplicador. | — |
| `mult_step` | float | — | 0.5 | 0.1 | 1.0 | Incremento del multiplicador por nivel. | C9 |
| `mult_max` | float | — | 4.0 | 1.0 | 10.0 | Multiplicador máximo. | C9 |
| `prism_score_factor` | float | — | 2.0 | 1.0 | 5.0 | Factor de puntuación en PRISM. | — |
| `combo_broken_feedback` | float | s | 0.5 | 0.2 | 1.0 | Duración del estado `COMBO_BROKEN`. | — |

### 2.6 Energía

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `energy_max` | int | energía | 100 | 100 | 100 | Fijo. | — |
| `energy_start` | int | energía | 100 | 1 | `energy_max` | Energía inicial. | C8 |
| `energy_error_cost` | int | energía | 35 | 10 | 100 | Coste por error. 35 → tres errores sin aciertos terminan la partida. | SC-001 |
| `energy_hit_gain` | int | energía | 1 | 0 | 10 | Recuperación por acierto. | SC-001 |

### 2.7 Modo PRISM

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `prism_charge_max` | int | carga | 100 | 100 | 100 | Fijo. | — |
| `prism_charge_per_hit` | int | carga | 4 | 1 | 20 | 25 aciertos seguidos llenan la carga. | — |
| `prism_charge_per_crystal` | int | carga | 20 | 0 | 100 | Carga por acierto cristal. | — |
| `prism_duration` | float | s | 6.0 | 3.0 | 12.0 | Duración del modo. | C7 |
| `prism_warning_time` | float | s | 1.5 | 0.5 | 3.0 | Aviso previo al fin. | C7 |

### 2.8 Evento especial: orbe cristal

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `crystal_min_time` | float | s | 10 | 0 | 60 | Instante mínimo de aparición. | — |
| `crystal_spawn_chance` | float | prob. | 0.04 | 0.0 | 0.20 | Probabilidad por aparición elegible. | — |
| `crystal_cooldown` | float | s | 8 | 2 | 30 | Separación mínima entre orbes cristal. | — |
| `crystal_max_per_session` | int | orbes | 5 | 0 | 10 | Límite por partida. 0 desactiva el evento. | — |
| `crystal_orb_reward` | int | cristales | 3 | 0 | 20 | Cristales por orbe cristal capturado. | Economía §5 |

### 2.9 Sesión

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto | Dependencias |
|-----------|------|--------|---------|-----|-----|--------|--------------|
| `session_max_time` | float | s | 90 | 60 | 180 | Duración máxima (`COMPLETED`). (D-02 → A) | C12, SC-001 |
| `resume_countdown` | float | s (tiempo real) | 1.5 | 0.0 | 3.0 | Cuenta atrás al reanudar. | — |
| `end_sequence_duration` | float | s (tiempo real) | 1.0 | 0.5 | 2.0 | Animación de fin antes de Resultados. | — |

## 3. Restricciones de validación

La configuración es inválida si falla cualquiera de estas restricciones (FR-FAIR-005). Todas se comprueban en una prueba automática.

| ID | Restricción |
|----|-------------|
| C1 | `core_radius < zone_inner_radius < zone_outer_radius < spawn_radius` |
| C2 | `core_radius + orb_radius ≤ zone_inner_radius` (el impacto ocurre al tocar el núcleo, no después) |
| C3 | `orb_speed_min ≤ orb_speed_max`, `spawn_interval_min ≤ spawn_interval_max`, `target_chance_end ≤ target_chance_start` |
| C4 | `min_{u∈[0,1]} v(u)·Δ(u) ≥ min_radial_gap`. Como `v·Δ` es un polinomio de grado 2 en `u`, basta evaluar `u = 0`, `u = 1` y el vértice si está en (0, 1). |
| C5 | `min_radial_gap > zone_outer_radius − zone_inner_radius` y `min_radial_gap ≥ 2·orb_radius` |
| C6 | `pity_max_non_target ≥ 1` |
| C7 | `prism_warning_time < prism_duration` |
| C8 | `1 ≤ energy_start ≤ energy_max` |
| C9 | `mult_max ≥ 1` y `mult_step > 0` |
| C10 | `max_orbs_in_flight ≥ ceil(max_{u} ((spawn_radius − zone_inner_radius) / v(u)) / Δ(u)) + 1` |
| C11 | `pulse_cooldown < (zone_outer_radius − zone_inner_radius) / orb_speed_max` |
| C12 | `fourth_color_time < session_max_time` |

Comprobación con valores por defecto (calculada con un script de Python de una línea el 2026-10-23; la prueba automática del proyecto deberá repetirla):
- C4: `v·Δ = 0.385 + 0.2675·u − 0.2925·u²` (parábola cóncava). Valores: 0.385 (u=0), 0.360 (u=1); el vértice (u ≈ 0.457, 0.446) es un máximo. Mínimo 0.360 ≥ 0.35 ✓.
- C5: 0.35 > 0.20 ✓; 0.35 ≥ 0.10 ✓.
- C10: tiempo de recorrido / intervalo = 2.37/1.10 = 2.16 (u=0) y 1.04/0.45 = 2.31 (u=1) → `ceil(2.31) + 1 = 4 ≤ 6` ✓.
- C11: 0.15 < 0.20/0.80 = 0.25 ✓.

## 4. Parámetros de presentación, audio, progresión y UX

| Parámetro | Tipo | Unidad | Defecto | Mín | Máx | Efecto |
|-----------|------|--------|---------|-----|-----|--------|
| `splash_min_time` | float | s (real) | 1.0 | 0.0 | 3.0 | Tiempo mínimo de la pantalla de Inicio. |
| `onboarding_sessions` | int | partidas | 3 | 0 | 10 | Partidas con indicación de aprendizaje (M-05). |
| `break_reminder_interval` | int | minutos | 30 | 15 | 120 | Intervalo del recordatorio de descanso (M-06). |
| `pause_music_duck_db` | float | dB | −12 | −40 | 0 | Atenuación de la música en pausa. |
| `sfx_max_voices` | int | voces | 12 | 4 | 32 | Sonidos simultáneos. |
| `haptic_hit_ms` | int | ms | 15 | 0 | 50 | Vibración en acierto (0 = sin vibración). |
| `haptic_error_ms` | int | ms | 50 | 0 | 150 | Vibración en error. |
| `haptic_prism_ms` | int | ms | 80 | 0 | 200 | Vibración al activar PRISM. |
| `crystals_score_divisor` | int | puntos/cristal | 1000 | 100 | 10000 | Conversión de puntuación a cristales. |
| `crystals_completion_bonus` | int | cristales | 5 | 0 | 50 | Bonificación por `COMPLETED`. |
| `crystals_balance_cap` | int | cristales | 999 999 | 999 999 | 999 999 | Fijo. Límite del saldo. |
| `mission_slots` | int | misiones | 3 | 1 | 5 | Huecos de misión simultáneos. Debe ser ≤ número de plantillas − 1. |
| `mission_tier_cap` | int | nivel | 10 | 0 | 50 | Nivel máximo de plantilla. |

## 5. Catálogo de cosméticos `[P]`

| ID | Categoría | Nombre | Precio (cristales) | Por defecto |
|----|-----------|--------|--------------------|-------------|
| `core_default` | Núcleo | Núcleo Estándar | 0 | Sí (poseído y equipado) |
| `core_pulsar` | Núcleo | Púlsar | 40 | No |
| `core_nebula` | Núcleo | Nebulosa | 120 | No |
| `core_singularity` | Núcleo | Singularidad | 300 | No |
| `trail_default` | Estela | Estela Básica | 0 | Sí (poseído y equipado) |
| `trail_spark` | Estela | Chispa | 40 | No |
| `trail_comet` | Estela | Cometa | 120 | No |
| `trail_aurora` | Estela | Aurora | 300 | No |

Coste total del catálogo: 920 cristales. Estimación orientativa (a validar con simulación): una partida de nivel medio con 12 000 puntos otorga 12 cristales; las misiones otorgan entre 10 y 30.

## 6. Plantillas de misión `[P]`

`k` = nivel de la plantilla (FR-MIS-002), en [0, `mission_tier_cap`]. Recompensa común: `10 + 2·k` cristales (10 a 30).

| ID | Tipo | Texto | Objetivo `n(k)` |
|----|------|-------|-----------------|
| `M_HITS_SESSION` | En una partida | «Acierta *n* orbes en una partida» | `20 + 10·k` |
| `M_COMBO` | En una partida | «Alcanza un combo de *n*» | `10 + 5·k` |
| `M_SCORE_SESSION` | En una partida | «Consigue *n* puntos en una partida» | `5000 + 2500·k` |
| `M_SURVIVE` | En una partida | «Aguanta *n* segundos en una partida» | `min(30 + 10·k, session_max_time)` |
| `M_PRISM_TOTAL` | Acumulada | «Activa el modo PRISM *n* veces» | `2 + k` |
| `M_SESSIONS` | Acumulada | «Termina *n* partidas» | `3 + k` |
| `M_CRYSTAL_ORBS` | Acumulada | «Captura *n* orbes cristal» | `2 + k` |

## 7. Bots de verificación `[P]`

Herramientas de prueba para SC-001, SC-002 y E17. Sus tasas de error son **suposiciones** que deben calibrarse con pruebas reales con jugadores; no son requisitos de jugabilidad.

| Bot | Comportamiento |
|-----|----------------|
| `NOVATO` | Para cada orbe que entra en zona decide en un instante uniforme dentro de su ventana en zona. Con probabilidad `1 − ε` actúa correctamente (toca si capturarlo es acierto; no toca en otro caso); con probabilidad `ε = 0.10` actúa al revés. |
| `EXPERTO` | Igual que `NOVATO` con `ε = 0.02`. |
| `SPAM` | Solicita un pulso en cada paso; solo los limita `pulse_cooldown`. |
| `PASIVO` | No toca nunca. |
| `ALEATORIO` | Para cada orbe, toca con probabilidad 0.5 en un instante uniforme de la ventana. Se usa para comprobar invariantes. |

## 8. Historial

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 0.1.0 | 2026-10-23 | Catálogo inicial propuesto. |
