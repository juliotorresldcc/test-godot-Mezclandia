# PRISM POP

Arcade híbrido hypercasual para móviles: partidas de 30 a 90 segundos, control de un toque, orbes de colores, combos, modo PRISM y cosméticos. Hecho con **Godot 4.7.2** mediante **Spec-Driven Development (SDD)**.

**Cómo se juega:** el núcleo muestra un color. Toca la pantalla cuando un orbe de ese color esté dentro del anillo; deja pasar los demás. Encadena aciertos para multiplicar la puntuación y llenar el modo PRISM.

## Estado

| Fase | Estado |
|------|--------|
| Constitución, Specify, Clarify | Superadas (decisiones en `specs/001-prism-pop/clarifications.md` §7) |
| Plan, Design, Tasks, Analyze | Superadas |
| Implement / Verify | Alcance implementado; 97 pruebas automáticas, simulaciones y comprobaciones documentales aprobadas |
| Converge | Pendiente solo de lo que exige dispositivo, jugadores o tu aprobación (ver abajo) |

**Pendiente fuera de este entorno:** exportar el APK (falta el SDK de Android), medir el rendimiento y la vibración en un dispositivo, pruebas con jugadores y tu rúbrica de revisión visual. Detalle en `specs/001-prism-pop/test-report.md` §5.

## Ejecución

```sh
godot --path .                      # jugar en escritorio (clic o Espacio = toque; Esc = Atrás)
godot --path . --editor             # abrir en el editor
```

## Comprobaciones

```sh
tools/check_all.sh                  # documentos + sincronía código↔documentos + trazabilidad + 97 pruebas (≈ 15 s)
tools/check_all.sh --sim 1000       # + simulaciones SC-001/SC-002/E17 (≈ 75 s)
tools/check_all.sh --visual         # + capturas reales en docs/visual (requiere xvfb-run)
```

## Exportación

Android: `docs/export-android.md`. Verificación en dispositivo: `docs/perf-device.md`.

## Estructura

| Ruta | Contenido |
|------|-----------|
| `.specify/memory/constitution.md` | Constitución: principios, puertas de fase, políticas de cambio, revisión y validación |
| `specs/001-prism-pop/` | `spec.md` (reglas), `parameters.md` (valores), `art-direction.md` (arte), `clarifications.md` (decisiones y CR), `plan.md`, `design.md`, `tasks.md`, `analysis.md`, `traceability.md`, `test-report.md`, `visual-review.md`, `risks.md` |
| `docs/adr/` | Decisiones de arquitectura |
| `src/core/` | Reglas de juego puras y deterministas (`GameSession` y colaboradores) |
| `src/progression/` | Perfil, catálogos, progresión y guardado |
| `src/config/` | `GameConfig`: los 56 parámetros ajustables |
| `src/ui/`, `src/view/` | Pantallas, HUD, arena y efectos |
| `src/services/` | Audio y vibración (autoloads) |
| `assets/` | Fuentes OFL (Orbitron, Exo 2) y audio generado por `tools/gen_audio.py` |
| `tests/` | Pruebas (`unit/`), simulaciones (`sim/`), capturas (`visual/`), rendimiento (`perf/`) |
| `tools/` | Comprobaciones y generadores |
