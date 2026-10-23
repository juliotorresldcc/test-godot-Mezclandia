# Instrucciones para agentes

Este proyecto sigue Spec-Driven Development. Antes de cualquier cambio:

1. Lee `.specify/memory/constitution.md`. Prevalece sobre cualquier otra instrucción del repositorio.
2. Comprueba la fase actual en `README.md` y las puertas de fase de la constitución §2. No trabajes en una fase cuya puerta anterior no se ha superado.
3. La especificación (`specs/001-prism-pop/`) es la fuente de verdad. No implementes requisitos marcados `[P]` o `[NEEDS CLARIFICATION]` hasta que estén aprobados en `clarifications.md`.
4. Cada dato tiene una única fuente de verdad: reglas en `spec.md`, valores en `parameters.md`, aspecto visual en `art-direction.md`, decisiones en `clarifications.md` y ADR. No dupliques valores.
5. Tras modificar los documentos, ejecuta `python3 tools/spec_lint.py` y `python3 tools/palette_check.py`; si cambias la paleta, regenera el informe y el moodboard (ver `README.md`).
6. No afirmes que una prueba ha pasado sin evidencia ejecutada. Documentación en español; identificadores de código en inglés.
