# Checklist de calidad de la especificación: PRISM POP v1

- **Fecha:** 2026-10-23 · **Fase:** Clarify, ronda 1
- **Artefactos revisados:** `spec.md` 0.1.0, `parameters.md` 0.1.0, `art-direction.md` 0.1.0, `clarifications.md` 0.1.0
- **Evidencia automática:** `python3 tools/spec_lint.py` → APROBADO (187 requisitos: 122 FR, 19 NFR, 7 SC, 39 ART; 64 parámetros, todos citados; 0 IDs duplicados; 0 parámetros sin definir). `python3 tools/palette_check.py` → APROBADO (ver `palette-report.txt`).

Marcado: `[x]` cumplido con evidencia · `[ ]` no cumplido · `[~]` cumplido en borrador, pendiente de aprobación del propietario.

## Contenido

- [x] Alcance y fuera de alcance explícitos (spec §0).
- [x] Sin detalles de implementación en las reglas (no se nombran nodos, clases ni API de Godot; solo `--audio-driver Dummy` como método de prueba en FR-AUD-004).
- [~] Todas las secciones obligatorias del mandato (4.1–4.6) están cubiertas: reglas (§3), parámetros (`parameters.md`), UX (§4), arte (`art-direction.md`), audio/vibración (§6), progresión (§7).
- [x] Todas las fórmulas incluyen variables, unidades, límites, ejemplos numéricos y redondeo (puntuación FR-SCO-001/002, dificultad FR-DIF-001, energía FR-ENE-001, PRISM FR-PRM-001, cristales FR-PRG-001, precisión FR-STAT-002, ángulo FR-ORB-003, misiones parameters §6).
- [x] Todos los parámetros con tipo, unidad, valor por defecto, mínimo, máximo, efecto y dependencias (`parameters.md` §2 y §4).

## Completitud de requisitos

- [ ] **Sin marcas `[NEEDS CLARIFICATION]`.** Quedan 6 marcas (D-01 ×1, D-02 ×4, D-03 ×1).
- [~] Cada requisito tiene un criterio de aceptación comprobable: 23 con línea explícita; los 125 restantes, mediante la convención de spec «Convención de criterios de aceptación» (pendiente de aprobación). Subjetivos con procedimiento propio: FR-ART-001, NFR-A11Y-006.
- [x] Identificadores únicos (verificado por `spec_lint.py`).
- [x] Estados y transiciones de partida completos y cerrados (FR-GS-001/002: 7 estados, 10 transiciones, el resto prohibidas).
- [x] Estados del combo completos (FR-CMB-001).
- [x] Tabla de resolución exhaustiva: evento × modo × tipo de orbe (FR-RES-001).
- [x] Orden de resolución por paso definido (FR-SIM-001) y casos simultáneos cubiertos (E01, E06, E07, E09, E10).
- [x] Prevención de situaciones imposibles con invariantes comprobables (FR-FAIR-001…006, FR-SEQ-005).
- [x] Entradas simultáneas y repetidas definidas (FR-INP-002/003).
- [x] Cada botón visible tiene comportamiento definido (§4.3–4.9); estados vacíos y errores definidos (FR-UX-012, FR-UX-062, FR-UX-071, FR-SAV-005).
- [x] Degradación sin audio y sin vibración definida (FR-AUD-004, FR-HAP-003).
- [x] Reglas de guardado: qué, cuándo, atomicidad, versiones, corrupción (FR-SAV-*).
- [x] Casos límite enumerados (spec §10, 19 casos).

## Preparación para la fase Plan

- [ ] **Decisiones CRÍTICAS resueltas:** D-01 y D-02 abiertas.
- [ ] **Decisiones ALTAS resueltas:** D-03 y D-04 abiertas.
- [ ] Propuestas M-01…M-13 y valores B-01…B-05 aprobados.
- [x] Criterios de éxito medibles definidos (SC-001…SC-007), con método de verificación.
- [~] Requisitos visuales con forma de evaluación (art-direction §9); tamaño de orbe pendiente de revisión en dispositivo (H-21/M-13).
- [ ] Constitución ratificada por el propietario.

## Pruebas no ejecutables en el entorno actual (identificadas ya)

- Rendimiento en dispositivo físico (NFR-PERF-001/002/005, SC-003).
- Vibración real (FR-HAP-001).
- Pruebas con jugadores (SC-001 parte manual, SC-004).
- Exportación e instalación en iOS (si D-03 = B).

## Resultado

**La fase Clarify NO supera su puerta de salida.** Bloqueantes: D-01, D-02 (críticas), D-03, D-04 (altas) y la aprobación de las propuestas. No se inicia la fase Plan.
