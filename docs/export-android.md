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

## 1 bis. Exportación realizada en el entorno (2026-10-23)

Con `dl.google.com` bloqueado, se usaron las herramientas oficiales de AOSP empaquetadas por Ubuntu (`apt-get install apksigner adb zipalign aapt`) y una estructura mínima de SDK:

```
/opt/android-sdk/platform-tools/adb            -> /usr/bin/adb (34.0.4)
/opt/android-sdk/build-tools/34.0.0/apksigner  -> /usr/bin/apksigner
/opt/android-sdk/build-tools/34.0.0/zipalign   -> /usr/bin/zipalign
```

Plantillas 4.7.2 descargadas de la publicación oficial en GitHub. Rutas configuradas en `~/.config/godot/editor_settings-4.7.tres` (`android_sdk_path`, `java_sdk_path` = OpenJDK 21, keystore de depuración que genera Godot).

Resultado de `godot --headless --path . --export-debug Android build/prism-pop-debug.apk`:

| Comprobación | Resultado |
|--------------|-----------|
| Tamaño | 58,6 MB (≤ 80 MB, NFR-PERF-005) |
| SHA-256 | `6cb2cc9453d4dd5464e267bd44a64f2a541b9598e811250fbbcff93a8dd2f43b` |
| `apksigner verify` | Verifica: esquemas v2 y v3; certificado de depuración de Godot |
| `aapt dump badging` | `com.prismpop.game` 1.0.0 (code 1); minSdk 24; targetSdk 36; solo `VIBRATE`; `screenOrientation` vertical; ABI arm64-v8a y armeabi-v7a; actividad lanzadora presente |
| Contenido | Sin archivos de `tests/`, `tools/`, `specs/` ni `docs/` |

Es una compilación de **depuración**: firmada con el keystore de depuración (instalable directamente, no apta para Google Play) y con la etiqueta de semilla visible (FR-SIM-003). Para publicar, genera tu propio keystore de release y usa `--export-release`.

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
