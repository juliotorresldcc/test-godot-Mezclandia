# ADR 0005: Interfaz construida por código; gestión de entrada

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
Hay 8 pantallas con disposición dependiente de dp y área segura; los `.tscn` escritos a mano son frágiles. La emulación de ratón desde táctil de Godot duplica eventos.

## Decisión
Pantallas como `Control` construidos por código con un `Theme` generado y `Layout` para dp/área segura. Pulsos desde `InputEventScreenTouch` y ratón no emulado; se excluye el rectángulo del botón Pausa.

## Consecuencias
Disposición comprobable por pruebas; menos edición visual en el editor. Botones siguen funcionando por táctil gracias a la emulación de ratón.
