#!/usr/bin/env bash
# Ejecuta todas las comprobaciones automáticas de PRISM POP (constitución §5).
# Uso: tools/check_all.sh [--sim N] [--visual]
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
SIM=0
VISUAL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sim) SIM="$2"; shift 2 ;;
    --visual) VISUAL=1; shift ;;
    *) echo "Argumento desconocido: $1" >&2; exit 2 ;;
  esac
done
python3 -I tools/spec_lint.py
python3 -I tools/palette_check.py
python3 -I tools/check_sync.py
python3 -I tools/trace_check.py --tests
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . --audio-driver Dummy --script res://tests/run_tests.gd
if [[ "$SIM" -gt 0 ]]; then
  "$GODOT" --headless --path . --audio-driver Dummy --script res://tests/sim/run_sim.gd -- "$SIM"
fi
if [[ "$VISUAL" -eq 1 ]]; then
  xvfb-run -a -s "-screen 0 1700x2600x24" "$GODOT" --path . --rendering-driver opengl3 --resolution 1080x1920 \
    --audio-driver Dummy --script res://tests/visual/capture.gd -- "$(pwd)/docs/visual" 9x16 full
fi
