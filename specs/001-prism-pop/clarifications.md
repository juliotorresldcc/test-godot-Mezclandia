# Registro de clarificaciones, decisiones y cambios: PRISM POP v1

- **Versión:** 0.2.0
- **Fecha:** 2026-10-23
- **Fase:** Clarify cerrada (ronda 1 resuelta)
- **Fuente de verdad de:** hallazgos de la revisión de la especificación, decisiones abiertas y resueltas, propuestas pendientes y solicitudes de cambio (`CR-NNN`).

## 1. Método

Se revisaron el mandato del propietario y los artefactos `spec.md`, `parameters.md` y `art-direction.md` buscando: requisitos vagos, contradicciones, valores sin definir, casos límite, estados imposibles, requisitos sin criterio de aceptación, dependencias de suposiciones, funcionalidades no verificables, decisiones que afectan a la arquitectura y requisitos visuales sin forma de evaluación. Se ejecutaron dos comprobaciones con herramientas reales: `tools/palette_check.py` (informe en `checklists/palette-report.txt`) y el cálculo numérico de las restricciones C4/C10 de `parameters.md` §3. También se renderizó el moodboard con Chromium para revisarlo visualmente.

Severidades:
- **CRÍTICA:** impide especificar o implementar el núcleo del juego. Bloquea la fase Plan.
- **ALTA:** afecta a la arquitectura, al alcance o a la viabilidad. Bloquea la fase Plan.
- **MEDIA:** afecta al comportamiento visible; existe una propuesta concreta que requiere aprobación.
- **BAJA:** detalle de bajo impacto; existe un valor por defecto propuesto.

## 2. Hallazgos

| ID | Severidad | Hallazgo | Estado | Resolución / decisión |
|----|-----------|----------|--------|-----------------------|
| H-01 | CRÍTICA | El mandato exige «controles de un toque» pero no define qué hace el toque (cambiar el color del núcleo, capturar, rotar…). Toda la sección de reglas depende de ello. | Resuelto | D-01 → A |
| H-02 | CRÍTICA | El mandato exige partidas de 30–90 s pero no define el mecanismo que las limita. Sin límite, un jugador experto puede superar los 90 s indefinidamente. | Resuelto | D-02 → A |
| H-03 | ALTA | Godot no está instalado en el entorno. La versión estable más reciente publicada es **4.7.2-stable** (consultado en los tags del repositorio oficial el 2026-10-23). No se puede validar ni ejecutar nada sin descargarlo. | Resuelto | D-03 → A |
| H-04 | ALTA | No se define la plataforma objetivo concreta (Android, iOS o ambas). La exportación para iOS requiere macOS y Xcode, no disponibles en este entorno Linux. | Resuelto | D-03 → A |
| H-05 | ALTA | No existen recursos (audio, música, tipografías, arte). El mandato no indica su origen ni su licencia. | Resuelto | D-04 → A |
| H-06 | MEDIA | GitHub Spec Kit no está instalado (última versión publicada v1.2.3). Instalarlo modifica el entorno y requiere autorización. Mientras tanto se sigue un flujo SDD manual con su estructura de directorios. | Resuelto | D-05 → A |
| H-07 | MEDIA | «Controles de un toque» frente a la existencia de botones (Pausa, menús). | Aprobado | Interpretación propuesta: «un toque» se refiere al control de juego; la interfaz usa botones convencionales (FR-INP-001). |
| H-08 | MEDIA | El mandato no define cómo se activa PRISM ni qué hace exactamente. | Aprobado | M-01 |
| H-09 | MEDIA | «Eventos especiales» sin definir. | Aprobado | M-02 |
| H-10 | MEDIA | No se define qué ocurre con las recompensas al abandonar una partida. Sin regla, «salir y reintentar» podría explotarse. | Aprobado | M-03 |
| H-11 | MEDIA | No se define el tratamiento de toques sin objetivo ni de toques repetidos. | Aprobado | M-04 |
| H-12 | MEDIA | El mandato no incluye aprendizaje (onboarding); sin él, la mecánica no se entiende en la primera partida (SC-004). Añadirlo es una ampliación de alcance. | Aprobado | M-05 |
| H-13 | MEDIA | El juego responsable se pide «desde el diseño» sin medidas concretas más allá de no monetizar. | Aprobado | M-06 |
| H-14 | MEDIA | Idioma(s) del juego no definidos. | Aprobado | M-07 |
| H-15 | MEDIA | Los objetivos de rendimiento no son verificables sin un dispositivo de referencia. | Aprobado | M-08 |
| H-16 | MEDIA | Misiones: no se define si son diarias, cómo se reclaman ni cómo se reponen. | Aprobado | M-09 |
| H-17 | MEDIA | Catálogo de cosméticos y precios no definidos. | Aprobado | M-10 |
| H-18 | MEDIA | Fórmula de cristales no definida. | Aprobado | M-11 |
| H-19 | MEDIA | Ubicación del indicador de siguiente objetivo: junto al núcleo competiría visualmente con los orbes reales de la zona. | Aprobado | M-12 |
| H-20 | MEDIA | El script de paleta detecta pares poco distinguibles con daltonismo: magenta/violeta en protanopía (ΔE 10.9) y cian/magenta en deuteranopía (ΔE 16.4). | Aprobado | Los símbolos (ART-002) resuelven la distinción; se propone que «Símbolos de color» esté activo por defecto (B-05). |
| H-21 | MEDIA | Al renderizar el moodboard, con `orb_radius = 0.05 R` el orbe mide unos 17 dp de diámetro en un teléfono de 1080 px y su símbolo unos 10 dp: probablemente poco legible. | Aprobado | M-13 |
| H-22 | MEDIA | No hay pantalla de estadísticas en el mandato, pero sí «estadísticas» en progresión. | Aprobado | Mostrarlas en la pantalla Misiones (FR-STAT-011). Incluido en M-09. |
| H-23 | BAJA | Cuenta atrás al reanudar no definida. | Aprobado | B-01 |
| H-24 | BAJA | Confirmación al reiniciar desde Pausa no definida. | Aprobado | B-02 |
| H-25 | BAJA | Protección del guardado frente a manipulación no definida. | Aprobado | B-03 |
| H-26 | BAJA | Empate con el récord no definido. | Aprobado | B-04 |
| H-27 | BAJA | Duraciones exactas de partida no verificables sin jugadores reales. | Aprobado | Verificación en dos niveles: simulación con bots (SC-001) + pruebas con jugadores (pendiente; requiere dispositivo). Las tasas de error de los bots son suposiciones a calibrar. |
| H-28 | BAJA | Posible contradicción entre «efectos reactivos» y accesibilidad (destellos). | Resuelto | Limitador de destellos (ART-052) y «Reducir efectos» (ART-050). Pendiente solo de la aprobación general. |
| H-29 | BAJA | «Partículas controladas» no cuantificado. | Resuelto | Presupuesto de 300 partículas (ART-051). |

Ningún hallazgo se ha marcado como resuelto por suposición: los «Resuelto en borrador» tienen ya una regla verificable escrita, pero siguen sujetos a la aprobación general de la especificación.

## 3. Decisiones bloqueantes — ronda 1 (máximo 5)

### D-01 · Mecánica del toque (CRÍTICA)

¿Qué hace el único toque del jugador?

| Opción | Descripción | Consecuencias |
|--------|-------------|---------------|
| **A — Pulso de captura (recomendada; redactada en `spec.md` §3)** | El núcleo muestra el color objetivo. Los orbes llegan desde el borde. Al tocar, se captura el orbe que esté en el anillo de captura. Hay que tocar solo cuando el orbe es del color correcto y dejar pasar los demás. | Combina decisión (¿toco o no?) y precisión temporal. Encaja con «secuencia de colores y anticipación», combos y errores claros. Reglas ya especificadas con invariantes de equidad demostrables. |
| B — Cambio de color del núcleo | Cada toque hace avanzar el color del núcleo en un ciclo fijo; cada orbe que llega debe coincidir con el color del núcleo en el impacto. | Mecánica muy conocida (menos diferenciación). Con 4 colores, a veces hacen falta 3 toques rápidos: menos «un toque». La secuencia de objetivos pierde sentido. Habría que rehacer §3 entera. |
| C — Anillo segmentado giratorio | El núcleo tiene un anillo de 4 segmentos de color; cada toque lo gira 90°; el orbe debe impactar en el segmento de su color. | Más exigente espacialmente; la secuencia de objetivos desaparece. Habría que rehacer §3 y la dirección artística del núcleo. |

### D-02 · Finalización y duración de la partida (CRÍTICA)

| Opción | Descripción | Consecuencias |
|--------|-------------|---------------|
| **A — Energía + límite de 90 s (recomendada; redactada)** | La partida termina al agotarse la energía (derrota) o al llegar a 90 s (`COMPLETED`, «¡Prisma estable!», +5 cristales). | Garantiza el máximo de 90 s; añade un objetivo de «supervivencia» satisfactorio. La puntuación tiene techo práctico. |
| B — Solo energía (sin límite) | La partida termina únicamente por energía. La dificultad máxima a partir de los 60 s hace que la mayoría pierda antes de 90 s. | Clásico arcade de récord sin techo; el rango 30–90 s pasa a ser un objetivo estadístico (SC-001), no una garantía. Se elimina `COMPLETED`. |
| C — Temporizador fijo sin energía | Toda partida dura exactamente N s (p. ej. 60); los errores solo restan puntos o combo. | Duración garantizada pero sin tensión de derrota; hay que rediseñar errores y puntuación. |

### D-03 · Plataformas, motor y herramientas (ALTA)

Propuesta: **Godot 4.7.2-stable** (última estable publicada), **GDScript con tipado estático**, **Android como plataforma de exportación v1**; iOS queda como objetivo posterior porque su exportación requiere macOS/Xcode.

Necesito tu autorización para **descargar en el entorno** el binario de Godot 4.7.2 para Linux (para validación headless y pruebas) y, cuando llegue la fase de exportación, sus plantillas de exportación y el SDK de Android.

| Opción | Consecuencias |
|--------|---------------|
| **A — Godot 4.7.2 + GDScript + Android (recomendada)** | Validación y pruebas automáticas posibles aquí; APK verificable aquí salvo las pruebas en dispositivo físico. |
| B — Igual que A, pero Android + iOS en v1 | El proyecto se prepara para iOS, pero la exportación y las pruebas de iOS serán **no ejecutables** en este entorno; quedan a tu cargo. |
| C — Otra versión o C# | C# en móvil sigue teniendo limitaciones de exportación; requiere justificación en ADR. |

### D-04 · Origen de los recursos (audio, tipografías, arte) (ALTA)

| Opción | Consecuencias |
|--------|---------------|
| **A — Recursos originales generados en el proyecto (recomendada)** | Arte procedimental (shaders, formas vectoriales, partículas: encaja con la estética de luz), efectos de sonido sintetizados mediante scripts reproducibles y fuentes OFL (Orbitron, Exo 2) incluidas con su licencia. Sin dependencias de licencias de terceros salvo OFL. La música sería sencilla (bucles sintetizados); la calidad musical es el principal riesgo (R-05). |
| B — Los aportas tú | Mejor calidad potencial; la implementación de audio y arte depende de tus entregas (dependencia externa en las tareas). |
| C — Paquetes CC0 de terceros | Rápido; hay que registrar origen y licencia de cada archivo, y la identidad visual/sonora será menos propia. |

### D-05 · Herramienta SDD (MEDIA, de proceso)

| Opción | Consecuencias |
|--------|---------------|
| **A — Continuar con el flujo Markdown actual (recomendada)** | Ya sigue la estructura de Spec Kit (`.specify/memory/`, `specs/001-…/`). Sin cambios en el entorno. Los análisis de cobertura los hago con scripts propios reproducibles. |
| B — Instalar Spec Kit v1.2.3 (`uvx --from git+https://github.com/github/spec-kit.git@v1.2.3 specify init --here`) | Comandos oficiales (`/speckit.*`). Puede generar plantillas y archivos que habría que conciliar con los ya creados; modifica el entorno y el repositorio. |

## 4. Propuestas pendientes de aprobación (no bloquean el Plan si se aprueban en bloque)

| ID | Propuesta | Requisitos afectados |
|----|-----------|----------------------|
| M-01 | PRISM se activa **automáticamente** al llenar la carga (25 aciertos con valores por defecto); dura 6 s; todas las capturas son aciertos con puntuación ×2; los impactos no penalizan. Alternativa: activación manual, que exigiría un segundo gesto y rompería el «un toque». | FR-PRM-* |
| M-02 | Un único evento especial en v1: el **orbe cristal** (aparece a partir de 10 s, 4 % por aparición, máx. 5 por partida, +3 cristales, +20 de carga PRISM). | FR-EVT-*, FR-SEQ-004 |
| M-03 | Abandonar (Reiniciar o Salir al menú desde Pausa) **no otorga recompensas** ni cuenta para misiones o récord. | FR-GS-006 |
| M-04 | El pulso vacío **no penaliza**, pero activa un tiempo de recarga de 0.15 s; los toques durante la recarga se ignoran. El «spam» se penaliza solo, porque captura orbes incorrectos. | FR-INP-003, E17 |
| M-05 | **Ampliación de alcance:** indicación de aprendizaje en `PRE_START` durante las 3 primeras partidas. | FR-UX-031 |
| M-06 | **Ampliación de alcance:** recordatorio de descanso no bloqueante cada 30 min de juego (activable/desactivable, activo por defecto). | FR-RG-002 |
| M-07 | Solo **español** en v1, con todos los textos en tabla de traducción para añadir idiomas después. | FR-UX-004 |
| M-08 | Dispositivo de referencia para rendimiento: Android de gama media de 2021 (4 GB de RAM, GPU de clase Adreno 610 / Mali-G52). Las pruebas en dispositivo físico serán **no ejecutables** en este entorno; quedarían a tu cargo. | NFR-PERF-* |
| M-09 | Misiones: 3 huecos, 7 plantillas con nivel creciente, **reclamo manual**, sin caducidad ni misiones diarias; estadísticas mostradas en la pantalla Misiones. | FR-MIS-*, FR-STAT-011 |
| M-10 | Catálogo: 2 categorías (núcleos y estelas) × 4 elementos; precios 0 / 40 / 120 / 300. | FR-PRG-010, parameters §5 |
| M-11 | Cristales = `floor(puntuación/1000)` + 3 por orbe cristal + 5 por `COMPLETED`. | FR-PRG-001 |
| M-12 | Indicador SIGUIENTE bajo la arena (no en el núcleo), sujeto a revisión visual. | ART-014, FR-CORE-003 |
| M-13 | Revisar el tamaño de los orbes en la primera revisión visual en dispositivo; si el símbolo no se lee, subir `orb_radius` (rango hasta 0.07). Por la restricción C2 (`core_radius + orb_radius ≤ zone_inner_radius`), con 0.06 hay que bajar `core_radius` a 0.11, y con 0.07 bajarlo a 0.10 o subir `zone_inner_radius` a 0.19 (C5 se sigue cumpliendo: 0.35 ≥ 0.14). | ART-015, parameters §2.1 |

## 5. Valores por defecto de bajo impacto (se aplican salvo objeción)

| ID | Valor por defecto |
|----|-------------------|
| B-01 | Cuenta atrás de 1.5 s («3, 2, 1») al reanudar. |
| B-02 | «Reiniciar» desde Pausa sin diálogo de confirmación. |
| B-03 | Guardado sin cifrado ni firma; se valida al cargar para evitar fallos. |
| B-04 | Un empate con el récord no es récord. |
| B-05 | «Símbolos de color» activo por defecto (ver H-20). |

## 6. Solicitudes de cambio

Ninguna todavía.

## 7. Historial de resoluciones

| Fecha | ID | Decisión | Decidido por |
|-------|----|----------|--------------|
| 2026-10-23 | D-01 | Opción A: pulso de captura en zona. | Propietario, mediante la instrucción «haz el proyecto» tras la presentación de las opciones recomendadas. |
| 2026-10-23 | D-02 | Opción A: energía + límite de 90 s (`COMPLETED`). | Ídem. |
| 2026-10-23 | D-03 | Opción A: Godot 4.7.2-stable, GDScript tipado, Android en v1. Descarga de Godot autorizada y realizada (binario oficial, commit `ed1daf0bf`). | Ídem. |
| 2026-10-23 | D-04 | Opción A: arte procedimental, audio sintetizado con script reproducible y fuentes OFL (Orbitron y Exo 2, obtenidas de los paquetes npm `@fontsource/*` 5.3.0 porque GitHub raw está bloqueado en el entorno). | Ídem. |
| 2026-10-23 | D-05 | Opción A: flujo Markdown sin instalar Spec Kit. | Ídem. |
| 2026-10-23 | M-01…M-13 | Aprobadas tal como están redactadas, incluidas las ampliaciones de alcance M-05 (aprendizaje) y M-06 (recordatorio de descanso). | Ídem. |
| 2026-10-23 | B-01…B-05 | Aplicados los valores por defecto. | Ídem. |
| 2026-10-23 | Constitución 1.0.0 | Ratificada. | Ídem. |

> Nota de trazabilidad: el propietario no eligió opción por opción; respondió «haz el proyecto» a la presentación de las recomendaciones. Se interpreta como aprobación de todas las opciones marcadas como recomendadas. Si alguna no refleja su intención, se tramitará como solicitud de cambio (constitución §3).
