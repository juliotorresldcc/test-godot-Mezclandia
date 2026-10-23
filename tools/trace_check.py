#!/usr/bin/env python3
"""Cobertura de requisitos de PRISM POP.

- Fase Analyze: cada requisito de spec.md y art-direction.md debe aparecer en
  la columna «Requisitos» de tasks.md (admite IDs exactos, comodines `FR-GS-*`
  y rangos `FR-PRM-001…006`).
- Fase Verify (--tests): cada requisito debe aparecer en traceability.md con
  al menos una prueba o una excepción documentada.

Uso: python3 tools/trace_check.py [--tests]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

FEATURE = Path(__file__).resolve().parent.parent / "specs" / "001-prism-pop"
REQ_DEF = re.compile(r"^(?:- )?\*\*((?:FR|NFR)-[A-Z0-9]+-\d{3}|SC-\d{3})\*\*|^\| (ART-\d{3}) \||^- \*\*(ART-\d{3})\*\*", re.M)
REF = re.compile(r"((?:FR|NFR|SC|ART)(?:-[A-Z0-9]+)*?)-(\*|\d{3})(?:…(\d{3}))?")


def defined_requirements() -> list[str]:
    text = (FEATURE / "spec.md").read_text(encoding="utf-8") + (FEATURE / "art-direction.md").read_text(encoding="utf-8")
    seen: list[str] = []
    for match in REQ_DEF.finditer(text):
        req = next(g for g in match.groups() if g)
        if req not in seen:
            seen.append(req)
    return seen


SLASH = re.compile(r"((?:FR|NFR|SC|ART)(?:-[A-Z0-9]+)*?)-(\d{3})((?:/\d{3})+)")


def expand(cell: str, universe: list[str]) -> set[str]:
    # «FR-CORE-002/003» equivale a «FR-CORE-002, FR-CORE-003».
    cell = SLASH.sub(lambda m: ", ".join(f"{m.group(1)}-{n}" for n in [m.group(2), *m.group(3).strip("/").split("/")]), cell)
    covered: set[str] = set()
    for prefix, start, end in REF.findall(cell):
        for req in universe:
            if not req.startswith(prefix + "-"):
                continue
            number = req[len(prefix) + 1 :]
            if not number.isdigit():
                continue
            if start == "*" or (end and int(start) <= int(number) <= int(end)) or (not end and number == start):
                covered.add(req)
    return covered


def column(path: Path, index: int) -> list[str]:
    cells = []
    for line in path.read_text(encoding="utf-8").splitlines():
        parts = [p.strip() for p in line.split("|")]
        if len(parts) > index + 1 and re.match(r"^(T\d{2}|(FR|NFR|SC|ART)-)", parts[1]):
            cells.append(parts[index + 1] if index else parts[1])
    return cells


def main() -> int:
    universe = defined_requirements()
    tasks_cells = column(FEATURE / "tasks.md", 1)
    covered = set().union(*(expand(c, universe) for c in tasks_cells)) if tasks_cells else set()
    missing = [r for r in universe if r not in covered]
    print(f"Requisitos: {len(universe)}; cubiertos por tareas: {len(universe) - len(missing)}")
    for req in missing:
        print(f"SIN TAREA {req}")
    ok = not missing

    if "--tests" in sys.argv:
        trace = FEATURE / "traceability.md"
        rows = {}
        for line in trace.read_text(encoding="utf-8").splitlines():
            parts = [p.strip() for p in line.split("|")]
            if len(parts) > 6 and re.match(r"^(FR|NFR|SC|ART)-", parts[1]):
                rows[parts[1]] = parts
        untraced = [r for r in universe if r not in rows]
        no_evidence = [r for r, p in rows.items() if not p[5] or p[5] in {"—", "-"}]
        print(f"En la matriz: {len(rows)}; sin fila: {len(untraced)}; sin prueba ni excepción: {len(no_evidence)}")
        for req in untraced:
            print(f"SIN FILA {req}")
        for req in no_evidence:
            print(f"SIN PRUEBA {req}")
        ok = ok and not untraced and not no_evidence

    print("RESULTADO:", "APROBADO" if ok else "FALLIDO")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
