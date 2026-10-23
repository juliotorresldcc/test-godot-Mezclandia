# Matriz de trazabilidad: PRISM POP v1

- **Fecha:** 2026-10-23 · Formato: `REQ → SPEC → DESIGN → TASK → TEST → EVIDENCE`
- Comprobada con `python3 tools/trace_check.py --tests`. Leyenda de evidencia: ✅ aprobada con salida registrada · ◐ verificada parcialmente · ⏳ pendiente (no ejecutable aquí).

| Requisito | Spec | Diseño | Tarea | Prueba | Evidencia |
|-----------|------|--------|-------|--------|-----------|
| FR-ARENA-001 | spec.md | 2.7 | T09 | TEST-SIM-01; reglas sin dependencia de la resolución (unidades R) | ✅ Aprobada — test-report §1 |
| FR-ARENA-002 | spec.md | 2.1 | T09 | TEST-CFG-02 (C1/C2) | ✅ Aprobada — test-report §1 |
| FR-GS-001 | spec.md | 2.7 | T09 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-002 | spec.md | 2.7 | T09 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-003 | spec.md | 2.7 | T09 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-004 | spec.md | 2.7 | T09 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-005 | spec.md | 2.7 | T09 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-006 | spec.md | 2.7 | T09, T11 | TEST-GS-01…08, TEST-UI-01 | ✅ Aprobada — test-report §1 |
| FR-GS-007 | spec.md | 2.7/2.9 | T09 | TEST-SAV-07 (el esquema no guarda partidas) | ✅ Aprobada — test-report §1 |
| FR-CORE-001 | spec.md | 2.7/2.12 | T09 | TEST-RES-01, TEST-RES-06; capturas 03–07 | ✅ Aprobada — test-report §1 |
| FR-CORE-002 | spec.md | 2.12 | T16 | Capturas 06 (PRISM) y 07 (energía crítica) | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| FR-CORE-003 | spec.md | 2.12 | T09, T16 | TEST-FAIR-01, SIM-SC002; capturas 03–05 | ✅ Aprobada — test-report §1 |
| FR-ORB-001 | spec.md | 2.4/2.7 | T08 | TEST-FAIR-01, SIM-SC002 | ✅ Aprobada — test-report §2 (simulación) |
| FR-ORB-002 | spec.md | 2.4 | T08 | TEST-SPN-01 | ✅ Aprobada — test-report §1 |
| FR-ORB-003 | spec.md | 2.4 | T08 | TEST-SPN-02 | ✅ Aprobada — test-report §1 |
| FR-ORB-004 | spec.md | 2.4 | T08 | TEST-CFG-02 (C10); sin avisos en 14 000 partidas simuladas | ✅ Aprobada — test-report §2 (simulación) |
| FR-ORB-005 | spec.md | 2.4 | T08 | TEST-SPN-02, TEST-SPN-03 | ✅ Aprobada — test-report §1 |
| FR-COL-001 | spec.md | 2.3 | T05 | TEST-SEQ-01…04; capturas (símbolos) | ✅ Aprobada — test-report §1 |
| FR-COL-002 | spec.md | 2.2/2.3 | T05 | TEST-DIF-03, TEST-SEQ-02 | ✅ Aprobada — test-report §1 |
| FR-SEQ-001 | spec.md | 2.3/2.4 | T05 | TEST-SEQ-01…04, TEST-SPN-02 | ✅ Aprobada — test-report §1 |
| FR-SEQ-002 | spec.md | 2.3/2.4 | T05 | TEST-SEQ-01…04, TEST-SPN-02 | ✅ Aprobada — test-report §1 |
| FR-SEQ-003 | spec.md | 2.3/2.4 | T05 | TEST-SEQ-01…04, TEST-SPN-02 | ✅ Aprobada — test-report §1 |
| FR-SEQ-004 | spec.md | 2.3/2.4 | T08 | TEST-SEQ-01…04, TEST-SPN-02 | ✅ Aprobada — test-report §1 |
| FR-SEQ-005 | spec.md | 2.7 | T09 | TEST-FAIR-01, SIM-SC002 (aserción en cada entrada en zona) | ✅ Aprobada — test-report §2 (simulación) |
| FR-INP-001 | spec.md | 2.11 | T17 | TEST-INP-04 | ✅ Aprobada — test-report §1 |
| FR-INP-002 | spec.md | 2.7 | T09 | TEST-INP-01, TEST-INP-02 | ✅ Aprobada — test-report §1 |
| FR-INP-003 | spec.md | 2.7 | T09 | TEST-INP-01, TEST-INP-02 | ✅ Aprobada — test-report §1 |
| FR-INP-004 | spec.md | 2.7 | T09 | TEST-RES-10 | ✅ Aprobada — test-report §1 |
| FR-INP-005 | spec.md | 2.7 | T09 | TEST-GS-01, TEST-GS-03 | ✅ Aprobada — test-report §1 |
| FR-INP-006 | spec.md | 2.11 | T17 | TEST-INP-05 | ✅ Aprobada — test-report §1 |
| FR-RES-001 | spec.md | 2.7 | T09 | TEST-RES-01…10 | ✅ Aprobada — test-report §1 |
| FR-RES-002 | spec.md | 2.7 | T09 | TEST-RES-01…10 | ✅ Aprobada — test-report §1 |
| FR-SCO-001 | spec.md | 2.2 | T04 | TEST-SCO-01, TEST-SCO-02 | ✅ Aprobada — test-report §1 |
| FR-SCO-002 | spec.md | 2.2 | T04 | TEST-SCO-01, TEST-SCO-02 | ✅ Aprobada — test-report §1 |
| FR-SCO-003 | spec.md | 2.7 | T04 | TEST-RES-01…05 | ✅ Aprobada — test-report §1 |
| FR-SCO-004 | spec.md | 2.8 | T04, T11 | TEST-PRG-03 | ✅ Aprobada — test-report §1 |
| FR-CMB-001 | spec.md | 2.5 | T06 | TEST-CMB-01…05, TEST-SCO-03 | ✅ Aprobada — test-report §1 |
| FR-CMB-002 | spec.md | 2.5 | T04 | TEST-CMB-01…05, TEST-SCO-03 | ✅ Aprobada — test-report §1 |
| FR-CMB-003 | spec.md | 2.5 | T06 | TEST-CMB-01…05, TEST-SCO-03 | ✅ Aprobada — test-report §1 |
| FR-ENE-001 | spec.md | 2.7 | T09 | TEST-ENE-01…04 | ✅ Aprobada — test-report §1 |
| FR-ENE-002 | spec.md | 2.7 | T09 | TEST-ENE-01…04 | ✅ Aprobada — test-report §1 |
| FR-ENE-003 | spec.md | 2.7 | T09 | TEST-ENE-01…04 | ✅ Aprobada — test-report §1 |
| FR-ENE-004 | spec.md | 2.7 | T09 | TEST-ENE-01…04 | ✅ Aprobada — test-report §1 |
| FR-ENE-005 | spec.md | 2.7 | T09 | TEST-ENE-01…04 | ✅ Aprobada — test-report §1 |
| FR-DIF-001 | spec.md | 2.2 | T04 | TEST-DIF-01…03 | ✅ Aprobada — test-report §1 |
| FR-DIF-002 | spec.md | 2.2 | T04 | TEST-DIF-01…03 | ✅ Aprobada — test-report §1 |
| FR-DIF-003 | spec.md | 2.2 | T04 | TEST-DIF-01…03 | ✅ Aprobada — test-report §1 |
| FR-EVT-001 | spec.md | 2.4 | T08 | TEST-RES-03, TEST-RES-08, TEST-SPN-03 | ✅ Aprobada — test-report §1 |
| FR-EVT-002 | spec.md | 2.4 | T08 | TEST-RES-03, TEST-RES-08, TEST-SPN-03 | ✅ Aprobada — test-report §1 |
| FR-PRM-001 | spec.md | 2.6 | T07 | TEST-PRM-01…03, TEST-RES-04, TEST-RES-09 | ✅ Aprobada — test-report §1 |
| FR-PRM-002 | spec.md | 2.6 | T07 | TEST-PRM-01…03, TEST-RES-04, TEST-RES-09 | ✅ Aprobada — test-report §1 |
| FR-PRM-003 | spec.md | 2.6 | T07 | TEST-PRM-01…03, TEST-RES-04, TEST-RES-09 | ✅ Aprobada — test-report §1 |
| FR-PRM-004 | spec.md | 2.6 | T07 | TEST-PRM-01…03, TEST-RES-04, TEST-RES-09 | ✅ Aprobada — test-report §1 |
| FR-PRM-005 | spec.md | 2.6 | T07 | TEST-PRM-01…03, TEST-RES-04, TEST-RES-09 | ✅ Aprobada — test-report §1 |
| FR-PRM-006 | spec.md | 2.6 | T07 | SIM (media de activaciones por bot), TEST-PRG-01 | ✅ Aprobada — test-report §2 (simulación) |
| FR-SIM-001 | spec.md | 2.7 | T09 | TEST-RES-10, TEST-ENE-03 | ✅ Aprobada — test-report §1 |
| FR-SIM-002 | spec.md | 2.7 | T09 | TEST-SIM-01 (100 repeticiones) | ✅ Aprobada — test-report §1 |
| FR-SIM-003 | spec.md | 2.7 | T09 | Semilla inyectada en pruebas; visible en depuración (captura 04) | ✅ Aprobada — test-report §1 |
| FR-FAIR-001 | spec.md | 2.7 | T09 | SIM-SC002, TEST-SPN-02, TEST-FAIR-01 | ✅ Aprobada — test-report §2 (simulación) |
| FR-FAIR-002 | spec.md | 2.7 | T08 | SIM-SC002, TEST-SPN-02, TEST-FAIR-01 | ✅ Aprobada — test-report §2 (simulación) |
| FR-FAIR-003 | spec.md | 2.7 | T09 | SIM-SC002, TEST-SPN-02, TEST-FAIR-01 | ✅ Aprobada — test-report §2 (simulación) |
| FR-FAIR-004 | spec.md | 2.7 | T09 | SIM-SC002, TEST-SPN-02, TEST-FAIR-01 | ✅ Aprobada — test-report §2 (simulación) |
| FR-FAIR-005 | spec.md | 2.1 | T02 | TEST-CFG-01/02, TEST-GS-08 | ✅ Aprobada — test-report §1 |
| FR-FAIR-006 | spec.md | 2.11 | T19 | TEST-LAY-01 (5 resoluciones), TEST-LAY-03 (HUD real) | ✅ Aprobada — test-report §1 |
| FR-STAT-001 | spec.md | 2.7 | T09 | TEST-SCO-03, SIM | ✅ Aprobada — test-report §1 |
| FR-STAT-002 | spec.md | 2.7 | T04 | TEST-SCO-03, SIM | ✅ Aprobada — test-report §1 |
| FR-UX-001 | spec.md | 2.11 | T18 | TEST-UI-01…07 | ✅ Aprobada — test-report §1 |
| FR-UX-002 | spec.md | 2.11 | T18 | TEST-UI-09 | ✅ Aprobada — test-report §1 |
| FR-UX-003 | spec.md | 2.11 | T18 | TEST-UI-01…09 (cada botón de §4) | ✅ Aprobada — test-report §1 |
| FR-UX-004 | spec.md | — | T13, T18 | TEST-STR-01 | ✅ Aprobada — test-report §1 |
| FR-UX-010 | spec.md | 2.11 | T18 | TEST-UI-01, TEST-UI-07; captura 01 | ✅ Aprobada — test-report §1 |
| FR-UX-011 | spec.md | 2.11 | T18 | TEST-UI-01, TEST-UI-07; captura 01 | ✅ Aprobada — test-report §1 |
| FR-UX-012 | spec.md | 2.11 | T18 | TEST-UI-01, TEST-UI-07; captura 01 | ✅ Aprobada — test-report §1 |
| FR-UX-020 | spec.md | 2.11 | T18 | TEST-UI-01, TEST-UI-06; captura 02 | ✅ Aprobada — test-report §1 |
| FR-UX-021 | spec.md | 2.11 | T18 | TEST-UI-01, TEST-UI-06; captura 02 | ✅ Aprobada — test-report §1 |
| FR-UX-030 | spec.md | 2.11 | T17, T18 | TEST-LAY-03, TEST-INP-04; capturas 03–08 | ✅ Aprobada — test-report §1 |
| FR-UX-031 | spec.md | 2.11 | T17, T18 | TEST-LAY-03, TEST-INP-04; capturas 03–08 | ✅ Aprobada — test-report §1 |
| FR-UX-032 | spec.md | 2.11 | T17, T18 | TEST-LAY-03, TEST-INP-04; capturas 03–08 | ✅ Aprobada — test-report §1 |
| FR-UX-040 | spec.md | 2.11 | T17, T18 | TEST-UI-01; captura 09 | ✅ Aprobada — test-report §1 |
| FR-UX-050 | spec.md | 2.11 | T18 | TEST-UI-02; captura 10 | ✅ Aprobada — test-report §1 |
| FR-UX-051 | spec.md | 2.11 | T18 | TEST-UI-02; captura 10 | ✅ Aprobada — test-report §1 |
| FR-UX-060 | spec.md | 2.11 | T18 | TEST-UI-03; captura 11 | ✅ Aprobada — test-report §1 |
| FR-UX-061 | spec.md | 2.11 | T18 | TEST-UI-03; captura 11 | ✅ Aprobada — test-report §1 |
| FR-UX-062 | spec.md | 2.11 | T18 | TEST-UI-03; captura 11 | ✅ Aprobada — test-report §1 |
| FR-UX-070 | spec.md | 2.11 | T18 | TEST-UI-04; captura 12 | ✅ Aprobada — test-report §1 |
| FR-UX-071 | spec.md | 2.11 | T18 | TEST-UI-04; captura 12 | ✅ Aprobada — test-report §1 |
| FR-UX-080 | spec.md | 2.11 | T18 | TEST-UI-05; captura 13 | ✅ Aprobada — test-report §1 |
| FR-UX-081 | spec.md | 2.11 | T18 | TEST-UI-05; captura 13 | ✅ Aprobada — test-report §1 |
| FR-ART-001 | spec.md | 2.12 | T20 | Revisión visual con rúbrica (art-direction §9) | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| FR-ART-002 | spec.md | 2.12 | T16 | Capturas 04 y 08 (símbolos), 11 (cosméticos); CosmeticArt solo dibuja patrón interior/estela | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| FR-ART-003 | spec.md | 2.12 | T16 | Capturas 04 y 08 (símbolos), 11 (cosméticos); CosmeticArt solo dibuja patrón interior/estela | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| FR-AUD-001 | spec.md | 2.10 | T14 | TEST-AUD-01 | ✅ Aprobada — test-report §1 |
| FR-AUD-002 | spec.md | 2.10 | T14 | TEST-AUD-01 (carga de capas); mezcla por capas pendiente de escucha | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| FR-AUD-003 | spec.md | 2.10 | T14 | TEST-AUD-01…03 (controlador Dummy) | ✅ Aprobada — test-report §1 |
| FR-AUD-004 | spec.md | 2.10 | T14 | TEST-AUD-01…03 (controlador Dummy) | ✅ Aprobada — test-report §1 |
| FR-AUD-005 | spec.md | 2.10 | T14 | TEST-AUD-01…03 (controlador Dummy) | ✅ Aprobada — test-report §1 |
| FR-HAP-001 | spec.md | 2.10 | T15, T17 | TEST-HAP-01 (sin llamadas en escritorio); vibración real | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| FR-HAP-002 | spec.md | 2.10 | T15 | TEST-HAP-01, TEST-UI-05 | ✅ Aprobada — test-report §1 |
| FR-HAP-003 | spec.md | 2.10 | T15 | TEST-HAP-01, TEST-UI-05 | ✅ Aprobada — test-report §1 |
| FR-PRG-001 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-PRG-002 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-PRG-003 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-PRG-010 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-PRG-011 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-PRG-012 | spec.md | 2.8 | T11 | TEST-PRG-01…10, TEST-UI-03 | ✅ Aprobada — test-report §1 |
| FR-MIS-001 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-002 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-003 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-004 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-005 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-006 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-MIS-007 | spec.md | 2.8 | T11 | TEST-MIS-01…06, TEST-UI-04 | ✅ Aprobada — test-report §1 |
| FR-STAT-010 | spec.md | 2.8 | T11 | TEST-PRG-01…10 | ✅ Aprobada — test-report §1 |
| FR-STAT-011 | spec.md | 2.11 | T18 | TEST-UI-04; captura 12 | ✅ Aprobada — test-report §1 |
| FR-SAV-001 | spec.md | 2.9 | T12 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| FR-SAV-002 | spec.md | 2.9 | T12 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| FR-SAV-003 | spec.md | 2.9 | T12 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| FR-SAV-004 | spec.md | 2.9 | T12 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| FR-SAV-005 | spec.md | 2.9 | T12, T18 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| FR-SAV-006 | spec.md | 2.9 | T12 | TEST-SAV-01…07, TEST-UI-02/03/05/07 | ✅ Aprobada — test-report §1 |
| NFR-PERF-001 | spec.md | plan §4 | T23 | PERF-01 (indicativo: CPU p95 ≈ 1 ms) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-PERF-002 | spec.md | plan §4 | T23 | PERF-01 (indicativo) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-PERF-003 | spec.md | plan §4 | T23 | PERF-01 (indicativo) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-PERF-004 | spec.md | plan §4 | T23 | PERF-01 (indicativo) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-PERF-005 | spec.md | plan §4 | T23 | PERF-01 (indicativo) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-A11Y-001 | spec.md | ART-003 | T13 | tools/palette_check.py | ✅ Aprobada — test-report §1 |
| NFR-A11Y-002 | spec.md | ART-002 | T13 | Capturas 04 (símbolos en orbes y núcleo) | ✅ Aprobada — test-report §1 |
| NFR-A11Y-003 | spec.md | ART-052 | T16 | TEST-VIS-01 | ✅ Aprobada — test-report §1 |
| NFR-A11Y-004 | spec.md | ART-020…025 | T13 | TEST-LAY-01 | ✅ Aprobada — test-report §1 |
| NFR-A11Y-005 | spec.md | ART-020…025 | T13 | TEST-LAY-01 | ✅ Aprobada — test-report §1 |
| NFR-A11Y-006 | spec.md | — | T20 | Control de un solo toque en cualquier punto (TEST-INP-04); prueba con jugadores | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-A11Y-007 | spec.md | ART-050 | T16 | TEST-VIS-02, captura 08 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| NFR-PRIV-001 | spec.md | plan §2 | T21 | Búsqueda de API de red en src/ (0 coincidencias); preset sin INTERNET | ✅ Aprobada — test-report §1 |
| NFR-SEC-001 | spec.md | 2.9 | T12 | TEST-SAV-05 | ✅ Aprobada — test-report §1 |
| FR-RG-001 | spec.md | — | T18 | Búsqueda de monetización/anuncios (0 coincidencias); misiones sin caducidad (FR-MIS-007) | ✅ Aprobada — test-report §1 |
| FR-RG-002 | spec.md | 2.11 | T18 | TEST-RG-02 | ✅ Aprobada — test-report §1 |
| NFR-PLAT-001 | spec.md | ADR 0009 | T21 | Preset Android validado por Godot; APK no generable sin SDK | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| NFR-PLAT-002 | spec.md | 2.11 | T01 | project.godot (vertical, expand), TEST-LAY-01 | ✅ Aprobada — test-report §1 |
| NFR-PLAT-003 | spec.md | 2.11 | T17 | TEST-UI-06 | ✅ Aprobada — test-report §1 |
| NFR-MNT-001 | spec.md | 2.1 | T02 | tools/check_sync.py (56 parámetros) | ✅ Aprobada — test-report §1 |
| NFR-MNT-002 | spec.md | ADR 0003 | T09 | run_tests.gd y run_sim.gd headless | ✅ Aprobada — test-report §1 |
| SC-001 | spec.md | — | T10 | SIM-SC001, SIM-SC002 | ✅ Aprobada — test-report §2 (simulación) |
| SC-002 | spec.md | — | T10 | SIM-SC001, SIM-SC002 | ✅ Aprobada — test-report §2 (simulación) |
| SC-003 | spec.md | — | T23 | PERF-01 (indicativo) | ⏳ Pendiente — requiere dispositivo (test-report §5) |
| SC-004 | spec.md | — | T20 | Prueba con jugadores nuevos | ⏳ Pendiente — requiere jugadores (test-report §5) |
| SC-005 | spec.md | — | T19 | TEST-UI-01…09 | ✅ Aprobada — test-report §1 |
| SC-006 | spec.md | — | T12 | TEST-SAV-01…07 | ✅ Aprobada — test-report §1 |
| SC-007 | spec.md | — | T19 | Validación headless sin errores, TEST-RSC-01 | ✅ Aprobada — test-report §1 |
| ART-001 | art-direction.md | — | T13 | tools/palette_check.py, tools/check_sync.py | ✅ Aprobada — test-report §1 |
| ART-002 | art-direction.md | — | T13, T16 | tools/palette_check.py, tools/check_sync.py | ✅ Aprobada — test-report §1 |
| ART-003 | art-direction.md | — | T13 | tools/palette_check.py, tools/check_sync.py | ✅ Aprobada — test-report §1 |
| ART-004 | art-direction.md | — | T13 | tools/palette_check.py, tools/check_sync.py | ✅ Aprobada — test-report §1 |
| ART-010 | art-direction.md | 2.12 | T13 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-011 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-012 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-013 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-014 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-015 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-016 | art-direction.md | 2.12 | T13, T16 | TEST-LAY-01/02; capturas 03–08 | ✅ Aprobada — test-report §1 |
| ART-020 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-021 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-022 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-023 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-024 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-025 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-026 | art-direction.md | 2.11 | T13 | TEST-LAY-01/03; capturas 9:16, 9:20, 3:4 | ✅ Aprobada — test-report §1 |
| ART-030 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-031 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-032 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-033 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-034 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-035 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-036 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-037 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-038 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-039 | art-direction.md | 2.12 | T16 | Capturas estáticas 04–07, 10; las animaciones en movimiento requieren revisión en dispositivo | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-040 | art-direction.md | 2.11 | T16 | Capturas 01, 09, 10 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-041 | art-direction.md | 2.11 | T16 | Capturas 01, 09, 10 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-042 | art-direction.md | 2.11 | T16 | Capturas 01, 09, 10 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-043 | art-direction.md | 2.11 | T16 | Capturas 01, 09, 10 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-044 | art-direction.md | 2.11 | T16 | Capturas 01, 09, 10 | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-050 | art-direction.md | 2.12 | T16 | Captura 08; fondo en capturas | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-051 | art-direction.md | 2.12 | T16 | TEST-VIS-01/02 | ✅ Aprobada — test-report §1 |
| ART-052 | art-direction.md | 2.12 | T16 | TEST-VIS-01/02 | ✅ Aprobada — test-report §1 |
| ART-053 | art-direction.md | 2.12 | T16 | Captura 08; fondo en capturas | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-060 | art-direction.md | 2.12 | T16 | Captura 11; CosmeticArt | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |
| ART-070 | art-direction.md | 2.11 | T13 | Capturas (iconos Pausa y Atrás) | ◐ Capturas reales revisadas (visual-review.md); rúbrica del propietario pendiente |

## Resumen

| Estado | Requisitos |
|---|---|
| ✅ | 152 |
| ◐ | 24 |
| ⏳ | 11 |
