# ADR 0008: Ejecutor de pruebas propio

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
Se necesitan pruebas headless sin depender de complementos de terceros.

## Decisión
`tests/run_tests.gd` (extiende `SceneTree`) descubre `tests/unit/test_*.gd`, ejecuta métodos `test_*` y termina con código 1 si algo falla. Simulaciones y capturas en scripts separados.

## Consecuencias
Sin funciones avanzadas (dobles, informes JUnit); suficiente para el alcance.
