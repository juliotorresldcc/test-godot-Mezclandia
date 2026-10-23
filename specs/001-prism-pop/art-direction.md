# Guía de dirección artística: PRISM POP v1

- **Versión:** 0.1.0 (aprobada el 2026-10-23)
- **Fecha:** 2026-10-23
- **Estado:** propuesta `[P]` completa. La identidad general es `[M]` (mandato); los valores concretos requieren aprobación y revisión visual (§9).
- **Fuente de verdad de:** paleta, símbolos, proporciones, tipografía, animaciones y procedimiento de revisión visual. `tools/palette_check.py` lee las tablas de §1 y §3 de este archivo; **no cambies su formato** sin actualizar el script.

## 0. Dirección creativa

**Concepto:** «Laboratorio de luz nocturno». Un núcleo de energía suspendido en un vacío azul noche descompone y absorbe luz pura. Todo lo que brilla es información de juego; todo lo que no informa está oscuro y quieto.

Principios verificables:
1. **La luz es información.** Solo los elementos de juego (núcleo, orbes, zona, retroalimentación) usan colores saturados o brillo aditivo. Los fondos y paneles nunca usan los cuatro colores de orbe a saturación completa.
2. **Jerarquía por luminancia:** núcleo y orbes > zona de captura > HUD > fondo.
3. **Ritmo rápido:** ninguna animación de respuesta a una acción del jugador dura más de 0.5 s (excepto las secuencias de fin y las transiciones de pantalla).
4. **Minimalismo:** en `PLAYING` no hay más de 7 grupos de elementos de interfaz visibles (puntuación, combo, tiempo, pausa, energía, PRISM, siguiente).

Referencias de estilo (descriptivas, sin uso de material de terceros): estética neón sobre fondo oscuro de los arcades minimalistas de luz; brillo aditivo y halos tipo «bloom»; gradientes radiales en esferas. El moodboard generado está en `assets/moodboard.svg` (generado por `tools/palette_check.py --svg`; muestra paleta, símbolos y maqueta de disposición, no arte final).

## 1. Paleta

- **ART-001** `[M][P]` Tokens de color (los únicos colores permitidos; cualquier otro requiere añadir un token aquí):

| Token | Hex | Uso |
|-------|-----|-----|
| `bg.night` | `#070B1F` | Fondo base (azul noche). |
| `bg.deep` | `#0E1A4D` | Extremo superior del gradiente de fondo. |
| `bg.surface` | `#151E48` | Paneles, diálogos, tarjetas. |
| `bg.surface_alt` | `#1F2A60` | Botones secundarios, pestañas inactivas. |
| `orb.cyan` | `#00E5FF` | Orbe y objetivo CIAN. |
| `orb.magenta` | `#FF2BD6` | Orbe y objetivo MAGENTA. |
| `orb.yellow` | `#FFE14D` | Orbe y objetivo AMARILLO. |
| `orb.violet` | `#A47CFF` | Orbe y objetivo VIOLETA. |
| `orb.crystal` | `#E8F4FF` | Orbe cristal (con brillo iridiscente). |
| `text.primary` | `#F2F5FF` | Texto principal. |
| `text.secondary` | `#A9B3D9` | Texto secundario y etiquetas. |
| `text.on_accent` | `#070B1F` | Texto sobre botón primario. |
| `ui.accent` | `#00E5FF` | Botón primario. |
| `ui.glyph` | `#070B1F` | Símbolos dentro de orbes y núcleo. |

  Transparencias permitidas (multiplicadores alfa sobre tokens): 0.04, 0.08, 0.15, 0.25, 0.35, 0.60, 0.75, 0.85.

## 2. Símbolos de color

- **ART-002** `[M][P]` Cada color de orbe tiene un símbolo de silueta única, dibujado en `ui.glyph` con alfa 0.85, de tamaño `0.6 · diámetro del orbe`:

| Color | Símbolo |
|-------|---------|
| CIAN | Triángulo equilátero (vértice arriba) |
| MAGENTA | Cuadrado |
| AMARILLO | Cruz griega (+) |
| VIOLETA | Estrella de 5 puntas |
| CRISTAL | Rombo (cuadrado girado 45°) con contorno, sin relleno |

  *Aceptación:* en una prueba de reconocimiento con el filtro de escala de grises activo, los cinco tipos se distinguen por la silueta en la resolución de referencia. Los símbolos se muestran en orbes, en el núcleo y en el indicador SIGUIENTE cuando el ajuste «Símbolos de color» está activo.

## 3. Contraste requerido

- **ART-003** `[M][P]` Pares que deben cumplir la relación de contraste WCAG 2.x indicada (NFR-A11Y-001):

| Primer plano | Fondo | Mínimo |
|--------------|-------|--------|
| `text.primary` | `bg.night` | 4.5 |
| `text.primary` | `bg.surface` | 4.5 |
| `text.primary` | `bg.surface_alt` | 4.5 |
| `text.secondary` | `bg.night` | 4.5 |
| `text.secondary` | `bg.surface` | 4.5 |
| `text.on_accent` | `ui.accent` | 4.5 |
| `orb.cyan` | `bg.night` | 3.0 |
| `orb.magenta` | `bg.night` | 3.0 |
| `orb.yellow` | `bg.night` | 3.0 |
| `orb.violet` | `bg.night` | 3.0 |
| `orb.crystal` | `bg.night` | 3.0 |
| `ui.glyph` | `orb.cyan` | 3.0 |
| `ui.glyph` | `orb.magenta` | 3.0 |
| `ui.glyph` | `orb.yellow` | 3.0 |
| `ui.glyph` | `orb.violet` | 3.0 |
| `ui.glyph` | `orb.crystal` | 3.0 |
| `orb.cyan` | `bg.deep` | 3.0 |
| `orb.magenta` | `bg.deep` | 3.0 |
| `orb.yellow` | `bg.deep` | 3.0 |
| `orb.violet` | `bg.deep` | 3.0 |

- **ART-004** `[P]` Distinción entre colores de orbe: el script informa de la diferencia de color ΔE (CIE76, espacio Lab) entre cada par de colores de orbe con visión normal y con simulación de protanopía, deuteranopía y tritanopía (Machado et al., 2009, severidad 1.0). Requisito: ΔE ≥ 20 entre todos los pares con visión normal. Los pares con ΔE < 20 en alguna simulación dependen de los símbolos (ART-002) para distinguirse; por eso «Símbolos de color» está activo por defecto.

Resultados de la última ejecución: ver §10.

## 4. Proporciones y disposición

Resolución de referencia: 1080 × 1920 px (vertical). `W` y `H` son el ancho y alto del área visible; `S_top` y `S_bottom` las inserciones de área segura. A efectos de tamaño mínimo, 1 dp = `W / 411` px (equivalencia de un teléfono de 1080 px de ancho y densidad 2.625).

- **ART-010** `[P]` **Arena:** centro en `(W/2, S_top + (H − S_top − S_bottom) · 0.50)`. `R_px = min(0.42 · W, 0.30 · (H − S_top − S_bottom))`. Nada de la interfaz puede invadir el círculo de radio `1.05 · R_px` (FR-FAIR-006).
- **ART-011** `[P]` **Núcleo** (radio `core_radius`): capas de dentro a fuera:
  1. Esfera con gradiente radial: centro = color objetivo mezclado 40 % con blanco; borde = color objetivo.
  2. Símbolo del objetivo (ART-002), tamaño `1.2 · core_radius`.
  3. Anillo de borde de `0.015 R` en `text.primary` alfa 0.60.
  4. Halo aditivo de radio `0.22 R` con alfa `0.15 + 0.20 · E / energy_max`.
  5. Destellos facetados que rotan a 0.25 vueltas/s (estáticos con «Reducir efectos»).
- **ART-012** `[P]` **Zona de captura:** corona entre `zone_inner_radius` y `zone_outer_radius` rellena con `text.primary` alfa 0.04; bordes de 2 dp con alfa 0.25. Con un orbe dentro: bordes alfa 0.60 y relleno alfa 0.08.
- **ART-013** `[P]` **Círculo de aparición:** contorno de 1 dp en `text.primary` alfa 0.08 en `r = spawn_radius`.
- **ART-014** `[P]` **Indicador SIGUIENTE:** centrado horizontalmente, inmediatamente debajo del círculo `1.05 R` (separación 12 dp). Contiene un orbe de radio `0.04 R` con el color y símbolo de `seq[idx+1]` y la etiqueta «SIGUIENTE» en `text.secondary`. (Ubicación propuesta, pendiente de revisión visual: M-12.)
- **ART-015** `[P]` **Orbes** (radio `orb_radius`): esfera con gradiente radial (centro: color mezclado 50 % con blanco; borde: color), halo aditivo de radio `1.6 · orb_radius` con alfa 0.35, símbolo (ART-002), estela cosmética (ART-060).
- **ART-016** `[P]` **Orbe cristal:** relleno `orb.crystal` alfa 0.85 con reflejo iridiscente que recorre los cuatro colores de orbe en 1.2 s (estático con «Reducir efectos»), contorno de 2 dp y símbolo de rombo.
- **ART-020** `[P]` **Botón Pausa:** esquina superior derecha, margen 16 dp desde el borde y el área segura; icono de 24 dp; área táctil de 48 × 48 dp.
- **ART-021** `[P]` **Banda superior del HUD:** puntuación centrada (40 dp, peso negrita), debajo el combo («×2.0» 24 dp y «COMBO 12» 14 dp); tiempo restante en la esquina superior izquierda (18 dp).
- **ART-022** `[P]` **Banda inferior del HUD:** a 24 dp del borde inferior seguro. Dos barras horizontales de 8 dp de alto con etiquetas de 14 dp encima: ENERGÍA (mitad izquierda) y PRISM (mitad derecha), separadas 16 dp, márgenes laterales 16 dp.
- **ART-023** `[P]` Márgenes laterales generales de pantallas de menú: 24 dp. Espaciado vertical entre botones: 12 dp.
- **ART-024** `[P]` **Tipografía:** títulos y números con una fuente geométrica de licencia libre (propuesta: *Orbitron*, OFL); texto corrido con una sans legible (propuesta: *Exo 2*, OFL). Tamaño mínimo de cualquier texto: 14 dp. Fuente pendiente de D-04.
- **ART-025** `[P]` **Botones:** alto 56 dp; radio de esquina 16 dp; primario: relleno `ui.accent`, texto `text.on_accent`; secundario: relleno `bg.surface_alt`, texto `text.primary`. Pulsado: escala 0.96 durante 0.08 s.
- **ART-026** `[P]` Resoluciones de verificación: 1080 × 1920 (9:16), 1080 × 2400 (9:20), 1536 × 2048 (3:4), 720 × 1280 (9:16 baja), y 1080 × 2400 con inserción superior de 40 dp (muesca).

## 5. Animaciones y respuesta a interacciones

Duraciones en segundos. «Suavizado» = curva de interpolación.

| ID | Interacción | Respuesta visual | Duración | Suavizado |
|----|-------------|------------------|----------|-----------|
| ART-030 | Acierto | Orbe escala 1.0 → 1.4 y se desvanece; 12 partículas del color del orbe (vida 0.35 s, velocidad 0.6 R/s); el núcleo aumenta su brillo un 40 %; texto «+N» sube 0.08 R y se desvanece en los últimos 0.2 s | 0.15 / 0.35 / 0.10 / 0.50 | salida cúbica |
| ART-031 | Activación PRISM | Onda prismática del núcleo al borde de la arena; el gradiente del fondo rota su tono durante el modo (ciclo 2 s, desplazamiento ≤ 30°); el núcleo recorre los cuatro colores a 1 ciclo/s; los orbes ganan halo iridiscente | onda 0.40 | salida senoidal |
| ART-032 | Aviso de fin de PRISM | El núcleo pulsa su brillo ±20 % a 2 Hz (no es un destello) y el medidor PRISM parpadea a 2 Hz | `prism_warning_time` | senoidal |
| ART-033 | Subida de nivel de combo | Texto «×m» escala 1.0 → 1.3 → 1.0 | 0.20 | salida elástica suave |
| ART-034 | Energía crítica | Halo del núcleo pulsa a 1 Hz; la barra de energía cambia a `text.primary` | continuo | senoidal |
| ART-035 | Nuevo color | Texto «NUEVO COLOR» bajo la banda superior + estrella violeta | `new_color_notice_duration` | entrada/salida |
| ART-036 | Error de color | El orbe se desatura a blanco (0.08 s) y se rompe en 6 fragmentos (0.30 s); sacudida de pantalla de amplitud 6 dp decreciente (0.20 s); la barra de energía muestra un único destello blanco | 0.38 total | salida cuadrática |
| ART-037 | Omisión | El orbe se aplasta contra el núcleo; el núcleo se desplaza en «glitch» RGB 3 dp; onda en la zona; mismo destello único de la barra de energía | 0.25 | lineal |
| ART-038 | Pulso vacío | Onda tenue de alfa 0.15 en la zona | 0.15 | salida |
| ART-039 | Ruptura de combo | El texto del combo cae 8 dp y se desvanece | `combo_broken_feedback` | entrada cuadrática |
| ART-040 | Transición de pantalla | Fundido cruzado + desplazamiento del 4 % del ancho | 0.25 | entrada/salida cúbica |
| ART-041 | Logotipo de Inicio | Aparición de las letras con dispersión prismática | ≤ 1.0 | salida |
| ART-042 | Abrir Pausa | Capa `bg.night` alfa 0.75 en fundido; panel escala 0.95 → 1.0 | 0.15 | salida |
| ART-043 | Recuento de puntuación | De 0 al valor final | 0.80 | salida cúbica |
| ART-044 | Fin de partida | La arena se desatura y los orbes se desvanecen; `GAME_OVER`: el núcleo se apaga; `COMPLETED`: el núcleo emite onda prismática | `end_sequence_duration` | salida |

## 6. Efectos, partículas y seguridad visual

- **ART-050** `[P]` **Reducir efectos** (NFR-A11Y-007): sin sacudida de pantalla, partículas × 0.5 (redondeo hacia abajo), sin rotaciones continuas (núcleo, cristal, fondo PRISM estático con gradiente prismático fijo).
- **ART-051** `[P]` Presupuesto de partículas: como máximo 300 partículas activas simultáneas. Si una emisión superaría el límite, se reduce su número de partículas.
- **ART-052** `[P]` **Destellos** (NFR-A11Y-003): un «destello» es un aumento de luminancia > 10 % del área de la pantalla en < 0.5 s. Un limitador global impide más de 3 destellos en cualquier ventana de 1 s. No hay destellos de pantalla completa.
- **ART-053** `[P]` El fondo es un gradiente vertical `bg.deep` (arriba) → `bg.night` (abajo) con un campo de estrellas estático de baja densidad (alfa ≤ 0.25). No hay movimiento de fondo fuera de PRISM.

## 7. Cosméticos

- **ART-060** `[P]` Los cosméticos solo pueden cambiar: la textura/patrón interior del núcleo (por debajo del símbolo y sin alterar el color objetivo), las partículas decorativas del núcleo y la estela de los orbes (longitud ≤ 0.15 R, alfa ≤ 0.40, en el color del propio orbe o en `text.primary`). No pueden cambiar colores de orbe, símbolos, halos de juego ni la zona de captura (FR-ART-003).

## 8. Iconografía de interfaz

- **ART-070** `[P]` Iconos lineales de trazo 2 dp en `text.primary`: pausa, atrás, ajustes, colección, misiones, cristal, candado. Sin texto incrustado en imágenes (todo texto se traduce).

## 9. Procedimiento de revisión visual

Los criterios subjetivos («premium», «satisfactorio») no son aceptables como único criterio. Cada revisión visual sigue este procedimiento:

1. **Capturas reales** del juego en ejecución (nunca maquetas) en las resoluciones de ART-026, para estos estados: Inicio, Menú principal, `PRE_START`, `PLAYING` con 3 orbes y uno en zona, `PLAYING` con combo ≥ 10, PRISM activo, energía crítica, Pausa, Resultados con récord, Colección, Misiones, Ajustes. Con y sin «Reducir efectos» y «Símbolos de color».
2. **Comprobaciones automáticas:** contraste (`tools/palette_check.py`), ninguna caja de la interfaz invade el círculo `1.05 R` ni el área segura, tamaños mínimos de texto y de área táctil.
3. **Lista objetiva por captura:** jerarquía de luminancia (§0.2), número de grupos de HUD (§0.4), colores solo de la paleta (§1), símbolos visibles cuando corresponde.
4. **Rúbrica subjetiva** puntuada por el propietario (1–5): legibilidad inmediata del objetivo, identidad futurista, sensación de respuesta del acierto, limpieza de la interfaz, coherencia entre pantallas. Aprobación: media ≥ 4 y ningún criterio < 3.
5. **Registro:** fecha, versión, capturas, resultados y decisión en `specs/001-prism-pop/visual-review.md`.

## 10. Resultados de verificación de la paleta

Salida de `python3 tools/palette_check.py` registrada en la fase Clarify: ver `checklists/palette-report.txt` (generado por el script; no editar a mano).

## 11. Historial

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 0.1.0 | 2026-10-23 | Primera guía propuesta. |
