#!/usr/bin/env python3
"""Comprueba que el código coincide con los documentos fuente de verdad (ADR 0004).

- parameters.md §2/§4 (valor por defecto, mínimo, máximo) ↔ src/config/game_config.gd
- parameters.md §5 (precios) ↔ src/progression/cosmetics_catalog.gd
- art-direction.md ART-001 (paleta) ↔ src/ui/palette.gd

Uso: python3 tools/check_sync.py   (código de salida 1 si hay diferencias)
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FEATURE = ROOT / "specs" / "001-prism-pop"


def number(text: str) -> float | None:
    text = text.strip().replace("−", "-").replace(" ", "").replace(" ", "")
    try:
        if "/" in text:
            numerator, denominator = text.split("/", 1)
            return float(numerator) / float(denominator)
        return float(text)
    except ValueError:
        return None


def main() -> int:
    errors: list[str] = []
    params_doc = (FEATURE / "parameters.md").read_text(encoding="utf-8")
    config_code = (ROOT / "src" / "config" / "game_config.gd").read_text(encoding="utf-8")

    doc_params: dict[str, tuple[float | None, float | None, float | None]] = {}
    for line in params_doc.splitlines():
        cells = [c.strip() for c in line.split("|")]
        if len(cells) > 6 and re.fullmatch(r"`[a-z0-9_]+`", cells[1]) and cells[2] not in ("Núcleo", "Estela"):
            name = cells[1].strip("`")
            doc_params[name] = (number(cells[4]), number(cells[5]), number(cells[6]))

    code_defaults = {m.group(1): number(m.group(2)) for m in re.finditer(r"@export var (\w+): \w+ = ([^\n]+)", config_code)}
    code_ranges = {m.group(1): (number(m.group(2)), number(m.group(3))) for m in re.finditer(r'"(\w+)": Vector2\(([^,]+), ([^)]+)\)', config_code)}

    for name, (default, low, high) in doc_params.items():
        if name not in code_defaults:
            errors.append(f"{name}: documentado pero no existe en GameConfig")
            continue
        if default is None or abs(code_defaults[name] - default) > 1e-9:
            errors.append(f"{name}: defecto doc={default} código={code_defaults[name]}")
        if name in code_ranges and low is not None and high is not None:
            if abs(code_ranges[name][0] - low) > 1e-9 or abs(code_ranges[name][1] - high) > 1e-9:
                errors.append(f"{name}: rango doc=[{low}, {high}] código={list(code_ranges[name])}")
        elif low is not None and high is not None:
            errors.append(f"{name}: rango sin comprobar en GameConfig.RANGES")
    for name in code_defaults:
        if name not in doc_params:
            errors.append(f"{name}: existe en GameConfig pero no está documentado")

    catalog = (ROOT / "src" / "progression" / "cosmetics_catalog.gd").read_text(encoding="utf-8")
    code_prices = {m.group(1): int(m.group(2)) for m in re.finditer(r'"(\w+)": \{[^}]*"price": (\d+)', catalog)}
    for line in params_doc.splitlines():
        cells = [c.strip() for c in line.split("|")]
        if len(cells) > 5 and re.fullmatch(r"`(core|trail)_\w+`", cells[1]) and cells[2] in ("Núcleo", "Estela"):
            item = cells[1].strip("`")
            if code_prices.get(item) != int(cells[4]):
                errors.append(f"{item}: precio doc={cells[4]} código={code_prices.get(item)}")

    art = (FEATURE / "art-direction.md").read_text(encoding="utf-8")
    palette = (ROOT / "src" / "ui" / "palette.gd").read_text(encoding="utf-8")
    doc_colors = {m.group(1): m.group(2).upper() for m in re.finditer(r"^\|\s*`([\w.]+)`\s*\|\s*`(#[0-9A-Fa-f]{6})`", art, re.M)}
    code_colors = {m.group(1): m.group(2).upper() for m in re.finditer(r'const (\w+) := Color\("(#[0-9A-Fa-f]{6})"\)', palette)}
    for token, hex_color in doc_colors.items():
        const = token.replace(".", "_").upper()
        if code_colors.get(const) != hex_color:
            errors.append(f"{token}: doc={hex_color} código={code_colors.get(const)}")

    print(f"Parámetros documentados: {len(doc_params)}; en código: {len(code_defaults)}; "
          f"precios: {len(code_prices)}; colores: {len(doc_colors)}")
    for error in errors:
        print(f"DIFERENCIA {error}")
    print("RESULTADO:", "APROBADO" if not errors else "FALLIDO")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
