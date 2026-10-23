# Registro de riesgos: PRISM POP v1

- **Versión:** 0.1.0 · **Fecha:** 2026-10-23
- Probabilidad (P) e impacto (I): Baja / Media / Alta.

| ID | Riesgo | P | I | Mitigación | Estado |
|----|--------|---|---|------------|--------|
| R-01 | La mecánica propuesta (D-01 A) no resulta divertida o se percibe como demasiado simple. | Media | Alta | Prototipo jugable mínimo como primera entrega de implementación; pruebas con jugadores antes de construir la progresión. | Abierto |
| R-02 | No hay dispositivo físico en el entorno: rendimiento, latencia táctil y vibración no verificables aquí. | Alta | Media | Escenario de estrés automatizado con medición de tiempos de fotograma en escritorio como indicador; pruebas en dispositivo registradas como pendientes para el propietario. | Abierto |
| R-03 | La latencia táctil varía entre dispositivos Android (≈ 50–100 ms) y reduce la ventana efectiva de captura (0.25 s a dificultad máxima). | Media | Media | Ventana parametrizada (`zone_outer_radius`, `orb_speed_max`); calibrar en dispositivo de referencia. | Abierto |
| R-04 | No se puede descargar Godot o las plantillas de exportación por restricciones de red o de autorización. | Baja | Alta | Comprobado: el repositorio oficial de Godot es accesible desde el entorno (consulta de tags). Pendiente de autorización (D-03). | Abierto |
| R-05 | Calidad de audio y música generadas sin artista (si D-04 = A) por debajo de la expectativa «premium». | Media | Media | Revisión de audio con rúbrica análoga a la visual; posibilidad de sustituir recursos sin cambiar código (identificadores de sonido estables, FR-AUD-001). | Abierto |
| R-06 | Ampliación silenciosa del alcance durante la implementación. | Media | Media | Política de cambios de la constitución §3; `spec_lint.py` en cada revisión. | Abierto |
| R-07 | Determinismo (FR-SIM-002) roto por diferencias de coma flotante entre plataformas. | Baja | Baja | El determinismo se exige en la misma plataforma y compilación (pruebas y repeticiones); no se usan repeticiones entre dispositivos. | Abierto |
| R-08 | Los bots de verificación no representan a jugadores reales y la calibración de SC-001 resulta engañosa. | Media | Media | Las tasas de error de los bots se tratan como suposiciones (parameters §7) y se recalibran con pruebas reales. | Abierto |
| R-09 | Orbes demasiado pequeños para leer el símbolo en teléfono (H-21). | Media | Media | Revisión visual temprana en dispositivo; ajuste dentro de rango (M-13). | Abierto |
