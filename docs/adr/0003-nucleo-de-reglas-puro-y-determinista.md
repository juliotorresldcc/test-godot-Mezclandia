# ADR 0003: Núcleo de reglas puro y determinista

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
SC-001/SC-002 requieren miles de partidas simuladas y FR-SIM-002 exige determinismo.

## Decisión
Las reglas viven en clases `RefCounted` sin nodos (`GameSession` y sus colaboradores). Paso fijo; el tiempo se deriva de un contador entero de pasos; un RNG con semilla por partida. La presentación solo escucha señales y lee estado.

## Consecuencias
Pruebas rápidas y deterministas; la vista nunca modifica reglas. Exige disciplina: ninguna regla en scripts de vista.
