# ADR 0009: Exportación Android

- **Estado:** Aceptada
- **Fecha:** 2026-10-23

## Contexto
D-03 A: Android en v1. El entorno no permite descargar el SDK de Android.

## Decisión
Preset `Android` en `export_presets.cfg` (arm64-v8a y armeabi-v7a, vertical, permiso VIBRATE, exclusión de `tests/*` y `tools/*`). La generación del APK se documenta en `docs/export-android.md` y se registra como no ejecutable aquí.

## Consecuencias
El propietario debe exportar en una máquina con SDK o habilitar `dl.google.com` en la red del entorno.
