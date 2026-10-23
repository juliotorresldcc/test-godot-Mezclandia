#!/usr/bin/env python3
"""Comprobaciones de coherencia de los artefactos SDD de PRISM POP.

1. Identificadores de requisito duplicados en spec.md y art-direction.md.
2. Parámetros citados (`snake_case` en monoespaciado) en spec.md y
   art-direction.md que no están definidos en parameters.md.
3. Parámetros definidos en parameters.md que no cita ningún documento.
4. Requisitos marcados como dependientes de decisiones abiertas.

Uso: python3 tools/spec_lint.py   (código de salida 1 si hay errores)
"""

from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

FEATURE = Path(__file__).resolve().parent.parent / "specs" / "001-prism-pop"
SPEC = FEATURE / "spec.md"
ART = FEATURE / "art-direction.md"
PARAMS = FEATURE / "parameters.md"

REQ_DEF = re.compile(r"^(?:- )?\*\*((?:FR|NFR|SC)-[A-Z0-9]+(?:-[A-Z0-9]+)*-?\d*)\*\*|^\| (ART-\d{3}) \||^- \*\*(ART-\d{3})\*\*", re.M)
PARAM_DEF = re.compile(r"^\| `([a-z][a-z0-9_]*)` \|", re.M)
CODE_SPAN = re.compile(r"`([^`\n]+)`")
# Excluye tokens de color con punto (text.on_accent) y nombres de archivo (palette_check.py).
SNAKE = re.compile(r"(?<![\w./])([a-z][a-z0-9]*(?:_[a-z0-9]+)+)\b(?!\.\w)")
OPEN_DECISION = re.compile(r"NEEDS CLARIFICATION: (D-\d+)")

# Identificadores en monoespaciado que no son parámetros: ids de sonido y de cosméticos,
# funciones y variables de estado definidas en spec.md (p. ej. p_obj en §3.11,
# racha_no_objetivo en FR-SEQ-004) y nombres de estadísticas (FR-STAT-010, FR-GS-006).
NOT_PARAMS = re.compile(
    r"^(?:core_(?:default|pulsar|nebula|singularity)|trail_\w+|ui_\w+|hit|hit_crystal|pulse_empty|error_color"
    r"|combo_tier_up|combo_break|prism_start|prism_warning|prism_end|new_color|energy_critical|game_over"
    r"|round_half_up|p_obj|t_ultima|racha_no_objetivo|errores_de_color|orbes_cristal_capturados"
    r"|sesiones_abandonadas|cristales_desbordados)$"
)


def snake_refs(text: str) -> set[str]:
    return {name for span in CODE_SPAN.findall(text) for name in SNAKE.findall(span)}


def main() -> int:
    spec_text = SPEC.read_text(encoding="utf-8")
    art_text = ART.read_text(encoding="utf-8")
    params_text = PARAMS.read_text(encoding="utf-8")
    errors: list[str] = []

    ids = [next(g for g in m.groups() if g) for m in REQ_DEF.finditer(spec_text + "\n" + art_text)]
    duplicates = sorted(i for i, n in Counter(ids).items() if n > 1)
    print(f"Requisitos definidos: {len(ids)} (FR: {sum(i.startswith('FR-') for i in ids)}, "
          f"NFR: {sum(i.startswith('NFR-') for i in ids)}, SC: {sum(i.startswith('SC-') for i in ids)}, "
          f"ART: {sum(i.startswith('ART-') for i in ids)})")
    if duplicates:
        errors.append(f"IDs duplicados: {duplicates}")

    defined = set(PARAM_DEF.findall(params_text))
    referenced = {p for p in snake_refs(spec_text + "\n" + art_text) if not NOT_PARAMS.match(p)}
    undefined = sorted(referenced - defined)
    unused = sorted(defined - referenced - snake_refs(params_text.split("## 3.")[1]))
    print(f"Parámetros definidos: {len(defined)}; citados en spec/arte: {len(referenced)}")
    if undefined:
        errors.append(f"Parámetros citados pero no definidos en parameters.md: {undefined}")
    if unused:
        print(f"AVISO parámetros definidos sin cita en spec/arte ni en restricciones: {unused}")

    open_refs = Counter(OPEN_DECISION.findall(spec_text + art_text + params_text))
    print(f"Marcas NEEDS CLARIFICATION por decisión: {dict(sorted(open_refs.items()))}")

    for error in errors:
        print(f"ERROR {error}")
    print("RESULTADO:", "FALLIDO" if errors else "APROBADO")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
