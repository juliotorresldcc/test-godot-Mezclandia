# ADR 0001: GDScript con tipado estático

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
El juego debe exportarse a Android y validarse headless. Alternativas: GDScript, C# (.NET), GDExtension (C++).

## Decisión
GDScript con anotaciones de tipo obligatorias: el proyecto eleva a error la advertencia `untyped_declaration`; la inferencia con `:=` está permitida.

## Consecuencias
Sin cadena de compilación extra; exportación móvil sin limitaciones. Rendimiento suficiente para ≤ 6 orbes y 300 partículas. Simulaciones masivas más lentas que en C# (aceptable: minutos).
