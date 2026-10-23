#!/usr/bin/env python3
"""Verifica la paleta de PRISM POP definida en specs/001-prism-pop/art-direction.md.

Lee la tabla de tokens (ART-001) y la tabla de pares de contraste (ART-003) del
documento, calcula el contraste WCAG 2.x y la distancia ΔE (CIE76) entre los
colores de orbe con visión normal y con simulación de deficiencias de color
(Machado, Oliveira y Fernandes, 2009; severidad 1.0).

Uso:
    python3 tools/palette_check.py [--report RUTA] [--svg RUTA]

Código de salida 0 si todos los requisitos se cumplen, 1 en otro caso.
Solo usa la biblioteca estándar.
"""

from __future__ import annotations

import argparse
import itertools
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ART_DOC = ROOT / "specs" / "001-prism-pop" / "art-direction.md"

TOKEN_ROW = re.compile(r"^\|\s*`([\w.]+)`\s*\|\s*`(#[0-9A-Fa-f]{6})`\s*\|")
CONTRAST_ROW = re.compile(r"^\|\s*`([\w.]+)`\s*\|\s*`([\w.]+)`\s*\|\s*([0-9.]+)\s*\|")

ORB_TOKENS = ["orb.cyan", "orb.magenta", "orb.yellow", "orb.violet"]
ORB_NAMES = {"orb.cyan": "CIAN", "orb.magenta": "MAGENTA", "orb.yellow": "AMARILLO", "orb.violet": "VIOLETA", "orb.crystal": "CRISTAL"}
MIN_DELTA_E_NORMAL = 20.0

# Matrices de Machado et al. (2009), severidad 1.0, sobre RGB lineal.
CVD_MATRICES: dict[str, list[list[float]]] = {
    "protanopia": [
        [0.152286, 1.052583, -0.204868],
        [0.114503, 0.786281, 0.099216],
        [-0.003882, -0.048116, 1.051998],
    ],
    "deuteranopia": [
        [0.367322, 0.860646, -0.227968],
        [0.280085, 0.672501, 0.047413],
        [-0.011820, 0.042940, 0.968881],
    ],
    "tritanopia": [
        [1.255528, -0.076749, -0.178779],
        [-0.078411, 0.930809, 0.147602],
        [0.004733, 0.691367, 0.303900],
    ],
}


def parse_doc(path: Path) -> tuple[dict[str, str], list[tuple[str, str, float]]]:
    tokens: dict[str, str] = {}
    pairs: list[tuple[str, str, float]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        token_match = TOKEN_ROW.match(line)
        if token_match:
            tokens[token_match.group(1)] = token_match.group(2).upper()
            continue
        pair_match = CONTRAST_ROW.match(line)
        if pair_match:
            pairs.append((pair_match.group(1), pair_match.group(2), float(pair_match.group(3))))
    return tokens, pairs


def hex_to_srgb(hex_color: str) -> tuple[float, float, float]:
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) / 255.0 for i in (0, 2, 4))  # type: ignore[return-value]


def srgb_to_linear(c: float) -> float:
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def linear_to_srgb(c: float) -> float:
    c = min(max(c, 0.0), 1.0)
    return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055


def relative_luminance(hex_color: str) -> float:
    r, g, b = (srgb_to_linear(c) for c in hex_to_srgb(hex_color))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(fg: str, bg: str) -> float:
    lighter, darker = sorted((relative_luminance(fg), relative_luminance(bg)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def simulate(hex_color: str, matrix: list[list[float]] | None) -> tuple[float, float, float]:
    linear = [srgb_to_linear(c) for c in hex_to_srgb(hex_color)]
    if matrix is None:
        return tuple(linear_to_srgb(c) for c in linear)  # type: ignore[return-value]
    mixed = [sum(row[i] * linear[i] for i in range(3)) for row in matrix]
    return tuple(linear_to_srgb(c) for c in mixed)  # type: ignore[return-value]


def srgb_to_lab(rgb: tuple[float, float, float]) -> tuple[float, float, float]:
    r, g, b = (srgb_to_linear(c) for c in rgb)
    x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047
    y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b
    z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883

    def f(t: float) -> float:
        return t ** (1 / 3) if t > 216 / 24389 else (24389 / 27 * t + 16) / 116

    fx, fy, fz = f(x), f(y), f(z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def delta_e76(a: tuple[float, float, float], b: tuple[float, float, float]) -> float:
    return sum((p - q) ** 2 for p, q in zip(srgb_to_lab(a), srgb_to_lab(b))) ** 0.5


def build_report(tokens: dict[str, str], pairs: list[tuple[str, str, float]]) -> tuple[list[str], bool]:
    lines: list[str] = []
    ok = True

    lines.append(f"Fuente: {ART_DOC.relative_to(ROOT)}")
    lines.append(f"Tokens leídos: {len(tokens)}; pares de contraste: {len(pairs)}")
    lines.append("")
    lines.append("== ART-003 Contraste WCAG ==")
    for fg, bg, minimum in pairs:
        if fg not in tokens or bg not in tokens:
            lines.append(f"FALLO  token desconocido en el par {fg} / {bg}")
            ok = False
            continue
        ratio = contrast_ratio(tokens[fg], tokens[bg])
        passed = ratio >= minimum
        ok &= passed
        lines.append(f"{'OK   ' if passed else 'FALLO'}  {fg:<16} sobre {bg:<16} {ratio:5.2f}:1 (mín {minimum})")

    lines.append("")
    lines.append(f"== ART-004 Distinción entre colores de orbe (ΔE76; requisito con visión normal ≥ {MIN_DELTA_E_NORMAL}) ==")
    missing = [t for t in ORB_TOKENS if t not in tokens]
    if missing:
        lines.append(f"FALLO  faltan tokens de orbe: {missing}")
        return lines, False
    for vision, matrix in [("normal", None), *CVD_MATRICES.items()]:
        lines.append(f"-- {vision}")
        for a, b in itertools.combinations(ORB_TOKENS, 2):
            de = delta_e76(simulate(tokens[a], matrix), simulate(tokens[b], matrix))
            if vision == "normal":
                passed = de >= MIN_DELTA_E_NORMAL
                ok &= passed
                status = "OK   " if passed else "FALLO"
            else:
                status = "OK   " if de >= MIN_DELTA_E_NORMAL else "AVISO"
            lines.append(f"{status}  {a:<12} vs {b:<12} ΔE = {de:6.1f}")
    lines.append("")
    lines.append("AVISO = par poco distinguible en esa simulación; depende de los símbolos (ART-002).")
    lines.append("")
    lines.append(f"RESULTADO GLOBAL: {'APROBADO' if ok else 'FALLIDO'}")
    return lines, ok


def write_svg(tokens: dict[str, str], path: Path) -> None:
    """Moodboard esquemático: paleta, símbolos y maqueta de disposición (no es arte final)."""
    night = tokens["bg.night"]
    text = tokens["text.primary"]
    secondary = tokens["text.secondary"]
    glyph = tokens["ui.glyph"]
    orbs = [(t, tokens[t]) for t in [*ORB_TOKENS, "orb.crystal"]]

    def symbol(kind: str, cx: float, cy: float, s: float) -> str:
        if kind == "orb.cyan":
            return f'<polygon points="{cx},{cy - s} {cx + s * 0.87},{cy + s * 0.5} {cx - s * 0.87},{cy + s * 0.5}" fill="{glyph}" fill-opacity="0.85"/>'
        if kind == "orb.magenta":
            return f'<rect x="{cx - s * 0.7}" y="{cy - s * 0.7}" width="{s * 1.4}" height="{s * 1.4}" fill="{glyph}" fill-opacity="0.85"/>'
        if kind == "orb.yellow":
            w = s * 0.45
            return (f'<rect x="{cx - w / 2}" y="{cy - s}" width="{w}" height="{s * 2}" fill="{glyph}" fill-opacity="0.85"/>'
                    f'<rect x="{cx - s}" y="{cy - w / 2}" width="{s * 2}" height="{w}" fill="{glyph}" fill-opacity="0.85"/>')
        if kind == "orb.violet":
            import math
            pts = []
            for i in range(10):
                radius = s if i % 2 == 0 else s * 0.42
                angle = -math.pi / 2 + i * math.pi / 5
                pts.append(f"{cx + radius * math.cos(angle):.1f},{cy + radius * math.sin(angle):.1f}")
            return f'<polygon points="{" ".join(pts)}" fill="{glyph}" fill-opacity="0.85"/>'
        return f'<polygon points="{cx},{cy - s} {cx + s},{cy} {cx},{cy + s} {cx - s},{cy}" fill="none" stroke="{glyph}" stroke-width="3"/>'

    parts: list[str] = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1000" viewBox="0 0 1200 1000" font-family="sans-serif">',
        "<defs>",
        f'<linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{tokens["bg.deep"]}"/><stop offset="1" stop-color="{night}"/></linearGradient>',
    ]
    for token, color in orbs:
        gid = token.replace(".", "_")
        parts.append(f'<radialGradient id="{gid}"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.5"/><stop offset="0.45" stop-color="{color}"/><stop offset="1" stop-color="{color}"/></radialGradient>')
    parts.append("</defs>")
    parts.append(f'<rect width="1200" height="1000" fill="{night}"/>')
    parts.append(f'<text x="40" y="60" fill="{text}" font-size="32" font-weight="bold">PRISM POP — moodboard esquemático (generado; no es arte final)</text>')

    parts.append(f'<text x="40" y="120" fill="{secondary}" font-size="20">Paleta (ART-001)</text>')
    for i, (token, color) in enumerate(tokens.items()):
        x, y = 40 + (i % 7) * 90, 140 + (i // 7) * 120
        parts.append(f'<rect x="{x}" y="{y}" width="70" height="70" rx="10" fill="{color}" stroke="{secondary}" stroke-opacity="0.4"/>')
        parts.append(f'<text x="{x}" y="{y + 88}" fill="{text}" font-size="11">{token}</text>')
        parts.append(f'<text x="{x}" y="{y + 102}" fill="{secondary}" font-size="11">{color}</text>')

    parts.append(f'<text x="40" y="420" fill="{secondary}" font-size="20">Orbes y símbolos (ART-002, ART-015)</text>')
    for i, (token, color) in enumerate(orbs):
        cx, cy = 90 + i * 120, 500
        parts.append(f'<circle cx="{cx}" cy="{cy}" r="56" fill="{color}" fill-opacity="0.25"/>')
        parts.append(f'<circle cx="{cx}" cy="{cy}" r="36" fill="url(#{token.replace(".", "_")})"/>')
        parts.append(symbol(token, cx, cy, 20))
        parts.append(f'<text x="{cx}" y="{cy + 80}" fill="{text}" font-size="13" text-anchor="middle">{ORB_NAMES[token]}</text>')

    # Maqueta de disposición a escala 1080x1920 -> 360x640 (ART-010, ART-014, ART-020..022).
    ox, oy, scale = 780, 120, 1 / 3
    dp = 1080 / 411 * scale
    w, h = 1080 * scale, 1920 * scale
    parts.append(f'<text x="{ox}" y="{oy - 20}" fill="{secondary}" font-size="20">Disposición 1080×1920 (ART-010…022)</text>')
    parts.append(f'<rect x="{ox}" y="{oy}" width="{w}" height="{h}" fill="url(#bg)" stroke="{secondary}" stroke-opacity="0.5"/>')
    radius = 0.42 * 1080 * scale
    cx, cy = ox + w / 2, oy + h / 2
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius}" fill="none" stroke="{text}" stroke-opacity="0.08"/>')
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius * 1.05}" fill="none" stroke="{secondary}" stroke-opacity="0.3" stroke-dasharray="4 4"/>')
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius * 0.27}" fill="none" stroke="{text}" stroke-opacity="0.04" stroke-width="{radius * 0.20}"/>')
    for zone_r in (0.17, 0.37):
        parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius * zone_r}" fill="none" stroke="{text}" stroke-opacity="0.25" stroke-width="{2 * dp}"/>')
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius * 0.12}" fill="url(#orb_cyan)"/>')
    parts.append(symbol("orb.cyan", cx, cy, radius * 0.07))
    for (token, _), (dx, dy) in zip(orbs[:3], [(0.3, -0.75), (-0.62, 0.15), (0.2, 0.27)]):
        parts.append(f'<circle cx="{cx + dx * radius}" cy="{cy + dy * radius}" r="{radius * 0.05}" fill="url(#{token.replace(".", "_")})"/>')
    parts.append(f'<text x="{cx}" y="{oy + 60}" fill="{text}" font-size="{40 * dp}" font-weight="bold" text-anchor="middle">12 450</text>')
    parts.append(f'<text x="{cx}" y="{oy + 60 + 26 * dp}" fill="{tokens["orb.yellow"]}" font-size="{24 * dp}" text-anchor="middle">×2.0</text>')
    parts.append(f'<text x="{ox + 16 * dp}" y="{oy + 30}" fill="{text}" font-size="{18 * dp}">1:02</text>')
    parts.append(f'<rect x="{ox + w - 64 * dp}" y="{oy + 16 * dp}" width="{48 * dp}" height="{48 * dp}" fill="none" stroke="{secondary}" stroke-dasharray="3 3"/>')
    nx, ny = cx, cy + radius * 1.05 + 12 * dp + radius * 0.04
    parts.append(f'<circle cx="{nx}" cy="{ny}" r="{radius * 0.04}" fill="url(#orb_magenta)"/>')
    parts.append(f'<text x="{nx}" y="{ny + 20 * dp}" fill="{secondary}" font-size="{14 * dp}" text-anchor="middle">SIGUIENTE</text>')
    by = oy + h - 24 * dp - 8 * dp
    bw = (w - 48 * dp) / 2
    parts.append(f'<text x="{ox + 16 * dp}" y="{by - 6}" fill="{secondary}" font-size="{14 * dp}">ENERGÍA</text>')
    parts.append(f'<rect x="{ox + 16 * dp}" y="{by}" width="{bw}" height="{8 * dp}" fill="{text}" fill-opacity="0.85"/>')
    parts.append(f'<text x="{ox + 32 * dp + bw}" y="{by - 6}" fill="{secondary}" font-size="{14 * dp}">PRISM</text>')
    parts.append(f'<rect x="{ox + 32 * dp + bw}" y="{by}" width="{bw * 0.6}" height="{8 * dp}" fill="{tokens["orb.violet"]}"/>')
    parts.append("</svg>")
    path.write_text("\n".join(parts) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--report", type=Path, help="Escribe el informe en esta ruta además de mostrarlo.")
    parser.add_argument("--svg", type=Path, help="Genera el moodboard esquemático en esta ruta.")
    args = parser.parse_args()

    tokens, pairs = parse_doc(ART_DOC)
    if not tokens or not pairs:
        print(f"FALLO: no se encontraron tablas de tokens o de contraste en {ART_DOC}", file=sys.stderr)
        return 1
    lines, ok = build_report(tokens, pairs)
    report = "\n".join(lines) + "\n"
    print(report, end="")
    if args.report:
        args.report.write_text(report, encoding="utf-8")
    if args.svg:
        write_svg(tokens, args.svg)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
