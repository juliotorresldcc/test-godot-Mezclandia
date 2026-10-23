# Informe de pruebas: PRISM POP v1

- **Fecha:** 2026-10-23 · **Motor:** Godot 4.7.2-stable oficial (`ed1daf0bf`) · **Entorno:** contenedor Linux x86-64 (4 CPU), sin GPU ni dispositivo móvil.
- Todas las salidas de esta página proceden de ejecuciones reales en ese entorno. Para reproducirlas: `tools/check_all.sh --sim 1000 --visual`.

## Clasificación (constitución §5.5)

| Estado | Cantidad | Detalle |
|--------|----------|---------|
| Aprobadas | 97 pruebas unitarias/integración + 5 criterios de simulación + 4 comprobaciones documentales | §1–§3 |
| Fallidas | 0 | — |
| Pendientes (verificación parcial) | Revisión visual del propietario (rúbrica), animaciones en movimiento | §4 |
| No ejecutables en este entorno | Rendimiento en dispositivo, vibración real, exportación del APK, escucha de la mezcla musical, pruebas con jugadores | §5 |

## 1. Pruebas unitarias e integración (`tests/run_tests.gd`)

Comando: `godot --headless --path . --audio-driver Dummy --script res://tests/run_tests.gd`. Resultado: **97 superadas, 0 fallidas**; el ejecutor también falla ante cualquier error de motor o de script no esperado (comprobado con una prueba de control: código de salida 1).

```
PASS test_combo_prism::test_cmb_01_idle_to_active
PASS test_combo_prism::test_cmb_02_active_to_broken_and_idle
PASS test_combo_prism::test_cmb_03_broken_to_active
PASS test_combo_prism::test_cmb_04_error_in_idle_stays_idle
PASS test_combo_prism::test_cmb_05_tier_up_signal
PASS test_combo_prism::test_prm_01_charge_and_halving
PASS test_combo_prism::test_prm_02_activation_at_full_charge
PASS test_combo_prism::test_prm_03_warning_and_end
PASS test_config::test_cfg_01_default_config_is_valid
PASS test_config::test_cfg_01_constraint_values_match_parameters_doc
PASS test_config::test_cfg_02_each_constraint_detects_violation
PASS test_presentation::test_lay_01_hud_never_overlaps_arena
PASS test_presentation::test_lay_02_reference_radius
PASS test_presentation::test_str_01_all_keys_exist
PASS test_presentation::test_rsc_01_no_broken_references
PASS test_presentation::test_aud_01_all_sounds_load_and_play
PASS test_presentation::test_aud_03_voice_limit_priority
PASS test_presentation::test_aud_02_volume_mapping
PASS test_presentation::test_hap_01_unavailable_on_desktop
PASS test_presentation::test_vis_01_flash_limiter
PASS test_presentation::test_vis_02_particle_budget
PASS test_presentation::test_fmt_01_time_and_numbers
PASS test_progression::test_prg_01_crystal_formula_example
PASS test_progression::test_prg_02_no_completion_bonus_on_game_over
PASS test_progression::test_prg_03_record_strictly_greater
PASS test_progression::test_prg_04_purchase_exact_balance
PASS test_progression::test_prg_05_purchase_insufficient_is_atomic
PASS test_progression::test_prg_06_equip_owned_only
PASS test_progression::test_prg_07_balance_cap_overflow
PASS test_progression::test_prg_08_abandoned_changes_nothing_but_stat
PASS test_progression::test_prg_09_onboarding_first_sessions
PASS test_progression::test_mis_01_initial_missions
PASS test_progression::test_mis_02_per_session_takes_best_value
PASS test_progression::test_mis_03_cumulative_and_completion
PASS test_progression::test_mis_04_claim_refills_with_unique_template
PASS test_progression::test_mis_05_targets_by_tier
PASS test_progression::test_mis_06_abandoned_not_counted
PASS test_progression::test_prg_10_reset_keeps_settings
PASS test_rules::test_dif_01_table_values
PASS test_rules::test_dif_02_limits
PASS test_rules::test_dif_03_active_colors
PASS test_rules::test_sco_01_points_table
PASS test_rules::test_sco_02_round_half_up
PASS test_rules::test_sco_03_tier_and_accuracy
PASS test_save::test_sav_01_round_trip_all_fields
PASS test_save::test_sav_02_missing_file_creates_new_profile
PASS test_save::test_sav_03_corrupt_file
PASS test_save::test_sav_04_future_version
PASS test_save::test_sav_05_out_of_range_values
PASS test_save::test_sav_06_interrupted_write_keeps_previous
PASS test_save::test_sav_07_no_personal_data
PASS test_sequence::test_seq_01_no_consecutive_repeats
PASS test_sequence::test_seq_02_no_violet_with_three_colors
PASS test_sequence::test_seq_03_projection
PASS test_sequence::test_seq_04_advance_rule
PASS test_session::test_gs_01_start_initializes
PASS test_session::test_gs_02_pause_from_pre_start_returns_to_pre_start
PASS test_session::test_gs_03_pause_freezes_everything
PASS test_session::test_gs_04_resume_countdown
PASS test_session::test_gs_05_pause_during_resuming
PASS test_session::test_gs_06_abandon_only_from_pause
PASS test_session::test_gs_07_terminal_ignores_input
PASS test_session::test_gs_08_invalid_config_refuses_to_start
PASS test_session::test_res_01_hit
PASS test_session::test_res_02_color_error
PASS test_session::test_res_03_crystal_hit
PASS test_session::test_res_04_prism_capture_any
PASS test_session::test_res_05_empty_pulse
PASS test_session::test_res_06_omission
PASS test_session::test_res_07_discard_non_target
PASS test_session::test_res_08_discard_crystal
PASS test_session::test_res_09_prism_impact_neutral_but_advances
PASS test_session::test_res_10_pulse_before_impact_in_same_step
PASS test_session::test_inp_01_one_pulse_per_step
PASS test_session::test_inp_02_cooldown
PASS test_session::test_ene_01_three_errors_game_over
PASS test_session::test_ene_02_completed_at_max_time
PASS test_session::test_ene_03_game_over_wins_tie_with_time_cap
PASS test_session::test_ene_04_critical_flag
PASS test_session::test_spn_01_first_spawn_and_interval
PASS test_session::test_spn_02_angle_gap_and_pity
PASS test_session::test_spn_03_crystal_conditions
PASS test_session::test_sim_01_determinism
PASS test_session::test_fair_01_invariants_random_play
PASS test_ui_flow::test_ui_01_menu_to_game_and_pause_flow
PASS test_ui_flow::test_ui_02_results_flow
PASS test_ui_flow::test_ui_03_collection_purchase_equip_insufficient
PASS test_ui_flow::test_ui_04_missions_claim
PASS test_ui_flow::test_ui_05_settings_controls
PASS test_ui_flow::test_ui_06_back_button_and_focus
PASS test_ui_flow::test_inp_04_pause_button_area_does_not_pulse
PASS test_ui_flow::test_lay_03_real_hud_outside_arena
PASS test_ui_flow::test_ui_07_load_error_dialog
PASS test_ui_flow::test_ui_08_quit_during_prism_restores_background
PASS test_ui_flow::test_inp_05_space_key_is_a_tap
PASS test_ui_flow::test_ui_09_transition_blocks_input
PASS test_ui_flow::test_rg_02_break_reminder
```

## 2. Simulaciones (`tests/sim/run_sim.gd`, 1 000 partidas por bot + 10 000 aleatorias)

Comando: `godot --headless --path . --audio-driver Dummy --script res://tests/sim/run_sim.gd -- 1000` (duración: 1 min 13 s). Las comprobaciones de invariantes (FR-FAIR-001, FR-SEQ-005) están activas en **todas** las partidas.

```
NOVICE   { "n": 1000, "median_s": 33.8, "p10_s": 14.38, "p90_s": 55.65, "max_s": 90.0, "mean_score": 3328, "completed_pct": 0.6, "crystal_orbs_mean": 0.73, "prism_mean": 0.13, "violations": 0 }
EXPERT   { "n": 1000, "median_s": 90.0, "p10_s": 71.35, "p90_s": 90.0, "max_s": 90.0, "mean_score": 26832, "completed_pct": 84.1, "crystal_orbs_mean": 2.79, "prism_mean": 1.83, "violations": 0 }
SPAM     { "n": 1000, "median_s": 7.07, "p10_s": 4.97, "p90_s": 12.02, "max_s": 24.0166666666667, "mean_score": 387, "completed_pct": 0.0, "crystal_orbs_mean": 0.01, "prism_mean": 0.0, "violations": 0 }
PASSIVE  { "n": 1000, "median_s": 6.48, "p10_s": 4.42, "p90_s": 9.52, "max_s": 12.4666666666667, "mean_score": 0, "completed_pct": 0.0, "crystal_orbs_mean": 0.0, "prism_mean": 0.0, "violations": 0 }
OK     SC-001 mediana NOVATO en [30, 60] s
OK     SC-001 mediana EXPERTO ≥ 75 s
OK     SC-001 ninguna partida > 90 s + paso (máx 90.0000 s)
OK     E17 puntuación media SPAM < NOVATO
RANDOM   { "n": 10000, "median_s": 6.48, "p10_s": 4.42, "p90_s": 10.52, "max_s": 25.0666666666667, "mean_score": 168, "completed_pct": 0.0, "crystal_orbs_mean": 0.0, "prism_mean": 0.0, "violations": 0 }
OK     SC-002 0 violaciones de invariantes en 14000 partidas
RESULTADO SIMULACIÓN: APROBADO
```

Observación (no es un incumplimiento): el bot NOVATO obtiene de media 3 328 puntos, es decir, unos 3 cristales por partida. El primer cosmético (40 cristales) llega hacia la 8.ª partida si se suman las misiones iniciales. Conviene validarlo con jugadores reales (riesgo R-08).

## 3. Comprobaciones documentales

| Herramienta | Resultado |
|-------------|-----------|
| `tools/spec_lint.py` | APROBADO — 187 requisitos, 56 parámetros, 0 duplicados, 0 marcas abiertas |
| `tools/palette_check.py` | APROBADO — 20/20 pares de contraste; 2 pares dependen de los símbolos con daltonismo (ver `checklists/palette-report.txt`) |
| `tools/check_sync.py` | APROBADO — 56 parámetros (valor y rango), 8 precios y 14 colores idénticos en código y documentos |
| `tools/trace_check.py --tests` | APROBADO — 187/187 requisitos con tarea y prueba o excepción |
| Exploración del código en busca de API de red y monetización | 0 coincidencias (NFR-PRIV-001, FR-RG-001) |

## 4. Verificación visual y de rendimiento indicativa

- **Capturas reales** (Xvfb + OpenGL/llvmpipe) en `docs/visual/`: 13 estados en 9:16 y 4 estados en 9:20 y en 3:4. Revisión registrada en `visual-review.md`.
- **Rendimiento** (`tests/perf/stress.gd`; escenario: PRISM activo, 6 orbes, presupuesto de partículas lleno):

```
PERF frames=300 partículas=132 orbes=6
PERF modo=X11 tiempo de fotograma: p50=27.04 ms p95=33.09 ms máx=48.89 ms
PERF memoria estática: 40.9 MB; objetos: 1719; nodos: 39
PERF frames=300 partículas=300 orbes=6
PERF modo=headless tiempo de fotograma: p50=0.79 ms p95=0.89 ms máx=1.15 ms
PERF memoria estática: 45.1 MB; objetos: 1740; nodos: 39
```

  Interpretación: en headless (sin renderizado) el coste de CPU de scripts y dibujo es ≈ 0,8–1,0 ms por fotograma (p95). Con Xvfb el renderizado lo hace la CPU (llvmpipe), así que esos 27 ms **no** representan una GPU móvil. NFR-PERF-001 sigue pendiente de medir en el dispositivo de referencia.

## 5. No ejecutables en este entorno

| Prueba | Motivo | Procedimiento |
|--------|--------|---------------|
| NFR-PERF-001…005, SC-003 | Sin dispositivo Android | `docs/perf-device.md` |
| FR-HAP-001 (vibración real) | Sin dispositivo | `docs/perf-device.md` §3 |
| NFR-PLAT-001 (APK) | `dl.google.com` bloqueado: sin SDK de Android; faltan las plantillas 4.7.2 | `docs/export-android.md` (salida del intento en §1 de ese documento) |
| FR-AUD-002 (mezcla por capas) | Controlador de audio nulo | Escucha en dispositivo |
| SC-004, NFR-A11Y-006 | Requiere jugadores | `docs/perf-device.md` §4 |

## 6. Defectos encontrados y corregidos durante Implement/Verify

| Defecto | Detectado por | Corrección |
|---------|---------------|------------|
| `Δ(60 s)` = 0.4499… < `spawn_interval_min` (coma flotante) | TEST-DIF-02 | Límite explícito en `Difficulty` |
| `JSON.parse_string` registra un error ante un guardado corrupto | TEST-SAV-03 | `JSON.parse` con código de error |
| Nombres de nodo duplicados al reconstruir Colección y Misiones | TEST-UI-03 | Retirar los hijos del árbol antes de liberarlos |
| Fondo PRISM no restablecido al abandonar durante PRISM | Revisión de capturas | `GameScreen._exit_tree`; regresión TEST-UI-08 |
| Línea de costura en la zona de captura | Revisión de capturas | Corona como malla precalculada |
| Duración redondeada hacia arriba en Resultados | Revisión de capturas | `format_time(round_up)`; TEST-FMT-01 |
| Arena invadiendo el HUD en 3:4 | Diseño de `Layout` | CR-001 (ART-010) |
| Scripts de captura y estrés no compilaban con `--script` (autoloads) | Ejecución | Lanzador mínimo + director cargado en tiempo de ejecución |
