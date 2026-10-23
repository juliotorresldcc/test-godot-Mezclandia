# Exportación Android (NFR-PLAT-001, ADR 0009)

## 1. Estado en el entorno de desarrollo

La exportación **no se pudo ejecutar** en el contenedor: la política de red bloquea `dl.google.com` (SDK de Android) y no hay plantillas de exportación instaladas. Salida real de `godot --headless --path . --export-debug Android build/prism-pop.apk` (2026-10-23):

```
No export template found at the expected path:
No export template found at the expected path:
Invalid Android SDK path in Editor Settings. Missing 'platform-tools' directory!
Unable to find Android SDK platform-tools' adb command. Please check in the Android SDK directory specified in Editor Settings.
Invalid Android SDK path in Editor Settings. Missing 'build-tools' directory!
Unable to find Android SDK build-tools' apksigner command. Please check in the Android SDK directory specified in Editor Settings.
```

Godot reconoce y valida el preset `Android` de `export_presets.cfg`; solo faltan las herramientas externas.

## 2. Requisitos

| Elemento | Versión |
|----------|---------|
| Godot | 4.7.2-stable (editor o binario de línea de órdenes) |
| Plantillas de exportación | 4.7.2-stable (`Godot_v4.7.2-stable_export_templates.tpz`) |
| JDK | 17 o superior (verificado en el entorno: OpenJDK 21) |
| Android SDK | `platform-tools`, `build-tools` (incluye `apksigner`), una plataforma reciente |
| Keystore | De depuración (`debug.keystore`) o de publicación |

## 3. Pasos

1. Instala las plantillas: en el editor, *Editor → Manage Export Templates → Download and Install*, o descomprime el `.tpz` en `~/.local/share/godot/export_templates/4.7.2.stable/`.
2. Configura en *Editor Settings → Export → Android* las rutas `java_sdk_path` y `android_sdk_path`, y el keystore de depuración.
3. Exporta:
   ```sh
   godot --headless --path . --export-debug Android build/prism-pop.apk     # depuración
   godot --headless --path . --export-release Android build/prism-pop.apk   # publicación (requiere keystore de release)
   ```
4. Instala: `adb install -r build/prism-pop.apk`.

## 4. Contenido del preset

- Arquitecturas arm64-v8a y armeabi-v7a; orientación vertical (`project.godot`); modo inmersivo.
- Permisos: solo `VIBRATE`; `INTERNET` desactivado (NFR-PRIV-001).
- Exclusiones: `tests/*`, `tools/*`, `specs/*`, `docs/*`, `build/*`.
- `package/unique_name = com.prismpop.game` (provisional: **cámbialo** por tu identificador antes de publicar).
