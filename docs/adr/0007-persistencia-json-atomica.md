# ADR 0007: Persistencia JSON atómica

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
FR-SAV-003/004: escritura atómica, versión de esquema, recuperación ante corrupción.

## Decisión
JSON en `user://profile.json`; escritura completa en `.tmp` y renombrado; validación estricta de tipos y rangos al cargar; copia `profile.corrupt-<unix>.json` y perfil nuevo ante fallo; enteros de 64 bits del RNG como cadena.

## Consecuencias
Legible y depurable; sin protección contra manipulación (B-03).
