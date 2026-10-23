# Análisis previo a la implementación: PRISM POP v1

- **Fecha:** 2026-10-23 · **Artefactos:** spec 0.2.0, parameters 0.1.0, art-direction 0.1.0, plan 1.0.0, design 1.0.0, tasks 1.0.0

## Comprobaciones ejecutadas

| Comprobación | Resultado |
|--------------|-----------|
| `tools/spec_lint.py` | APROBADO: 187 requisitos, 0 duplicados. (La cifra «64 parámetros» registrada inicialmente incluía por error las 8 filas de cosméticos; el script se corrigió y son 56 parámetros.) |
| `tools/palette_check.py` | APROBADO (ver `checklists/palette-report.txt`) |
| `tools/trace_check.py` (requisitos → tareas) | **Primera ejecución: FALLIDO**, 31 requisitos sin tarea (rendimiento, accesibilidad, ART-002…004, ART-070, FR-SEQ-005, FR-FAIR-003/004, FR-ARENA-*, FR-STAT-011, FR-RG-001, NFR-MNT-002), además de 2 defectos del propio script (no interpretaba `002/003` ni los IDs `SC-NNN`). Corregido en `tasks.md` (nueva tarea T23 de rendimiento y ampliación de T09, T12, T13, T16, T18, T20) y en el script. **Ejecución final: APROBADO, 187/187.** |

## Conflictos y riesgos detectados

| ID | Hallazgo | Tratamiento |
|----|----------|-------------|
| AN-01 | La emulación de ratón desde táctil de Godot duplicaría los pulsos. | Resuelto en el diseño (ADR 0005). |
| AN-02 | El estado del RNG de misiones es de 64 bits y el JSON de Godot lo convertiría en coma flotante (pérdida de precisión). | Se guarda como cadena (ADR 0007). |
| AN-03 | Sumar `sim_step` repetidamente acumularía error y desplazaría el fin de los 90 s. | `t = pasos · sim_step` (ADR 0003). |
| AN-04 | Sin SDK de Android, T21 no puede generar el APK. | T21 parcialmente bloqueada; registrado en riesgos (R-02) y en el plan. |
| AN-05 | NFR-PERF-001/002/005 y SC-003/SC-004 requieren dispositivo o jugadores. | T23 y T20 producen la medición indicativa y el procedimiento; la verificación queda como no ejecutable. |

## Veredicto

Sin problemas críticos pendientes; las decisiones de alcance están resueltas (`clarifications.md` §7). **Se autoriza la fase Implement** en el orden de `tasks.md`.
