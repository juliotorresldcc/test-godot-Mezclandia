# ADR 0004: Configuración central `GameConfig`

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
NFR-MNT-001 prohíbe valores mágicos; `parameters.md` es la fuente de verdad documental.

## Decisión
Un `Resource` `GameConfig` con todos los parámetros y sus valores por defecto, más `validate()` con las restricciones C1–C12. `tools/check_sync.py` compara sus valores con `parameters.md`.

## Consecuencias
Dos representaciones (documento y código) sincronizadas por una comprobación automática que falla ante cualquier diferencia.
