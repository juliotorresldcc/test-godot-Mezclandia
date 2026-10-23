# PRISM POP

Arcade híbrido hypercasual para móviles: partidas de 30 a 90 segundos, control de un toque, orbes de colores, combos, modo PRISM y cosméticos. Se construye con Godot mediante **Spec-Driven Development (SDD)**.

## Estado

**Fase actual: Clarify (ronda 1).** Todavía no hay proyecto Godot ni código de juego: según la constitución, la implementación no empieza hasta que la especificación esté aprobada y las decisiones críticas resueltas.

Decisiones pendientes del propietario: ver `specs/001-prism-pop/clarifications.md` §3–§5.

## Estructura

| Ruta | Contenido |
|------|-----------|
| `.specify/memory/constitution.md` | Constitución: principios, flujo SDD, puertas de fase, política de cambios, revisión y validación. |
| `specs/001-prism-pop/spec.md` | Especificación funcional (fuente de verdad de las reglas). |
| `specs/001-prism-pop/parameters.md` | Catálogo de parámetros ajustables, restricciones, cosméticos, misiones y bots de verificación. |
| `specs/001-prism-pop/art-direction.md` | Guía de dirección artística verificable y procedimiento de revisión visual. |
| `specs/001-prism-pop/clarifications.md` | Hallazgos, decisiones abiertas, propuestas y registro de cambios. |
| `specs/001-prism-pop/risks.md` | Registro de riesgos. |
| `specs/001-prism-pop/checklists/` | Checklist de calidad de la especificación e informe de paleta. |
| `specs/001-prism-pop/assets/moodboard.svg` | Moodboard esquemático generado (paleta, símbolos, maqueta de disposición). |
| `tools/palette_check.py` | Verifica contraste WCAG y distinción de colores (incluida simulación de daltonismo) leyendo la guía de arte. |
| `tools/spec_lint.py` | Verifica la coherencia entre documentos: IDs únicos y parámetros definidos. |

## Comprobaciones

Requieren solo Python 3 (biblioteca estándar):

```sh
python3 tools/spec_lint.py
python3 tools/palette_check.py --report specs/001-prism-pop/checklists/palette-report.txt --svg specs/001-prism-pop/assets/moodboard.svg
```

## Herramientas

- **GitHub Spec Kit:** no instalado. El flujo SDD se sigue manualmente con su estructura de directorios (decisión D-05).
- **Godot:** no instalado en el entorno. Versión propuesta: 4.7.2-stable (decisión D-03).
- Las instrucciones de ejecución y exportación se añadirán en la fase Plan.
