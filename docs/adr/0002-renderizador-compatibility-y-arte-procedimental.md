# ADR 0002: Renderizador Compatibility y arte procedimental 2D

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
D-04 A exige arte propio; el mandato pide halos, gradientes y partículas en móviles de gama media. Alternativas: Mobile (Vulkan) con glow 2D de entorno, o Compatibility con capas aditivas.

## Decisión
Renderizador Compatibility. Halos con capa aditiva (`CanvasItemMaterial.BLEND_MODE_ADD`) y texturas de gradiente radial generadas; partículas propias con búfer fijo.

## Consecuencias
Compatible con dispositivos sin Vulkan y con renderizado por software para capturas automáticas. Sin bloom real de posprocesado; el brillo es aproximado por capas.
