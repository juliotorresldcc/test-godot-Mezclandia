# Especificación funcional: PRISM POP v1

- **Feature:** `001-prism-pop`
- **Versión del documento:** 0.2.2 (aprobada)
- **Fecha:** 2026-10-23
- **Estado:** APROBADA el 2026-10-23 (ver `clarifications.md` §7).
- **Documentos asociados (fuentes de verdad propias):**
  - `parameters.md` — valores, tipos, unidades y rangos de todos los parámetros ajustables.
  - `art-direction.md` — guía visual verificable (paleta, proporciones, animaciones, revisión visual).
  - `clarifications.md` — hallazgos, decisiones abiertas y registro de cambios.

### Leyenda de estado de cada requisito

| Marca | Significado |
|-------|-------------|
| `[M]` | Exigido explícitamente por el mandato del propietario. Aprobado en su enunciado; los detalles concretos pueden ser `[P]`. |
| `[P]` | Propuesta del agente, **aprobada** el 2026-10-23 junto con el resto de la especificación. |
| `(D-xx → A)` | Requisito que dependía de una decisión ya resuelta; se indica la opción elegida. |

Los parámetros se citan con su nombre en `monoespaciado` (p. ej. `orb_speed_min`). Sus valores por defecto solo aparecen aquí en los ejemplos numéricos; la fuente de verdad es `parameters.md`.

### Convención de criterios de aceptación `[P]`

- Si un requisito tiene una línea *Aceptación*, esa es su prueba mínima obligatoria.
- Si no la tiene, su enunciado es el criterio: la prueba reproduce las condiciones del enunciado y comprueba **literalmente** cada valor, fila de tabla, transición y ejemplo numérico que contiene. Toda fila de una tabla de reglas (transiciones, resolución, botones) es un caso de prueba independiente.
- Los requisitos con componente subjetivo (FR-ART-001, NFR-A11Y-006) se verifican con el procedimiento de revisión visual de `art-direction.md` §9 o con la prueba manual indicada en la fase Design.
- La fase Design asignará a cada requisito al menos una prueba concreta (`TEST-…`); un requisito sin prueba asignada no supera la puerta de la fase Analyze.

---

## 0. Resumen y alcance

PRISM POP es un arcade híbrido hypercasual para teléfonos móviles en orientación vertical. Un **núcleo** energético en el centro de la pantalla muestra un **color objetivo**. Desde el borde de la arena llegan **orbes** de colores hacia el núcleo. El jugador, con un único gesto (tocar la pantalla), emite un **pulso** que captura el orbe situado en la **zona de captura** que rodea al núcleo. Capturar un orbe del color objetivo es un **acierto**; capturar uno de otro color, o dejar que un orbe del color objetivo alcance el núcleo, es un **error**. Los aciertos consecutivos forman **combos** que multiplican la puntuación y cargan el **modo PRISM**. Los errores consumen **energía**; la partida termina al agotarse la energía o al alcanzar la duración máxima. Las partidas otorgan **cristales** para desbloquear cosméticos.

> La mecánica del toque (pulso de captura en zona) quedó fijada por la decisión **D-01 → A**.

### 0.1 Dentro del alcance de v1
Partida completa (§3), ocho pantallas (§4), dirección artística (§5 y `art-direction.md`), audio y vibración (§6), cristales, cosméticos, misiones, estadísticas y guardado local (§7), requisitos no funcionales (§8).

### 0.2 Fuera del alcance de v1 `[M]`
Monetización real, anuncios, compras dentro de la aplicación, funciones en red (clasificaciones, nube, multijugador), analítica, notificaciones push, cuentas de usuario. Cualquier incorporación futura requiere una especificación independiente.

---

## 1. Glosario

| Término | Definición |
|---------|------------|
| **Arena** | Círculo de juego centrado en el núcleo. Su radio `R` es la unidad de distancia de la simulación (1 R). |
| **Núcleo** | Elemento central inmóvil. Muestra el color objetivo vigente. Radio visual `core_radius`. |
| **Orbe** | Entidad que se desplaza en línea recta desde el círculo de aparición (radio 1 R) hacia el centro. Tiene un color o es un orbe cristal. |
| **Zona de captura** | Corona circular con radio interior `zone_inner_radius` y exterior `zone_outer_radius`. Un orbe está «en zona» si la distancia de su centro al centro del núcleo `r` cumple `zone_inner_radius < r ≤ zone_outer_radius`. |
| **Impacto** | Un orbe impacta cuando `r ≤ zone_inner_radius`. Al impactar es consumido. |
| **Pulso** | Acción del jugador generada por un toque válido durante `PLAYING`. |
| **Consumo** | Eliminación de un orbe por captura (pulso) o por impacto. |
| **Color objetivo** | Elemento `seq[idx]` de la secuencia de objetivos. |
| **Secuencia de objetivos** | Lista `seq` de colores generada de forma determinista a partir de la semilla de la partida. `idx` es el índice vigente. |
| **Siguiente objetivo** | `seq[idx + 1]`. Se muestra al jugador como anticipación. |
| **Acierto** | Captura válida que suma puntuación (ver tabla de resolución §3.7). |
| **Error** | Error de color u omisión (ver §3.7). |
| **Error de color** | Capturar, en modo normal, un orbe de color distinto del objetivo. |
| **Omisión** | Que un orbe del color objetivo impacte en el núcleo en modo normal. |
| **Pulso vacío** | Pulso emitido sin ningún orbe en zona. |
| **Combo `c`** | Número entero de aciertos consecutivos sin error. |
| **Multiplicador `m`** | Factor derivado de `c` (§3.8). |
| **Energía `E`** | Entero en [0, `energy_max`]. La partida termina por derrota cuando llega a 0. |
| **Carga PRISM `Q`** | Entero en [0, `prism_charge_max`]. Al llenarse activa el modo PRISM. |
| **Tiempo de juego `t`** | Segundos transcurridos en estado `PLAYING` desde el inicio de la partida. No avanza en ningún otro estado. |
| **Progreso de dificultad `u`** | `u = clamp(t / difficulty_ramp_time, 0, 1)`. |
| **Paso de simulación** | Unidad discreta de avance de la simulación, de duración fija `sim_step` (§3.14). |

---

## 2. Historias de usuario y escenarios de aceptación

### HU-1 — Jugar una partida (Prioridad P1) `[M]`
Como jugador, quiero partidas rápidas de un solo toque en las que capturo orbes del color correcto para encadenar combos y superar mi récord.

**Prueba independiente:** desde el menú principal se puede iniciar, jugar, pausar, reanudar, perder o completar una partida y ver los resultados sin usar ninguna otra pantalla.

1. **Dado** el menú principal, **cuando** pulso «JUGAR», **entonces** se muestra la arena en estado `PRE_START` con el texto «Toca para empezar».
2. **Dado** `PRE_START`, **cuando** toco la arena, **entonces** la partida pasa a `PLAYING` con `t = 0`, `E = energy_start`, `c = 0`, `Q = 0`, puntuación 0, y ese toque no genera pulso.
3. **Dado** un orbe del color objetivo en zona, **cuando** toco, **entonces** el orbe se consume, se suma la puntuación de §3.8, `c` aumenta en 1 y el objetivo avanza a `seq[idx+1]`.
4. **Dado** `PLAYING`, **cuando** la energía llega a 0, **entonces** la partida termina en `GAME_OVER` y se muestran los resultados.

### HU-2 — Progresar entre partidas (Prioridad P2) `[M]`
Como jugador, quiero ganar cristales, completar misiones y desbloquear cosméticos para personalizar mi juego.

**Prueba independiente:** con un perfil que tiene cristales suficientes, se puede comprar y equipar un cosmético, y el cambio persiste tras cerrar y abrir la aplicación.

1. **Dado** el final de una partida no abandonada, **cuando** se muestran los resultados, **entonces** se acreditan los cristales calculados según §7.1 y se guarda el perfil.
2. **Dado** un cosmético con precio ≤ saldo, **cuando** confirmo la compra, **entonces** el saldo disminuye exactamente en el precio y el cosmético queda «Poseído».
3. **Dado** una misión completada, **cuando** pulso «Reclamar», **entonces** recibo su recompensa y el hueco se rellena con una misión nueva.

### HU-3 — Ajustar y jugar con comodidad (Prioridad P3) `[M]`
Como jugador, quiero controlar volumen, vibración y efectos visuales, y poder distinguir los colores aunque tenga dificultades de percepción del color.

1. **Dado** Ajustes, **cuando** pongo Música al 0 %, **entonces** no suena música y el resto del juego funciona igual.
2. **Dado** «Símbolos de color» activado, **cuando** aparece un orbe, **entonces** muestra el símbolo de su color (§5).
3. **Dado** «Reducir efectos» activado, **cuando** cometo un error, **entonces** no hay sacudida de pantalla.

---

## 3. Reglas de juego

> Esta sección aplica las decisiones D-01 → A (pulso de captura) y D-02 → A (energía + límite de 90 s).

### 3.1 Sistema de coordenadas

- **FR-ARENA-001** `[P]` La simulación usa coordenadas polares centradas en el núcleo, con distancias en unidades de arena `R`. La conversión a píxeles está definida en `art-direction.md` §4 y no afecta a las reglas.
  *Aceptación:* la misma partida (semilla + entradas) produce el mismo resultado en dos resoluciones distintas (prueba de determinismo con resoluciones 1080×1920 y 1536×2048).
- **FR-ARENA-002** `[P]` Las magnitudes geométricas son `core_radius`, `zone_inner_radius`, `zone_outer_radius`, `orb_radius` y el radio de aparición `spawn_radius = 1.0 R`.
  *Aceptación:* la validación de configuración (§3.15, FR-FAIR-005) rechaza cualquier configuración con `core_radius ≥ zone_inner_radius` o `zone_inner_radius ≥ zone_outer_radius` o `zone_outer_radius ≥ spawn_radius`.

### 3.2 Estados de la partida y transiciones

- **FR-GS-001** `[M][P]` La partida (`GameSession`) tiene exactamente estos estados: `PRE_START`, `PLAYING`, `PAUSED`, `RESUMING`, `GAME_OVER`, `COMPLETED`, `ABANDONED`. Los tres últimos son terminales.
- **FR-GS-002** `[M][P]` Solo se permiten las transiciones de esta tabla. Cualquier otra solicitud de transición se ignora y se registra como advertencia en modo de depuración.

| ID | Desde | Hacia | Disparador | Efectos |
|----|-------|-------|-----------|---------|
| T01 | `PRE_START` | `PLAYING` | Toque en la arena | `t = 0`; inicializa `E`, `c`, `Q`, puntuación, `idx = 0`; el toque **no** genera pulso. |
| T02 | `PRE_START` | `PAUSED` | Botón Pausa o botón Atrás (Android) | Recuerda `origen = PRE_START`. |
| T03 | `PLAYING` | `PAUSED` | Botón Pausa, botón Atrás, pérdida de foco o paso a segundo plano | Congela la simulación; descarta pulsos pendientes; recuerda `origen = PLAYING`. |
| T04 | `PAUSED` | `RESUMING` | «Reanudar» con `origen = PLAYING` | Inicia cuenta atrás de `resume_countdown` segundos de tiempo real. |
| T05 | `PAUSED` | `PRE_START` | «Reanudar» con `origen = PRE_START` | Ninguno. |
| T06 | `RESUMING` | `PLAYING` | Fin de la cuenta atrás | Continúa la simulación exactamente donde se congeló. |
| T07 | `RESUMING` | `PAUSED` | Botón Pausa, botón Atrás o pérdida de foco | Cancela la cuenta atrás. |
| T08 | `PLAYING` | `GAME_OVER` | `E = 0` al final de un paso (§3.14) | Fin de partida por derrota. |
| T09 | `PLAYING` | `COMPLETED` | `t ≥ session_max_time` al final de un paso, con `E > 0` (D-02 → A) | Fin de partida por compleción. |
| T10 | `PAUSED` | `ABANDONED` | «Reiniciar» o «Salir al menú» | Partida descartada (FR-GS-006). «Reiniciar» crea a continuación una partida nueva en `PRE_START`. |

- **FR-GS-003** `[P]` En `PAUSED`, `RESUMING`, `GAME_OVER`, `COMPLETED` y `ABANDONED` no avanzan `t`, los orbes, los temporizadores de PRISM ni la dificultad, y los toques en la arena no generan pulsos.
  *Aceptación:* tras 10 s en `PAUSED`, las posiciones de los orbes, `t` y el temporizador de PRISM son idénticos a los del instante de pausa.
- **FR-GS-004** `[P]` Durante `RESUMING` se muestra una cuenta atrás «3, 2, 1» con cada número durante `resume_countdown / 3` segundos.
  *Aceptación:* con `resume_countdown = 1.5`, la simulación se reanuda 1.5 s ± 1 paso después de pulsar «Reanudar».
- **FR-GS-005** `[P]` Al entrar en `GAME_OVER` o `COMPLETED` se reproduce la animación de fin (`end_sequence_duration`) y después se muestra la pantalla de Resultados. Durante la animación se ignoran todas las entradas excepto las del sistema operativo.
- **FR-GS-006** `[P]` Una partida `ABANDONED` no otorga cristales, no actualiza el récord, no cuenta para misiones ni estadísticas excepto `sesiones_abandonadas`.
  *Aceptación:* abandonar una partida con 5 000 puntos deja intactos saldo, récord y progreso de misiones.
- **FR-GS-007** `[P]` Si la aplicación se cierra o el sistema la termina durante una partida, la partida se pierde sin recompensas. Las partidas no se guardan a medias.

### 3.3 Núcleo

- **FR-CORE-001** `[M][P]` El núcleo es inmóvil, está en el centro de la arena y muestra en todo momento el color objetivo vigente `seq[idx]` y su símbolo (si «Símbolos de color» está activo).
  *Aceptación:* tras cada avance de `idx`, el color del núcleo coincide con `seq[idx]` en el mismo fotograma en que se procesa el avance.
- **FR-CORE-002** `[P]` El brillo del halo del núcleo representa la energía según `art-direction.md` ART-011. Durante PRISM el núcleo muestra el aspecto prismático (ART-031).
- **FR-CORE-003** `[P]` El siguiente objetivo `seq[idx+1]` se muestra en el indicador «SIGUIENTE» (ART-014) durante `PLAYING`, `PAUSED` y `RESUMING`.
  *Aceptación:* en 1 000 avances simulados, el indicador muestra `seq[idx+1]` tras cada avance.

### 3.4 Generación y movimiento de los orbes

- **FR-ORB-001** `[M][P]` Todos los orbes se mueven radialmente hacia el centro a la velocidad global vigente `v(t)` (§3.11), en unidades R/s. La velocidad se aplica a todos los orbes en vuelo por igual, de modo que el orden de llegada coincide siempre con el orden de aparición.
  *Aceptación:* en 10 000 partidas simuladas, el orden de consumo de los orbes es igual a su orden de aparición.
- **FR-ORB-002** `[P]` La primera aparición se produce en `t = 0`. Cada aparición siguiente se produce cuando `t ≥ t_ultima + Δ(t_ultima)`, donde `Δ` es el intervalo de aparición de §3.11 evaluado en el instante de la aparición anterior.
  *Ejemplo:* con valores por defecto, la primera aparición es en `t = 0` y la segunda en `t = 1.10 s` (`Δ(0) = 1.10 s`).
- **FR-ORB-003** `[P]` Cada orbe aparece en `r = spawn_radius` con un ángulo `θ` (grados). El primero, `θ = 360·U`. Los siguientes, `θ = θ_anterior + orb_min_angle_gap + U·(360 − 2·orb_min_angle_gap)` (módulo 360), donde `U` es un número pseudoaleatorio uniforme en [0, 1) del generador de la partida.
  *Ejemplo:* `θ_anterior = 100°`, `orb_min_angle_gap = 40°`, `U = 0.5` → `θ = 100 + 40 + 140 = 280°`. La separación angular circular con el orbe anterior es siempre ≥ 40°.
- **FR-ORB-004** `[P]` Si hay `max_orbs_in_flight` orbes en vuelo, la aparición se retrasa hasta que alguno se consuma. Con los parámetros por defecto esta situación no debe ocurrir nunca; si ocurre, se registra una advertencia (es un indicador de configuración incorrecta).
- **FR-ORB-005** `[P]` Al aparecer, a cada orbe se le asigna su tipo (color o cristal) según el algoritmo de §3.5 (FR-SEQ-004). El tipo no cambia durante su vida.

### 3.5 Colores, secuencia de objetivos y anticipación

- **FR-COL-001** `[M][P]` Colores de orbe: `CIAN`, `MAGENTA`, `AMARILLO`, `VIOLETA`, cada uno con un símbolo único (`art-direction.md` §2). Además existe el tipo especial `CRISTAL` (§3.12), que nunca es color objetivo.
- **FR-COL-002** `[P]` Colores activos: con `t < fourth_color_time` están activos `CIAN`, `MAGENTA` y `AMARILLO`; con `t ≥ fourth_color_time` se añade `VIOLETA`. Al activarse el cuarto color se muestra el aviso «NUEVO COLOR» (ART-035) durante `new_color_notice_duration`.
- **FR-SEQ-001** `[M][P]` La secuencia de objetivos `seq` se genera bajo demanda (cuando se necesita un índice aún no generado) con el generador de la partida: `seq[0]` es uniforme entre los colores activos; cada `seq[i+1]` es uniforme entre los colores activos **distintos de** `seq[i]`. Los colores activos son los del instante en que se genera el elemento.
  *Aceptación:* en 100 000 elementos generados, nunca hay dos elementos consecutivos iguales y ningún elemento es `VIOLETA` si fue generado con `t < fourth_color_time`.
- **FR-SEQ-002** `[M][P]` **Regla de avance:** cuando un orbe es consumido (por captura o por impacto), si su color es igual a `seq[idx]`, entonces `idx ← idx + 1`. En cualquier otro caso `idx` no cambia. Esta regla es la misma en modo normal y en modo PRISM, y es independiente de que el consumo puntúe o penalice.
- **FR-SEQ-003** `[P]` **Proyección:** el objetivo proyectado `P` es el color que será objetivo cuando llegue un orbe nuevo. Se calcula recorriendo los orbes en vuelo en orden de llegada, partiendo de `j = idx`: para cada orbe no cristal, si su color es `seq[j]`, entonces `j ← j + 1`. Al terminar, `P = seq[j]`.
  *Ejemplo:* `seq = [CIAN, MAGENTA, AMARILLO, …]`, `idx = 0`, en vuelo (en orden) `CIAN`, `AMARILLO`. El primero coincide con `seq[0]` → `j = 1`; el segundo no coincide con `seq[1] = MAGENTA` → `j = 1`. `P = MAGENTA`.
- **FR-SEQ-004** `[P]` **Asignación de tipo al aparecer** (en este orden):
  1. Calcular `P` (FR-SEQ-003).
  2. Si `racha_no_objetivo ≥ pity_max_non_target`, el orbe es del color `P` (orbe objetivo); `racha_no_objetivo ← 0`. Fin.
  3. Si el orbe cristal es elegible (FR-EVT-002) y `U < crystal_spawn_chance`, el orbe es `CRISTAL`; `racha_no_objetivo` no cambia. Fin.
  4. Si `U < p_obj(u)` (§3.11), el orbe es del color `P`; `racha_no_objetivo ← 0`.
  5. En otro caso, el orbe es de un color uniforme entre los colores activos distintos de `P`; `racha_no_objetivo ← racha_no_objetivo + 1`.

  Cada `U` es una extracción nueva del generador de la partida.
  *Aceptación:* en 10 000 partidas simuladas no aparecen nunca más de `pity_max_non_target` orbes de color consecutivos que no sean del objetivo proyectado.
- **FR-SEQ-005** `[P]` **Invariante de anticipación:** como consecuencia de FR-ORB-001, FR-SEQ-002 y FR-SEQ-003, el color objetivo vigente cuando un orbe llega a la zona es igual al `P` calculado cuando ese orbe apareció, sea cual sea el comportamiento del jugador.
  *Aceptación:* en 10 000 partidas simuladas con bots aleatorios, la aserción «objetivo al entrar en zona = P al aparecer» se cumple en el 100 % de los orbes.

### 3.6 Entrada y pulsos

- **FR-INP-001** `[M][P]` El único control de juego es tocar la pantalla. Cuenta como toque cada evento de pulsación inicial (contacto nuevo) de cualquier dedo, o clic izquierdo de ratón en escritorio, dentro de la región de juego. La región de juego es toda la pantalla excepto el área táctil del botón Pausa (ART-020). Mantener pulsado, deslizar o soltar no generan pulsos.
- **FR-INP-002** `[P]` En `PLAYING`, un toque genera una solicitud de pulso. Se procesa como máximo un pulso por paso de simulación. Si llegan varios toques antes del siguiente paso, se procesa uno y se descartan los demás.
  *Aceptación:* dos toques simultáneos de dos dedos producen exactamente un pulso.
- **FR-INP-003** `[P]` Tras procesar un pulso (con o sin orbe), los toques recibidos durante `pulse_cooldown` segundos de tiempo de juego se descartan sin efecto ni penalización.
  *Aceptación:* con `pulse_cooldown = 0.15`, un toque a los 0.10 s del anterior no tiene efecto; uno a los 0.16 s sí.
- **FR-INP-004** `[P]` El pulso actúa sobre el orbe en zona en el instante del paso (antes de mover los orbes, §3.14). Por FR-FAIR-001 hay como máximo un orbe en zona.
- **FR-INP-005** `[P]` Durante `PRE_START`, el primer toque solo inicia la partida (T01). Durante `PAUSED`, `RESUMING` y los estados terminales, los toques en la arena no tienen efecto de juego.
- **FR-INP-006** `[P]` En escritorio (pruebas y desarrollo) la tecla Espacio equivale a un toque. No se expone al jugador en móvil.

### 3.7 Resolución de aciertos y errores

- **FR-RES-001** `[M][P]` La resolución de cada evento sigue esta tabla de decisión exhaustiva:

| Evento | Modo | Tipo del orbe | Resultado | `c` | Puntos | `E` | `Q` | Avance `idx` (FR-SEQ-002) |
|--------|------|---------------|-----------|-----|--------|-----|-----|-----------|
| Pulso con orbe en zona | Normal | Color = objetivo | **Acierto** | `c+1` | §3.8 | `+energy_hit_gain` | `+prism_charge_per_hit` | Sí |
| Pulso con orbe en zona | Normal | Color ≠ objetivo | **Error de color** | `0` | 0 | `−energy_error_cost` | `floor(Q/2)` | No |
| Pulso con orbe en zona | Normal | `CRISTAL` | **Acierto cristal** | `c+1` | §3.8 | `+energy_hit_gain` | `+prism_charge_per_crystal` | No |
| Pulso con orbe en zona | PRISM | Cualquiera | **Acierto** | `c+1` | §3.8 (×`prism_score_factor`) | `+energy_hit_gain` | sin cambio (bloqueada) | Solo si color = objetivo |
| Pulso sin orbe en zona | Cualquiera | — | **Pulso vacío** | sin cambio | 0 | sin cambio | sin cambio | No |
| Impacto | Normal | Color = objetivo | **Omisión** | `0` | 0 | `−energy_error_cost` | `floor(Q/2)` | Sí |
| Impacto | Normal | Color ≠ objetivo | **Descarte** (neutro) | sin cambio | 0 | sin cambio | sin cambio | No |
| Impacto | Cualquiera | `CRISTAL` | **Descarte** (neutro) | sin cambio | 0 | sin cambio | sin cambio | No |
| Impacto | PRISM | Color | **Descarte** (neutro) | sin cambio | 0 | sin cambio | sin cambio | Solo si color = objetivo |

  La captura de un orbe `CRISTAL`, en cualquier modo, suma además `crystal_orb_reward` cristales al contador de la partida y cuenta como orbe cristal capturado.
  *Aceptación:* una prueba unitaria por fila verifica todos los efectos de la fila y la ausencia de cualquier otro efecto.
- **FR-RES-002** `[P]` `E` y `Q` se limitan a sus rangos tras cada operación: `E = clamp(E, 0, energy_max)`, `Q = clamp(Q, 0, prism_charge_max)`.

### 3.8 Puntuación base y multiplicador

- **FR-SCO-001** `[M][P]` Al registrar un acierto, primero se incrementa el combo (`c ← c + 1`) y después se calcula:
  - `m(c) = min(mult_max, 1 + mult_step · floor(c / combo_step))`
  - `k = prism_score_factor` si el modo PRISM está activo; `k = 1` en otro caso.
  - `puntos = round_half_up(score_base · m(c) · k)` (entero).

  Variables: `c` entero ≥ 1 (adimensional), `m` real ≥ 1 (adimensional), `score_base` entero (puntos).
  Con los valores por defecto (`score_base = 100`, `mult_step = 0.5`, `combo_step = 5`, `mult_max = 4.0`, `prism_score_factor = 2`):

| `c` tras el acierto | `m(c)` | Puntos (normal) | Puntos (PRISM) |
|---|---|---|---|
| 1 – 4 | 1.0 | 100 | 200 |
| 5 – 9 | 1.5 | 150 | 300 |
| 10 – 14 | 2.0 | 200 | 400 |
| 15 – 19 | 2.5 | 250 | 500 |
| 20 – 24 | 3.0 | 300 | 600 |
| 25 – 29 | 3.5 | 350 | 700 |
| ≥ 30 | 4.0 (límite) | 400 | 800 |

  *Aceptación:* pruebas unitarias con `c ∈ {1, 4, 5, 9, 10, 29, 30, 31, 100}` en modo normal y PRISM devuelven exactamente los valores de la tabla.
- **FR-SCO-002** `[P]` `round_half_up(x) = floor(x + 0.5)`. Con los valores por defecto el resultado ya es entero; la regla aplica si se ajustan los parámetros.
- **FR-SCO-003** `[P]` La puntuación de la partida es un entero de 64 bits que comienza en 0 y solo aumenta por aciertos. No hay bonificaciones de fin de partida en puntos.
- **FR-SCO-004** `[P]` **Récord:** al terminar una partida en `GAME_OVER` o `COMPLETED`, si su puntuación es **estrictamente mayor** que el récord guardado, se convierte en el nuevo récord y Resultados muestra «NUEVO RÉCORD». Un empate no es récord.

### 3.9 Combos

- **FR-CMB-001** `[M][P]` Estados del combo:

| Estado | Condición | Duración |
|--------|-----------|----------|
| `COMBO_IDLE` | `c = 0` y sin ruptura reciente | — |
| `COMBO_ACTIVE` | `c ≥ 1` | hasta un error |
| `COMBO_BROKEN` | Transitorio tras romperse un combo con `c ≥ 1` | `combo_broken_feedback` s de tiempo de juego |

  Transiciones:
  - `COMBO_IDLE → COMBO_ACTIVE`: acierto (`c` pasa de 0 a 1).
  - `COMBO_ACTIVE → COMBO_ACTIVE`: acierto (`c ← c + 1`).
  - `COMBO_ACTIVE → COMBO_BROKEN`: error de color u omisión (`c ← 0`). Registra `c` previo para estadísticas.
  - `COMBO_BROKEN → COMBO_IDLE`: transcurre `combo_broken_feedback`.
  - `COMBO_BROKEN → COMBO_ACTIVE`: acierto durante la ventana (`c = 1`).
  - `COMBO_IDLE` + error: permanece en `COMBO_IDLE` (aplica la penalización de energía igualmente).
  - Pulso vacío, descarte, pausa y reanudación no cambian el estado del combo.
- **FR-CMB-002** `[P]` El **nivel de combo** visible es `tier = min(floor(c / combo_step), floor((mult_max − 1) / mult_step))` (0 a 6 con valores por defecto). Al subir de nivel se reproduce la respuesta de ART-033 y el sonido `combo_tier_up`.
- **FR-CMB-003** `[P]` El mejor combo de la partida es el valor máximo alcanzado por `c`.

### 3.10 Energía, errores y finalización

- **FR-ENE-001** `[M][P]` La partida empieza con `E = energy_start`. Cada error resta `energy_error_cost`; cada acierto (incluido cristal y PRISM) suma `energy_hit_gain`. No hay drenaje pasivo por tiempo.
  *Ejemplo (valores por defecto `energy_start = 100`, `energy_error_cost = 35`, `energy_hit_gain = 1`):* tres errores sin aciertos: 100 → 65 → 30 → 0 (fin). Con 10 aciertos entre errores: 100 → 65 → 75 → 40 → 50 → 15 → 25 → 0 (fin al cuarto error).
- **FR-ENE-002** `[P]` **Estado crítico:** cuando `0 < E ≤ energy_error_cost` (el siguiente error termina la partida), se activa la respuesta de energía crítica (ART-034 y sonido `energy_critical`). Se desactiva cuando `E > energy_error_cost`.
- **FR-ENE-003** `[M][P]` La partida termina por derrota (`GAME_OVER`) cuando `E = 0` al final de un paso de simulación.
- **FR-ENE-004** `[M][P]` La partida termina por compleción (`COMPLETED`) cuando `t ≥ session_max_time` al final de un paso con `E > 0`. Si en el mismo paso `E = 0`, prevalece `GAME_OVER`. (D-02 → A)
  *Aceptación:* ninguna partida simulada dura más de `session_max_time + sim_step`.
- **FR-ENE-005** `[P]` Al terminar la partida, los orbes en vuelo se eliminan sin efectos de juego y se detiene el generador.

### 3.11 Curva de dificultad

- **FR-DIF-001** `[M][P]` La dificultad depende solo del tiempo de juego, mediante `u = clamp(t / difficulty_ramp_time, 0, 1)`, con interpolación lineal:
  - Velocidad de los orbes: `v(t) = orb_speed_min + (orb_speed_max − orb_speed_min) · u` [R/s].
  - Intervalo de aparición: `Δ(t) = spawn_interval_max − (spawn_interval_max − spawn_interval_min) · u` [s].
  - Probabilidad de orbe objetivo: `p_obj(u) = target_chance_start − (target_chance_start − target_chance_end) · u` [adimensional].

| `t` (s) | `u` | `v` (R/s) | `Δ` (s) | `p_obj` | Tiempo de recorrido hasta impacto (s)* | Ventana en zona (s)** |
|---|---|---|---|---|---|---|
| 0 | 0.00 | 0.350 | 1.100 | 0.550 | 2.37 | 0.571 |
| 15 | 0.25 | 0.4625 | 0.9375 | 0.5125 | 1.79 | 0.432 |
| 30 | 0.50 | 0.575 | 0.775 | 0.475 | 1.44 | 0.348 |
| 45 | 0.75 | 0.6875 | 0.6125 | 0.4375 | 1.21 | 0.291 |
| ≥ 60 | 1.00 | 0.800 | 0.450 | 0.400 | 1.04 | 0.250 |

  \* `(spawn_radius − zone_inner_radius) / v` con velocidad constante. \*\* `(zone_outer_radius − zone_inner_radius) / v`. Valores por defecto de `parameters.md`.
- **FR-DIF-002** `[M][P]` Límites: `v` nunca es menor que `orb_speed_min` ni mayor que `orb_speed_max`; `Δ` nunca es menor que `spawn_interval_min` ni mayor que `spawn_interval_max`.
  *Aceptación:* prueba unitaria con `t ∈ {−1, 0, 30, 60, 61, 10⁶}` devuelve valores dentro de los límites (con `t = −1` tratado como 0).
- **FR-DIF-003** `[P]` A partir de `t ≥ difficulty_ramp_time` la dificultad se mantiene en su máximo hasta el final de la partida.

### 3.12 Evento especial: orbe cristal

- **FR-EVT-001** `[M][P]` En v1 existe un único evento especial: el **orbe cristal**. Es un orbe con aspecto propio (ART-016), que nunca es color objetivo. Sus efectos están en la tabla FR-RES-001.
- **FR-EVT-002** `[P]` Un orbe cristal es elegible para aparecer si se cumplen todas las condiciones: `t ≥ crystal_min_time`; el modo PRISM no está activo; han pasado al menos `crystal_cooldown` segundos de tiempo de juego desde la aparición del último orbe cristal (o no ha aparecido ninguno); en la partida han aparecido menos de `crystal_max_per_session` orbes cristal.
  *Aceptación:* en 10 000 partidas simuladas no se incumple ninguna de las condiciones.

### 3.13 Modo PRISM

- **FR-PRM-001** `[M][P]` **Carga:** `Q` empieza en 0. Un acierto en modo normal suma `prism_charge_per_hit`; un acierto cristal suma `prism_charge_per_crystal`; un error aplica `Q ← floor(Q / 2)`. Durante PRISM, `Q` permanece en 0 y no se carga.
  *Ejemplo:* 25 aciertos seguidos desde `Q = 0` con `prism_charge_per_hit = 4` → `Q = 100` → activación. Con `Q = 63` un error deja `Q = 31`.
- **FR-PRM-002** `[M][P]` **Activación:** automática al final del paso en que `Q ≥ prism_charge_max`. Al activarse: `Q ← 0`, temporizador PRISM `= prism_duration` s de tiempo de juego, respuesta ART-031 y sonido `prism_start`. No se puede activar si ya está activo. `[P: activación automática frente a manual, ver M-01]`
- **FR-PRM-003** `[M][P]` **Efectos durante PRISM:** todas las capturas son aciertos con factor `prism_score_factor`; los impactos son descartes neutros; la regla de avance FR-SEQ-002 sigue aplicándose; no aparecen orbes cristal.
- **FR-PRM-004** `[P]` **Aviso de fin:** durante los últimos `prism_warning_time` segundos se muestra la respuesta ART-032 y suena `prism_warning` una vez.
- **FR-PRM-005** `[M][P]` **Finalización:** cuando el temporizador llega a 0 (en el paso 3 de §3.14), el modo vuelve a normal. Los orbes en vuelo mantienen su tipo y se rigen por las reglas normales desde ese paso. La pausa congela el temporizador. Si la partida termina durante PRISM, PRISM termina con ella.
- **FR-PRM-006** `[P]` Se cuenta el número de activaciones de PRISM por partida (estadística y misiones).

### 3.14 Orden de resolución en cada paso de simulación

- **FR-SIM-001** `[P]` La simulación avanza en pasos fijos de `sim_step` segundos. En cada paso con estado `PLAYING` se ejecuta, en este orden exacto:
  1. **Pulso:** si hay una solicitud de pulso válida (FR-INP-002/003), resolverla contra el orbe en zona según FR-RES-001.
  2. **Tiempo:** `t ← t + sim_step`; actualizar `u`; decrementar el temporizador PRISM y finalizar PRISM si llega a 0; actualizar ventanas de `COMBO_BROKEN` y avisos; activar el cuarto color si corresponde.
  3. **Movimiento:** cada orbe en vuelo `r ← r − v(t) · sim_step`.
  4. **Impactos:** resolver, en orden de llegada, los orbes con `r ≤ zone_inner_radius` según FR-RES-001.
  5. **Aparición:** aplicar FR-ORB-002 a FR-ORB-005.
  6. **Activación PRISM:** aplicar FR-PRM-002.
  7. **Fin:** aplicar FR-ENE-003 y después FR-ENE-004.
- **FR-SIM-002** `[P]` **Determinismo:** dados la misma semilla, la misma configuración y la misma secuencia de pulsos (indicada por número de paso), la partida produce exactamente el mismo resultado (puntuación, estadísticas, orden y tipo de todos los orbes).
  *Aceptación:* 100 repeticiones de una partida grabada producen resultados idénticos bit a bit.
- **FR-SIM-003** `[P]` La semilla de cada partida se obtiene de una fuente no determinista al crear la partida (excepto en pruebas, donde se inyecta). La semilla se muestra en el modo de depuración para reproducir errores.

### 3.15 Equidad: prevención de situaciones imposibles o injustas

- **FR-FAIR-001** `[P]` Nunca hay más de un orbe en zona. Se garantiza por la separación radial mínima entre orbes consecutivos: `v(t) · Δ(t) ≥ min_radial_gap` para todo `u ∈ [0, 1]`, con `min_radial_gap > (zone_outer_radius − zone_inner_radius)`.
  *Ejemplo (valores por defecto):* `v·Δ` vale 0.385 en `u = 0`, 0.446 en `u = 0.5` y 0.360 en `u = 1`; todos ≥ `min_radial_gap = 0.35` > 0.20.
- **FR-FAIR-002** `[P]` Un orbe objetivo aparece como máximo tras `pity_max_non_target` orbes de color no objetivo consecutivos (FR-SEQ-004 paso 2).
- **FR-FAIR-003** `[P]` El indicador «SIGUIENTE» y el color del núcleo son siempre correctos (invariante FR-SEQ-005).
- **FR-FAIR-004** `[P]` El objetivo no cambia mientras un orbe está en zona salvo por el consumo de ese mismo orbe (consecuencia de FR-FAIR-001 y FR-SEQ-002).
- **FR-FAIR-005** `[P]` **Validación de configuración:** al cargar la configuración se comprueban todas las restricciones de `parameters.md` §3. Si alguna falla, en compilaciones de depuración la partida no se inicia y se muestra el error; las compilaciones de publicación no pueden generarse con una configuración inválida (comprobación automática en la batería de pruebas).
- **FR-FAIR-006** `[P]` Durante `PLAYING`, ningún elemento de la interfaz se superpone a la arena (círculo de radio `1.05 R`) en ninguna de las resoluciones de referencia (`art-direction.md` §4). En `PRE_START`, `RESUMING` y la secuencia de fin pueden superponerse textos informativos (CR-003).

### 3.16 Estadísticas de la partida

- **FR-STAT-001** `[P]` Cada partida registra: puntuación, duración `t` final, aciertos (incluidos cristal y PRISM), errores de color, omisiones, pulsos vacíos, mejor combo, activaciones de PRISM, orbes cristal capturados, cristales ganados y motivo de fin.
- **FR-STAT-002** `[P]` Precisión = `floor(100 · aciertos / (aciertos + errores_de_color + omisiones))` en %; si el denominador es 0, la precisión es 0 %.
  *Ejemplo:* 47 aciertos, 2 errores de color, 1 omisión → `floor(100·47/50) = 94 %`.

---

## 4. Experiencia de usuario

### 4.1 Mapa de pantallas (`GameManager`)

- **FR-UX-001** `[M][P]` Estados de la aplicación y navegación permitida:

| Desde | Acción | Hacia |
|-------|--------|-------|
| Arranque | Carga completada | Inicio |
| Inicio | Fin de `splash_min_time` y carga completada, o toque tras la carga | Menú principal |
| Menú principal | JUGAR | Partida (`PRE_START`) |
| Menú principal | Colección / Misiones / Ajustes | Pantalla correspondiente |
| Menú principal | Atrás (Android) | Diálogo «¿Salir del juego?» |
| Colección / Misiones | Atrás (botón o Android) | Menú principal |
| Ajustes | Atrás | Pantalla de origen (Menú principal o Pausa) |
| Partida | Pausa | Pausa (superpuesta) |
| Pausa | Reanudar / Reiniciar / Ajustes / Salir al menú | Partida / Partida nueva / Ajustes / Menú principal |
| Partida | Fin de partida | Resultados |
| Resultados | Reintentar | Partida nueva (`PRE_START`) |
| Resultados | Menú o Atrás | Menú principal |

- **FR-UX-002** `[P]` Las transiciones entre pantallas siguen ART-040. Durante una transición se ignoran los toques.
- **FR-UX-003** `[M]` Cada botón visible tiene un comportamiento especificado en esta sección. Un botón sin comportamiento especificado no puede existir.
  *Aceptación:* la matriz de pruebas de interfaz contiene una fila por cada botón de esta sección y todas pasan.
- **FR-UX-004** `[P]` Todos los textos se muestran en español (`[P]`, ver M-07) y se cargan desde una tabla de traducción, nunca escritos en el código.

### 4.2 Inicio

- **FR-UX-010** `[M][P]` Propósito: mostrar la identidad y cargar el perfil. Componentes: logotipo animado (ART-041), indicador de carga discreto si la carga supera 1 s.
- **FR-UX-011** `[P]` Se pasa al Menú principal cuando la carga ha terminado y han transcurrido `splash_min_time` segundos; un toque tras la carga omite la espera.
- **FR-UX-012** `[P]` **Error de carga:** si el guardado no puede leerse (§7.5), se muestra el diálogo: «No se pudo leer tu progreso. Se ha guardado una copia de seguridad y se empezará un progreso nuevo.» con un único botón **Aceptar** (cierra el diálogo y continúa al Menú principal).

### 4.3 Menú principal

- **FR-UX-020** `[M][P]` Componentes y acciones:

| Componente | Contenido / acción |
|-----------|---------------------|
| Logotipo | «PRISM POP». Sin acción. |
| Récord | «RÉCORD» + valor con separador de miles. Si no hay récord: «RÉCORD —». |
| Saldo | Icono de cristal + saldo. Sin acción. |
| Botón **JUGAR** (primario) | Abre la Partida en `PRE_START`. |
| Botón **Colección** | Abre Colección. |
| Botón **Misiones** | Abre Misiones. Muestra una insignia con el número de misiones listas para reclamar si es > 0. |
| Botón **Ajustes** | Abre Ajustes con origen Menú principal. |

- **FR-UX-021** `[P]` Diálogo «¿Salir del juego?»: **Salir** cierra la aplicación tras asegurar que no hay escrituras de guardado pendientes; **Cancelar** cierra el diálogo. En iOS no existe este diálogo (no hay botón Atrás del sistema).

### 4.4 Partida (HUD)

- **FR-UX-030** `[M][P]` Componentes durante la partida (disposición en ART-020 a ART-026):

| Componente | Contenido |
|-----------|-----------|
| Puntuación | Entero con separador de miles. |
| Combo | «×m» y «COMBO c». Oculto si `c = 0` (salvo animación de ruptura). |
| Tiempo | Tiempo restante `session_max_time − t` en formato `m:ss`, redondeado hacia arriba. (D-02 → A) |
| Botón **Pausa** | T02/T03/T07. |
| Barra de energía | `E / energy_max`. Estado crítico según FR-ENE-002. |
| Medidor PRISM | `Q / prism_charge_max`; durante PRISM, tiempo restante de PRISM. |
| Núcleo, zona y orbes | §3 y `art-direction.md`. |
| Indicador SIGUIENTE | `seq[idx+1]` (FR-CORE-003). |

- **FR-UX-031** `[P]` En `PRE_START` se muestran la arena sin orbes, la puntuación 0 y el texto pulsante «Toca para empezar». En las `onboarding_sessions` primeras partidas del perfil se muestra además la indicación de aprendizaje: «Toca cuando un orbe del color del núcleo esté dentro del anillo» (ver propuesta M-05).
- **FR-UX-032** `[P]` Las ventanas emergentes de puntuación («+150») aparecen en la posición del orbe capturado (ART-030).

### 4.5 Pausa

- **FR-UX-040** `[M][P]` Capa superpuesta (ART-042) sobre la partida congelada. Componentes: título «PAUSA», puntuación actual y botones:

| Botón | Acción |
|-------|--------|
| **Reanudar** (primario) | T04 o T05. Atrás (Android) equivale a Reanudar. |
| **Reiniciar** | T10 y crea una partida nueva en `PRE_START`. Sin confirmación `[P]` (ver B-02). |
| **Ajustes** | Abre Ajustes con origen Pausa (sin la opción Restablecer progreso). |
| **Salir al menú** | T10 y vuelve al Menú principal. |

### 4.6 Resultados

- **FR-UX-050** `[M][P]` Componentes:

| Componente | Contenido |
|-----------|-----------|
| Título | «FIN DE LA PARTIDA» (`GAME_OVER`) o «¡PRISMA ESTABLE!» (`COMPLETED`). |
| Puntuación | Animación de recuento (ART-043); un toque la completa al instante. |
| Insignia | «NUEVO RÉCORD» solo si se cumple FR-SCO-004. |
| Estadísticas | Duración (`m:ss`), aciertos, precisión, mejor combo, activaciones PRISM. |
| Cristales | Total ganado y desglose (puntuación, orbes cristal, compleción). |
| Misiones | Lista de misiones completadas en esta partida, con el texto «Lista para reclamar». Vacía → no se muestra la sección. |
| Aviso de descanso | Si procede (FR-RG-002). |
| Botón **Reintentar** (primario) | Partida nueva en `PRE_START`. |
| Botón **Menú** | Menú principal. Atrás (Android) equivale a Menú. |

- **FR-UX-051** `[P]` Las recompensas y estadísticas se aplican y se guardan **antes** de mostrar la pantalla de Resultados (§7.5).

### 4.7 Colección

- **FR-UX-060** `[M][P]` Dos pestañas: **Núcleos** y **Estelas**. Cada pestaña muestra una cuadrícula con todos los cosméticos de su categoría (`parameters.md` §5). Cada elemento muestra vista previa, nombre y estado:

| Estado | Condición | Indicación | Acción al tocar |
|--------|-----------|-----------|-----------------|
| Equipado | Poseído y equipado | «EQUIPADO» | Ninguna. |
| Poseído | Poseído, no equipado | «EQUIPAR» | Lo equipa y desequipa el anterior de su categoría; guarda. |
| Disponible | No poseído, precio ≤ saldo | Precio | Diálogo «¿Comprar *nombre* por *N* cristales?» con **Comprar** (descuenta, marca poseído, lo equipa y guarda) y **Cancelar**. |
| Insuficiente | No poseído, precio > saldo | Precio atenuado | Mensaje breve «Te faltan *N* cristales» durante 2 s. |

- **FR-UX-061** `[P]` Botón **Atrás** vuelve al Menú principal. La pantalla muestra el saldo actual.
- **FR-UX-062** `[P]` No existe estado vacío: cada categoría contiene al menos el elemento por defecto gratuito, poseído desde el inicio.

### 4.8 Misiones

- **FR-UX-070** `[M][P]` Muestra los `mission_slots` huecos activos. Cada misión: descripción, barra de progreso «actual/objetivo», recompensa en cristales y estado:
  - En curso: sin botón.
  - Completada: botón **Reclamar +N** → suma N cristales, registra el reclamo, rellena el hueco (§7.3) y guarda.
- **FR-UX-071** `[P]` Botón **Atrás** vuelve al Menú principal. No hay estado vacío: los huecos siempre están ocupados (§7.3).

### 4.9 Ajustes

- **FR-UX-080** `[M][P]` Controles (los cambios se aplican al instante y se guardan al cambiar):

| Control | Tipo | Valores | Defecto |
|---------|------|---------|---------|
| Música | Deslizador | 0–100 %, pasos de 10 | 70 % |
| Efectos de sonido | Deslizador | 0–100 %, pasos de 10 | 80 % |
| Vibración | Interruptor | Sí/No; deshabilitado con el texto «No disponible en este dispositivo» si la plataforma no la admite (FR-HAP-003) | Sí |
| Símbolos de color | Interruptor | Sí/No | Sí |
| Reducir efectos | Interruptor | Sí/No (ART-050) | No |
| Recordatorio de descanso | Interruptor | Sí/No (FR-RG-002) | Sí |
| Botón **Restablecer progreso** | Botón | Solo con origen Menú principal | — |
| Botón **Créditos y licencias** | Botón | Abre un panel desplazable con créditos y licencias de los recursos de terceros; botón **Cerrar** | — |
| Versión | Texto | Versión de la aplicación | — |
| Botón **Atrás** | Botón | Vuelve a la pantalla de origen | — |

- **FR-UX-081** `[P]` **Restablecer progreso:** diálogo «Esto borrará cristales, desbloqueos, misiones, estadísticas y récord. Los ajustes se conservan. No se puede deshacer.» con **Borrar** (restablece el perfil a sus valores iniciales y guarda) y **Cancelar**.

---

## 5. Dirección artística

La guía verificable completa está en `art-direction.md` (requisitos `ART-NNN`). Requisitos funcionales de alto nivel:

- **FR-ART-001** `[M]` Fondo azul noche; colores de orbe cian, magenta, amarillo y violeta eléctricos; núcleo con profundidad; orbes reconocibles; partículas controladas; gradientes y halos; tipografía legible; interfaz minimalista; animaciones rápidas.
- **FR-ART-002** `[M][P]` Ninguna información de juego se transmite solo por color: cada color de orbe tiene un símbolo (ART-002).
- **FR-ART-003** `[P]` Los cosméticos no pueden alterar el color, el símbolo ni la legibilidad de los orbes y del objetivo del núcleo (ART-060).

---

## 6. Audio y respuesta sensorial

- **FR-AUD-001** `[M][P]` Eventos con sonido:

| ID sonido | Evento | Notas |
|-----------|--------|-------|
| `pulse_empty` | Pulso vacío | Suave, corto. |
| `hit` | Acierto | El tono sube un semitono por nivel de combo (`tier`, FR-CMB-002). |
| `hit_crystal` | Acierto cristal | Brillo cristalino. |
| `error_color` | Error de color | Disonante, corto. |
| `omission` | Omisión | Impacto grave. |
| `combo_tier_up` | Sube nivel de combo | — |
| `combo_break` | Ruptura de combo con `c ≥ combo_step` | — |
| `prism_start` / `prism_warning` / `prism_end` | Modo PRISM | — |
| `new_color` | Activación del cuarto color | — |
| `energy_critical` | Entrada en estado crítico | Una vez por entrada. |
| `game_over` / `completed` | Fin de partida | — |
| `record` | Nuevo récord en Resultados | — |
| `ui_tap` / `ui_back` / `purchase` / `claim` | Interfaz | — |

- **FR-AUD-002** `[M][P]` Música: una pista de menú en bucle y una pista de partida en bucle con dos capas: base (siempre) y capa de intensidad que entra con fundido de 2 s cuando `u ≥ 0.5`. Durante PRISM se añade la capa PRISM. En Pausa, la música baja `pause_music_duck_db` dB.
- **FR-AUD-003** `[M][P]` Volumen: deslizador `p` (0–100 %) → ganancia `20·log10(p/100)` dB; `p = 0` silencia por completo el bus. Música y efectos tienen buses independientes.
- **FR-AUD-004** `[M][P]` Si no hay dispositivo de audio o falla su inicialización, el juego funciona íntegramente sin sonido, sin diálogos de error, y registra una advertencia. *Aceptación:* ejecución con controlador de audio nulo (`--audio-driver Dummy`) completa una partida simulada sin errores.
- **FR-AUD-005** `[P]` Como máximo `sfx_max_voices` sonidos simultáneos; si se supera, se descarta el más antiguo de menor prioridad.
- **FR-HAP-001** `[M][P]` Vibración opcional: `hit` `haptic_hit_ms` ms; error de color y omisión `haptic_error_ms` ms; activación PRISM `haptic_prism_ms` ms. Ninguna otra acción vibra.
- **FR-HAP-002** `[M]` La vibración respeta el interruptor de Ajustes.
- **FR-HAP-003** `[M][P]` Si la plataforma no admite vibración (cualquier plataforma distinta de Android o iOS), el interruptor aparece deshabilitado con el texto «No disponible en este dispositivo» y no se realiza ninguna llamada de vibración.

---

## 7. Progresión

### 7.1 Cristales

- **FR-PRG-001** `[M][P]` Al terminar una partida en `GAME_OVER` o `COMPLETED`:
  `cristales = floor(puntuación / crystals_score_divisor) + crystal_orb_reward · orbes_cristal_capturados + (crystals_completion_bonus si COMPLETED, si no 0)`.
  *Ejemplo:* puntuación 12 345, 2 orbes cristal, `COMPLETED` → `floor(12345/1000) + 3·2 + 5 = 12 + 6 + 5 = 23`.
- **FR-PRG-002** `[P]` El saldo es un entero en [0, `crystals_balance_cap`]. Lo que exceda el límite se pierde y se registra en estadísticas (`cristales_desbordados`).
- **FR-PRG-003** `[M]` Los cristales no se pueden comprar con dinero real ni obtener mediante anuncios.

### 7.2 Cosméticos

- **FR-PRG-010** `[M][P]` Catálogo, precios y categorías en `parameters.md` §5. Dos categorías: núcleos y estelas de orbe. Cada categoría tiene exactamente un elemento equipado.
- **FR-PRG-011** `[M][P]` Condición de desbloqueo única en v1: compra con cristales. Los elementos por defecto son gratuitos y poseídos desde el inicio.
- **FR-PRG-012** `[P]` Una compra es atómica: o se descuenta el precio y se marca poseído (y se guarda), o no ocurre nada.
  *Aceptación:* con saldo exactamente igual al precio, la compra deja saldo 0 y el elemento poseído.

### 7.3 Misiones

- **FR-MIS-001** `[M][P]` Hay `mission_slots` misiones activas simultáneas, generadas a partir de las plantillas de `parameters.md` §6. Nunca hay dos misiones activas de la misma plantilla.
- **FR-MIS-002** `[P]` Cada plantilla tiene nivel `k` = número de veces que se ha reclamado una misión de esa plantilla, limitado a `mission_tier_cap`. El objetivo y la recompensa se calculan con las fórmulas de la plantilla al asignar la misión y no cambian después.
- **FR-MIS-003** `[P]` Progreso: las misiones «en una partida» toman el mejor valor de una sola partida desde la asignación; las misiones «acumuladas» suman desde la asignación. Solo cuentan partidas terminadas en `GAME_OVER` o `COMPLETED`. El progreso se evalúa al final de cada partida.
- **FR-MIS-004** `[P]` Una misión pasa a «Completada» cuando progreso ≥ objetivo. El progreso mostrado se limita al objetivo.
- **FR-MIS-005** `[P]` Al reclamar, el hueco se rellena con una plantilla elegida de forma uniforme entre las que no ocupan los **otros** huecos (la reclamada puede repetirse con su nivel aumentado; CR-002), con el generador del perfil (semilla y estado guardados en el perfil para que el resultado sea reproducible).
- **FR-MIS-006** `[P]` Las misiones iniciales del perfil nuevo son fijas: `M_HITS_SESSION`, `M_COMBO`, `M_SESSIONS`, todas con `k = 0`.
- **FR-MIS-007** `[M]` Las misiones no tienen caducidad, temporizadores diarios ni penalizaciones por no jugar (FR-RG-001).

### 7.4 Estadísticas acumuladas

- **FR-STAT-010** `[M][P]` El perfil guarda: récord, partidas terminadas, partidas abandonadas, partidas completadas (`COMPLETED`), aciertos totales, errores totales, mejor combo histórico, activaciones PRISM totales, orbes cristal totales, tiempo de juego total (s), cristales ganados totales, cristales gastados totales, cristales desbordados.
- **FR-STAT-011** `[P]` Las estadísticas acumuladas se muestran en la pantalla Misiones bajo el encabezado «Estadísticas». *(Ubicación propuesta: el mandato no define una pantalla de estadísticas.)*

### 7.5 Persistencia local

- **FR-SAV-001** `[M][P]` Se guardan localmente: perfil (saldo, cosméticos poseídos y equipados, misiones y sus niveles, semilla de misiones, estadísticas, número de partidas para el aprendizaje) y ajustes. No se guarda la partida en curso.
- **FR-SAV-002** `[P]` Momentos de guardado: antes de mostrar Resultados; tras una compra, un equipamiento, un reclamo, un restablecimiento y un cambio de ajustes; al abandonar una partida (estadística de abandono).
- **FR-SAV-003** `[P]` Escritura atómica: se escribe un archivo temporal completo y se sustituye el archivo principal solo si la escritura terminó correctamente. Un fallo de escritura nunca corrompe el guardado anterior.
  *Aceptación:* interrumpir la escritura a mitad (prueba con fallo inyectado) deja el guardado anterior intacto y legible.
- **FR-SAV-004** `[P]` El guardado incluye un número de versión de esquema. Al cargar una versión anterior se aplican migraciones en orden. Si la versión es posterior a la soportada, o el contenido no es legible, o contiene valores fuera de rango: se copia el archivo a una copia de seguridad con marca de tiempo, se crea un perfil nuevo y se muestra FR-UX-012.
- **FR-SAV-005** `[P]` Si una escritura falla, se muestra durante 3 s el aviso «No se pudo guardar el progreso», se mantiene el estado en memoria y se reintenta en el siguiente momento de guardado.
- **FR-SAV-006** `[P]` El guardado no contiene datos personales ni identificadores de dispositivo.

---

## 8. Requisitos no funcionales

### 8.1 Rendimiento

- **NFR-PERF-001** `[M][P]` 60 FPS sostenidos en el dispositivo de referencia (`[P]`, ver M-08) durante el escenario de estrés: 60 s a dificultad máxima, PRISM activo, `max_orbs_in_flight` orbes y el presupuesto máximo de partículas (ART-051). Criterio: percentil 95 del tiempo de fotograma ≤ 16.7 ms y ningún fotograma > 33.3 ms tras los 2 primeros segundos.
- **NFR-PERF-002** `[P]` Arranque en frío hasta el Menú principal ≤ 3 s en el dispositivo de referencia.
- **NFR-PERF-003** `[P]` La respuesta visual a un pulso se renderiza en el primer fotograma posterior al paso de simulación que lo procesa.
- **NFR-PERF-004** `[P]` Sin creación de nodos ni recursos por orbe o partícula durante la partida que provoque picos de recolección o carga (reutilización de objetos); verificable por ausencia de picos > 33.3 ms en el escenario de estrés.
- **NFR-PERF-005** `[P]` Memoria residente ≤ 300 MB y tamaño del paquete Android ≤ 80 MB.

### 8.2 Accesibilidad

- **NFR-A11Y-001** `[M][P]` Contraste: texto ≥ 4.5:1 respecto a su fondo; texto grande (≥ 24 dp o ≥ 18.7 dp en negrita) ≥ 3:1; orbes y elementos gráficos de juego ≥ 3:1 respecto al fondo azul noche. Verificado con `tools/palette_check.py`.
- **NFR-A11Y-002** `[M][P]` Ninguna información depende solo del color (símbolos, texto).
- **NFR-A11Y-003** `[P]` Destellos: ningún elemento destella más de 3 veces en cualquier ventana de 1 s, y no hay destellos de pantalla completa (ART-052).
- **NFR-A11Y-004** `[P]` Áreas táctiles de todos los botones ≥ 48 × 48 dp.
- **NFR-A11Y-005** `[P]` Tamaño mínimo de texto: 14 dp (ART-024).
- **NFR-A11Y-006** `[P]` El juego se puede jugar con una sola mano y un solo dedo.
- **NFR-A11Y-007** `[P]` «Reducir efectos» desactiva sacudidas de pantalla, reduce las partículas al 50 % y sustituye animaciones de rotación continua por estados estáticos (ART-050).

### 8.3 Privacidad y seguridad

- **NFR-PRIV-001** `[M]` La aplicación no realiza conexiones de red, no incluye analítica ni SDK de terceros de recogida de datos y no solicita permisos salvo `VIBRATE` en Android.
- **NFR-SEC-001** `[P]` El guardado es local y no se cifra ni firma: la manipulación por el propio usuario se acepta (juego individual sin competición en línea). La carga valida tipos y rangos para que un archivo manipulado no provoque fallos (FR-SAV-004).

### 8.4 Juego responsable

- **FR-RG-001** `[M]` Sin monetización, sin anuncios, sin cajas de botín, sin temporizadores de presión, sin rachas diarias, sin notificaciones de reenganche, sin penalizaciones por no jugar.
- **FR-RG-002** `[P]` Recordatorio de descanso (activable en Ajustes): cuando el tiempo de juego acumulado desde que se abrió la aplicación supera cada múltiplo de `break_reminder_interval`, la siguiente pantalla de Resultados muestra el aviso no bloqueante «Llevas *N* minutos jugando. ¿Qué tal un descanso?». (Propuesta M-06.)

### 8.5 Plataforma y presentación

- **NFR-PLAT-001** `[M][P]` Plataforma objetivo: teléfonos móviles. Android en v1; iOS queda fuera de v1 (D-03 → A).
- **NFR-PLAT-002** `[P]` Orientación vertical fija. Relaciones de aspecto soportadas: de 3:4 a 9:21 (ancho/alto entre 0.75 y 0.43). Respeto de las áreas seguras (muescas, barras del sistema).
- **NFR-PLAT-003** `[P]` Al perder el foco o pasar a segundo plano durante `PLAYING` o `RESUMING`, la partida pasa a `PAUSED` (T03/T07) y se silencia el audio hasta recuperar el foco.

### 8.6 Mantenibilidad y pruebas

- **NFR-MNT-001** `[M]` Todos los parámetros de `parameters.md` se leen de un recurso de configuración central; ninguno se escribe literalmente en el código de juego.
- **NFR-MNT-002** `[P]` La lógica de reglas (§3) es ejecutable y comprobable sin escenas ni renderizado (simulación headless), para permitir pruebas unitarias y simulaciones masivas con bots.

---

## 9. Criterios de éxito medibles

- **SC-001** `[M][P]` Duración de partida (objetivo 30–90 s): con los bots de referencia de `parameters.md` §7, en 1 000 partidas simuladas por bot: la mediana del bot NOVATO está en [30, 60] s y la mediana del bot EXPERTO es ≥ 75 s. Ninguna partida supera `session_max_time + sim_step` (si D-02 = A). Se valida además en pruebas con jugadores (pendiente, requiere dispositivo).
- **SC-002** `[P]` Cero violaciones de los invariantes FR-FAIR-001 a FR-FAIR-004 y FR-SEQ-005 en 10 000 partidas simuladas.
- **SC-003** `[P]` NFR-PERF-001 cumplido en el dispositivo de referencia.
- **SC-004** `[P]` En pruebas con jugadores nuevos, ≥ 80 % consigue ≥ 5 aciertos en su primera partida sin explicación externa (requiere jugadores; pendiente).
- **SC-005** `[M]` El 100 % de los botones de §4 se comporta como está especificado (matriz de pruebas de interfaz).
- **SC-006** `[P]` Ida y vuelta del guardado: el 100 % de los campos se conserva; los casos de archivo corrupto, versión futura y escritura interrumpida se recuperan según FR-SAV-003/004.
- **SC-007** `[P]` Cero errores y cero advertencias de script en la validación headless del proyecto, y cero referencias rotas a recursos.

---

## 10. Casos límite

| # | Caso | Comportamiento especificado |
|---|------|-----------------------------|
| E01 | Toque en el mismo paso en que un orbe objetivo alcanzaría el impacto | El pulso se resuelve antes del movimiento (FR-SIM-001): si el orbe está en zona al inicio del paso, se captura. |
| E02 | Toque sobre el botón Pausa | Solo pausa; no genera pulso (FR-INP-001). |
| E03 | Varios dedos a la vez | Un solo pulso (FR-INP-002). |
| E04 | Llamada entrante o paso a segundo plano en `RESUMING` | T07 → `PAUSED`. |
| E05 | El sistema termina la aplicación durante la partida | Partida perdida sin recompensas (FR-GS-007). |
| E06 | Se alcanza `session_max_time` durante PRISM | `COMPLETED`; PRISM termina (FR-PRM-005). |
| E07 | `E = 0` y `t ≥ session_max_time` en el mismo paso | `GAME_OVER` (FR-ENE-004). |
| E08 | Se activa el cuarto color con orbes en vuelo | Los orbes en vuelo no cambian; los elementos de `seq` ya generados no cambian (FR-SEQ-001). |
| E09 | PRISM se activa con un orbe en zona | Desde ese paso, la captura de ese orbe es un acierto PRISM. |
| E10 | PRISM termina con un orbe no objetivo en zona | Desde ese paso rigen las reglas normales; capturarlo es error de color. Mitigado por el aviso FR-PRM-004. |
| E11 | Puntuación igual al récord | No es récord (FR-SCO-004). |
| E12 | Saldo exactamente igual al precio | Compra permitida; saldo 0 (FR-PRG-012). |
| E13 | Misión completada en una partida abandonada | No cuenta (FR-MIS-003). |
| E14 | Restablecer progreso con misiones por reclamar | Se pierden; el diálogo lo advierte (FR-UX-081). |
| E15 | Guardado de una versión futura (bajada de versión de la app) | Copia de seguridad + perfil nuevo (FR-SAV-004). |
| E16 | Error de energía al 100 % | `E = 65`; no hay protección extra. |
| E17 | Toques continuos («spam») | Limitados por `pulse_cooldown`; capturan orbes no objetivo y provocan errores de color, por lo que no son una estrategia dominante. Verificado con el bot SPAM (`parameters.md` §7): su puntuación media debe ser inferior a la del bot NOVATO. |
| E18 | No tocar nunca | Cada orbe objetivo provoca una omisión; la partida termina por energía. |
| E19 | Saldo en el límite `crystals_balance_cap` | Excedente perdido y registrado (FR-PRG-002). |

---

## 11. Entidades clave

| Entidad | Atributos principales |
|---------|----------------------|
| Partida (`Session`) | estado, origen de pausa, semilla, `t`, `E`, `c`, `Q`, estado de combo, puntuación, `seq`, `idx`, racha no objetivo, temporizador PRISM, orbes en vuelo, estadísticas de partida |
| Orbe | id secuencial, tipo (color o `CRISTAL`), `r`, `θ`, instante de aparición |
| Configuración | todos los parámetros de `parameters.md` |
| Perfil | saldo, cosméticos poseídos y equipados, misiones activas, niveles por plantilla, semilla de misiones, estadísticas acumuladas, partidas jugadas |
| Ajustes | volúmenes, vibración, símbolos, reducir efectos, recordatorio |
| Cosmético | id, categoría, nombre, precio, por defecto |
| Plantilla de misión | id, tipo (en una partida / acumulada), métrica, fórmula de objetivo, fórmula de recompensa |
| Misión activa | plantilla, `k`, objetivo, recompensa, progreso, estado |

---

## 12. Historial del documento

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 0.1.0 | 2026-10-23 | Primer borrador completo para la fase Clarify. |
| 0.2.0 | 2026-10-23 | Aprobada: decisiones D-01…D-05 resueltas; propuestas aprobadas. Sin cambios de reglas. |
| 0.2.1 | 2026-10-23 | Aclaración de FR-MIS-005 (CR-002). |
| 0.2.2 | 2026-10-23 | Aclaración de FR-FAIR-006 (CR-003). |
