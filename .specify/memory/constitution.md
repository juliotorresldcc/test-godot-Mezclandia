# Constitución del proyecto PRISM POP

- **Versión:** 1.0.0
- **Ratificada:** pendiente de aprobación del propietario del producto
- **Última modificación:** 2026-10-23

Esta constitución gobierna todo el trabajo sobre PRISM POP. Ante un conflicto entre este documento y cualquier otro artefacto, prevalece este documento. Ante un conflicto entre la especificación aprobada y el código, prevalece la especificación.

---

## 1. Principios

### P1. La especificación es la fuente de verdad
1. La especificación aprobada (`specs/<feature>/spec.md` y los documentos que referencia) prevalece sobre cualquier suposición del agente o del desarrollador.
2. El código se deriva de la especificación. Si el código y la especificación divergen, el código está mal, salvo que se siga el proceso de cambios (§3) para modificar la especificación.
3. No se implementa ninguna funcionalidad sin requisito aprobado, criterios de aceptación y dependencias identificadas.
4. Un requisito marcado como `[P]` (propuesta) o `[NEEDS CLARIFICATION]` **no está aprobado** y no puede implementarse hasta que el propietario lo apruebe.

### P2. Trazabilidad obligatoria
1. Todo requisito tiene un identificador único y estable (`FR-<ÁREA>-NNN`, `NFR-<ÁREA>-NNN`, `ART-NNN`, `SC-NNN`). Un identificador eliminado no se reutiliza.
2. Todo requisito funcional tiene criterios de aceptación comprobables (observables, con valores concretos y resultado binario aprobado/fallido).
3. Toda tarea referencia los requisitos que satisface. Una tarea sin requisito no se ejecuta.
4. Toda prueba referencia los requisitos que verifica. La matriz `REQ → SPEC → DESIGN → TASK → TEST → EVIDENCE` se mantiene actualizada.

### P3. Decisiones explícitas y registradas
1. Toda decisión técnica relevante se registra como ADR (`docs/adr/NNNN-titulo.md`) con contexto, alternativas, decisión y consecuencias.
2. Toda ambigüedad detectada y su resolución se registra en `specs/<feature>/clarifications.md`, indicando quién la resolvió y cuándo.
3. No se marca como resuelto algo que solo se ha supuesto. Una suposición es una propuesta hasta que se aprueba.
4. Las decisiones visuales importantes se documentan en la guía de dirección artística con criterios verificables y se validan mediante el procedimiento de revisión visual.

### P4. Dependencias antes que código
1. Antes de programar una tarea se identifican sus dependencias (otras tareas, recursos, herramientas, assets, versiones).
2. No se inicia una tarea cuyas dependencias no estén satisfechas.
3. Todo recurso necesario (audio, fuentes, imágenes) existe o tiene una estrategia de sustitución documentada y aprobada. Un recurso provisional se marca como tal y nunca se presenta como definitivo.

### P5. Calidad de código
1. Código modular, con responsabilidades únicas y claras, tipado estático (en GDScript: anotaciones de tipo en variables, parámetros y retornos) y compatible con la versión de Godot fijada en el plan.
2. Sin valores mágicos: los parámetros de juego viven en el recurso de configuración central definido en `parameters.md`.
3. Arquitectura proporcional al alcance: no se introducen patrones, servicios ni abstracciones que la especificación no justifique.
4. Los errores se corrigen en su origen. Prohibido ocultarlos con soluciones temporales, `try`/silenciado de errores, valores por defecto silenciosos o reintentos ciegos.
5. Prohibido sustituir una funcionalidad real por una simulación silenciosa (p. ej., un guardado que no escribe, un sonido que nunca suena sin avisar). Cualquier degradación (audio no disponible, vibración no disponible) está especificada y es visible para quien prueba.

### P6. Evidencia antes que afirmaciones
1. No se declara una prueba superada sin evidencia reproducible (comando ejecutado, salida registrada, captura real, fecha y versión).
2. No se declara terminada una funcionalidad parcialmente implementada.
3. No se inventan capturas, métricas, resultados ni ejecuciones. Las pruebas que no pueden ejecutarse en el entorno disponible se registran como **no ejecutables** con su motivo.
4. Una puntuación de análisis o de checklist satisfactoria no sustituye las pruebas reales del juego.

### P7. Rendimiento y accesibilidad son calidad de producto
1. Los objetivos de rendimiento (`NFR-PERF-*`) y accesibilidad (`NFR-A11Y-*`) son requisitos, no mejoras opcionales.
2. Ninguna funcionalidad se da por terminada si incumple un requisito de rendimiento o accesibilidad aplicable.

### P8. Seguridad, privacidad y juego responsable desde el diseño
1. Versión 1: sin red, sin analítica, sin recogida de datos personales, sin monetización real y sin anuncios.
2. Prohibidos los patrones oscuros: cajas de botín, recompensas aleatorias de pago, temporizadores de presión, penalizaciones por no jugar, notificaciones de reenganche.
3. Cualquier incorporación futura de monetización, red o datos requiere una especificación independiente y aprobada.

---

## 2. Flujo SDD y puertas de fase

GitHub Spec Kit **no está instalado** en el entorno (verificado el 2026-10-23). Hasta que el propietario decida lo contrario (decisión D-05), el flujo se ejecuta manualmente con archivos Markdown que siguen la estructura de directorios de Spec Kit. No se debe afirmar que se ha ejecutado un comando de Spec Kit que no se ha ejecutado.

| # | Fase | Artefactos (fuente de verdad) | Puerta de salida |
|---|------|-------------------------------|------------------|
| 0 | Constitución | `.specify/memory/constitution.md` | Ratificada por el propietario |
| 1 | Specify | `specs/001-prism-pop/spec.md`, `parameters.md`, `art-direction.md` | Todo requisito con ID y criterio de aceptación |
| 2 | Clarify | `specs/001-prism-pop/clarifications.md`, `checklists/requirements.md` | Cero hallazgos CRÍTICOS o ALTOS abiertos; propuestas que afectan al alcance aprobadas |
| 3 | Plan | `specs/001-prism-pop/plan.md`, `docs/adr/` | Versión de Godot verificada en el entorno; cada decisión con justificación |
| 4 | Design | `specs/001-prism-pop/design/` (contratos, estados) | Cada componente con responsabilidad, E/S, señales, errores y pruebas |
| 5 | Tasks | `specs/001-prism-pop/tasks.md` | Cada tarea con requisitos, dependencias, criterios y definición de terminado |
| 6 | Checklist/Analyze | `specs/001-prism-pop/analysis.md` | 100 % de requisitos obligatorios cubiertos por tareas; sin conflictos críticos |
| 7 | Implement | código + pruebas | Tarea a tarea, en orden de dependencias |
| 8 | Verify | `specs/001-prism-pop/traceability.md`, `test-report.md` | Evidencia por requisito |
| 9 | Converge | tareas correctivas | Todos los requisitos obligatorios verificados o excepciones aceptadas explícitamente |

Reglas de las puertas:
1. No se avanza a una fase si la puerta de la anterior no se ha superado.
2. Un problema descubierto en una fase posterior se corrige en el artefacto que le corresponde (p. ej., una regla ambigua descubierta al implementar se corrige en `spec.md`), y se repiten las fases afectadas.
3. Las puertas no se superan modificando artificialmente los resultados.

---

## 3. Política de gestión de cambios

1. **Registro.** Toda propuesta nueva (funcionalidad, cambio de regla, cambio de alcance) se registra en `clarifications.md` con el identificador `CR-NNN`.
2. **Evaluación de impacto.** Se enumeran requisitos, diseño, tareas, pruebas y assets afectados.
3. **Aprobación.** Los cambios que afectan al comportamiento visible, al alcance o a la arquitectura requieren aprobación explícita del propietario. Los cambios puramente editoriales (erratas, redacción sin cambio de significado) no la requieren, pero se registran en el historial de versiones del documento.
4. **Ajuste de parámetros.** Modificar el valor de un parámetro **dentro del rango permitido** documentado en `parameters.md` no requiere reaprobación de la especificación, pero se registra (valor anterior, valor nuevo, motivo, evidencia). Salir del rango permitido es un cambio de especificación.
5. **Propagación.** Tras aprobar un cambio se actualizan, en este orden: especificación → plan/ADR → diseño → tareas → pruebas → código.
6. **Prohibiciones.** No se incorporan funcionalidades en silencio. No se eliminan requisitos para reducir artificialmente el trabajo pendiente. No se cambia una regla funcional para que una implementación defectuosa parezca correcta.
7. **Versionado de documentos.** Cada artefacto de especificación lleva versión semántica: MAYOR = cambio incompatible de reglas o alcance; MENOR = requisito añadido o ampliado; PARCHE = aclaración sin cambio de comportamiento.

## 4. Política de revisión de código

1. Todo cambio se integra mediante pull request contra la rama principal.
2. La descripción del PR enumera los IDs de tarea y requisito que aborda y la evidencia de las pruebas.
3. Antes de solicitar revisión: validación del proyecto en Godot headless sin errores ni advertencias de script nuevas, pruebas automatizadas superadas, diff revisado de forma adversarial por el autor.
4. El revisor comprueba: correspondencia con la especificación, ausencia de valores mágicos, tipado, ausencia de errores silenciados, pruebas que verifican de verdad el requisito y documentación actualizada.
5. Un PR que cambia comportamiento sin actualizar la especificación se rechaza.

## 5. Política de validación

1. **Automática:** importación/validación headless del proyecto, pruebas unitarias de lógica pura (reglas, fórmulas, máquinas de estado, guardado), simulaciones deterministas con semilla, comprobación de referencias rotas y comprobación de la paleta.
2. **Ejecución:** arranque de escenas y recorrido de pantallas cuando el entorno lo permita.
3. **Visual:** procedimiento de revisión visual de `art-direction.md` §9 con capturas reales.
4. **Manual en dispositivo:** pruebas táctiles, rendimiento y vibración en dispositivo físico. Si el entorno no dispone de dispositivo, estas pruebas se registran como **no ejecutables** y quedan pendientes para el propietario.
5. Las pruebas se clasifican siempre en: aprobadas, fallidas, pendientes y no ejecutables en el entorno actual.

## 6. Gobernanza

1. El propietario del producto es la única autoridad para aprobar la especificación, los cambios de alcance y las excepciones.
2. Enmendar esta constitución requiere aprobación del propietario e incrementar su versión.
3. Idioma de la documentación: español. Identificadores de código: inglés (decisión del plan técnico).
