# ADR 0006: Audio sintetizado y versionado

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
D-04 A: audio original. Generarlo en tiempo de ejecución retrasaría el arranque (NFR-PERF-002).

## Decisión
`tools/gen_audio.py` (biblioteca estándar de Python, semilla fija) genera WAV mono de 22 050 Hz en `assets/audio/`. Se versionan los WAV y el script.

## Consecuencias
Reproducible y sin licencias de terceros; calidad musical limitada (R-05); se puede sustituir cada archivo sin tocar código.
