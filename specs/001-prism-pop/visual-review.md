# Revisión visual: PRISM POP v1

- **Fecha:** 2026-10-23 · **Procedimiento:** art-direction §9 · **Capturas:** `docs/visual/` (reales, Xvfb + OpenGL 4.5/llvmpipe; generadas con `tests/visual/capture.gd`).
- **Revisor:** agente (lista objetiva). **La rúbrica subjetiva (§9.4) corresponde al propietario y está pendiente.**

## 1. Comprobaciones automáticas (§9.2)

| Comprobación | Resultado |
|--------------|-----------|
| Contraste de la paleta | APROBADO (`palette-report.txt`) |
| HUD fuera de la arena en `PLAYING` (5 resoluciones + HUD real) | APROBADO (TEST-LAY-01, TEST-LAY-03) |
| Áreas táctiles ≥ 48 dp y textos ≥ 14 dp | APROBADO (TEST-LAY-01) |

## 2. Lista objetiva por captura (§9.3)

| Captura | Jerarquía de luminancia | Grupos de HUD ≤ 7 | Solo paleta | Símbolos | Observaciones |
|---------|------------------------|-------------------|-------------|----------|---------------|
| 01 Inicio | ✓ | — | ✓ | — | Logotipo legible. |
| 02 Menú | ✓ | — | ✓ | — | Botón primario dominante; récord y saldo legibles. |
| 03 PRE_START | ✓ | 6 | ✓ | ✓ | Indicación y «Toca para empezar» sobre la arena (permitido por CR-003). |
| 04 Orbe en zona | ✓ | 6 | ✓ | ✓ | Zona resaltada con el orbe dentro; estela en cuña que se desvanece. |
| 05 Combo | ✓ | 7 | ✓ | ✓ | «×2.0» y «COMBO 12» legibles. |
| 06 PRISM | ✓ | 7 | ✓ | ✓ | Onda prismática, tono del fondo desplazado, núcleo multicolor. |
| 07 Energía crítica | ✓ | 7 | ✓ | ✓ | Barra de energía en blanco. |
| 08 Sin símbolos + reducir efectos | ✓ | 7 | ✓ | Desactivados (ajuste) | Sin rotaciones; colores distinguibles con visión normal. |
| 09 Pausa | ✓ | — | ✓ | — | Capa con alfa 0.75; botones con jerarquía clara. |
| 10 Resultados | ✓ | — | ✓ | — | Récord, desglose de cristales y misiones. |
| 11 Colección | ✓ | — | ✓ | ✓ | Estados EQUIPADO, precio y precio atenuado (insuficiente). |
| 12 Misiones | ✓ | — | ✓ | — | Reclamar y estadísticas. |
| 13 Ajustes | ✓ | — | ✓ | — | Vibración deshabilitada con «No disponible…» (escritorio). |
| 9:20 y 3:4 (01–04) | ✓ | ✓ | ✓ | ✓ | En 3:4 la arena se reduce según CR-001; sin solapes. |

## 3. Hallazgos abiertos para la revisión del propietario

| ID | Hallazgo | Propuesta |
|----|----------|-----------|
| VR-01 | Orbitron dibuja el **0 con barra** (Ø) y un **7** muy estilizado: la puntuación «0» se puede confundir con un icono. | Valorar Exo 2 para cifras (cambio de ART-024; requiere aprobación). |
| VR-02 | Orbes de ~17 dp: el símbolo se lee en la captura a tamaño completo, pero en un teléfono físico puede quedar pequeño (H-21/M-13). | Revisar en dispositivo; ajustar `orb_radius` dentro del rango si hace falta. |
| VR-03 | La etiqueta de semilla aparece en compilaciones de depuración (FR-SIM-003); no aparece en las de publicación. | Ninguna. |
| VR-04 | Las animaciones (ART-030…044) solo se han verificado en capturas estáticas. | Revisión en movimiento en dispositivo. |

## 4. Rúbrica del propietario (§9.4) — pendiente

| Criterio | Puntuación (1–5) |
|----------|------------------|
| Legibilidad inmediata del objetivo | — |
| Identidad futurista | — |
| Sensación de respuesta del acierto | — |
| Limpieza de la interfaz | — |
| Coherencia entre pantallas | — |
