#!/usr/bin/env python3
"""Genera los efectos de sonido y la música de PRISM POP (ADR 0006, FR-AUD-001/002).

Síntesis aditiva y sustractiva sencilla con la biblioteca estándar. Determinista:
la misma versión del script produce los mismos archivos (semilla fija).

Uso: python3 tools/gen_audio.py [directorio_salida]   (por defecto assets/audio)
"""

from __future__ import annotations

import math
import random
import struct
import sys
import wave
from pathlib import Path

RATE = 22050
TAU = 2 * math.pi
BPM = 120
BEAT = 60 / BPM
LOOP_BARS = 8
LOOP_SECONDS = LOOP_BARS * 4 * BEAT  # 16 s


def note(semitones_from_a4: float) -> float:
    return 440.0 * 2 ** (semitones_from_a4 / 12)


def silence(seconds: float) -> list[float]:
    return [0.0] * int(seconds * RATE)


def envelope(n: int, attack: float, release: float) -> list[float]:
    a = max(1, int(attack * RATE))
    r = max(1, int(release * RATE))
    out = []
    for i in range(n):
        level = min(1.0, i / a)
        if i > n - r:
            level *= max(0.0, (n - i) / r)
        out.append(level)
    return out


def tone(freq: float, seconds: float, *, wave_type: str = "sine", attack: float = 0.005,
         release: float = 0.05, decay: float = 0.0, glide_to: float | None = None, harmonics: int = 1) -> list[float]:
    n = int(seconds * RATE)
    env = envelope(n, attack, release)
    phase = 0.0
    out = []
    for i in range(n):
        f = freq if glide_to is None else freq + (glide_to - freq) * i / n
        phase += TAU * f / RATE
        if wave_type == "sine":
            value = sum(math.sin(phase * h) / h for h in range(1, harmonics + 1))
        elif wave_type == "saw":
            value = sum(((-1) ** (h + 1)) * math.sin(phase * h) / h for h in range(1, 8))
        elif wave_type == "square":
            value = sum(math.sin(phase * h) / h for h in range(1, 9, 2))
        else:
            raise ValueError(wave_type)
        if decay:
            value *= math.exp(-decay * i / RATE)
        out.append(value * env[i])
    return out


def noise(seconds: float, rng: random.Random, decay: float = 30.0) -> list[float]:
    n = int(seconds * RATE)
    smooth = 0.0
    out = []
    for i in range(n):
        smooth = 0.6 * smooth + 0.4 * rng.uniform(-1, 1)
        out.append(smooth * math.exp(-decay * i / RATE))
    return out


def mix(*tracks: tuple[list[float], float, float]) -> list[float]:
    """Mezcla (pista, ganancia, desplazamiento en segundos)."""
    length = max(int(offset * RATE) + len(track) for track, _, offset in tracks)
    out = [0.0] * length
    for track, gain, offset in tracks:
        start = int(offset * RATE)
        for i, value in enumerate(track):
            out[start + i] += value * gain
    return out


def sequence(notes: list[float], step: float, **kwargs: object) -> list[float]:
    return mix(*[(tone(note(n), step * 1.6, **kwargs), 1.0, i * step) for i, n in enumerate(notes)])


def normalize(samples: list[float], peak: float = 0.85) -> list[float]:
    top = max(1e-9, max(abs(s) for s in samples))
    return [s * peak / top for s in samples]


def write(path: Path, samples: list[float], peak: float = 0.85) -> None:
    data = normalize(samples, peak)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in data))


def sound_effects(rng: random.Random) -> dict[str, tuple[list[float], float]]:
    e5, b5 = note(7), note(14)
    return {
        "pulse_empty": (mix((noise(0.06, rng, 60), 0.5, 0), (tone(note(-5), 0.06, release=0.04), 0.4, 0)), 0.35),
        "hit": (mix((tone(e5, 0.18, harmonics=3, decay=18), 1.0, 0), (tone(b5, 0.12, decay=25), 0.4, 0.01)), 0.8),
        "hit_crystal": (mix(*[(tone(note(n), 0.4, harmonics=2, decay=8), 0.6, i * 0.04) for i, n in enumerate([12, 16, 19, 24])]), 0.8),
        "error_color": (mix((tone(note(-10), 0.25, wave_type="saw", glide_to=note(-16), release=0.08), 0.6, 0),
                            (tone(note(-9.6), 0.25, wave_type="saw", glide_to=note(-15.6), release=0.08), 0.6, 0)), 0.75),
        "omission": (mix((tone(note(-33), 0.3, glide_to=note(-40), decay=10), 1.0, 0), (noise(0.15, rng, 25), 0.5, 0)), 0.85),
        "combo_tier_up": (sequence([7, 11, 14], 0.07, harmonics=2, release=0.06), 0.7),
        "combo_break": (tone(note(2), 0.3, wave_type="square", glide_to=note(-10), release=0.1), 0.5),
        "prism_start": (mix((tone(note(-12), 0.6, wave_type="saw", glide_to=note(12), release=0.15), 0.5, 0),
                            (sequence([12, 16, 19, 23, 24], 0.08, harmonics=2), 0.6, 0.2)), 0.85),
        "prism_warning": (mix((tone(note(12), 0.12, release=0.04), 1.0, 0), (tone(note(12), 0.12, release=0.04), 1.0, 0.22)), 0.6),
        "prism_end": (tone(note(12), 0.4, wave_type="saw", glide_to=note(-12), release=0.15), 0.5),
        "new_color": (sequence([3, 10, 15], 0.1, harmonics=3, decay=4), 0.7),
        "energy_critical": (mix((tone(note(-36), 0.12, decay=20), 1.0, 0), (tone(note(-36), 0.12, decay=20), 0.8, 0.22)), 0.9),
        "game_over": (sequence([0, -4, -7, -12], 0.18, wave_type="square", release=0.15), 0.6),
        "completed": (sequence([0, 4, 7, 12, 16], 0.14, harmonics=3, release=0.2), 0.7),
        "record": (mix((sequence([7, 12, 16, 19], 0.12, harmonics=3), 0.8, 0), (tone(note(24), 0.6, harmonics=2, decay=3), 0.5, 0.48)), 0.8),
        "ui_tap": (mix((tone(note(19), 0.04, release=0.03), 0.6, 0), (noise(0.02, rng, 120), 0.3, 0)), 0.45),
        "ui_back": (tone(note(10), 0.05, release=0.035), 0.4),
        "purchase": (sequence([12, 19, 24], 0.06, harmonics=2, decay=6), 0.7),
        "claim": (sequence([7, 14, 19, 26], 0.05, harmonics=2, decay=5), 0.7),
    }


CHORDS = [[-12, -9, -5], [-16, -12, -9], [-9, -5, -2], [-14, -10, -7]]  # La m, Fa, Do, Sol


def music_loop(layer: str, rng: random.Random) -> list[float]:
    out = silence(LOOP_SECONDS)
    bar = 4 * BEAT

    def add(samples: list[float], start: float, gain: float) -> None:
        offset = int(start * RATE)
        for i, value in enumerate(samples):
            if offset + i < len(out):
                out[offset + i] += value * gain

    for b in range(LOOP_BARS):
        chord = CHORDS[b % 4]
        start = b * bar
        if layer in ("menu", "game_base"):
            for n in chord:
                add(tone(note(n), bar, attack=0.4, release=0.5, harmonics=2), start, 0.25)
        if layer == "game_base":
            for i in range(8):
                add(tone(note(chord[0] - 12), BEAT / 2, wave_type="saw", attack=0.005, release=0.1, decay=6), start + i * BEAT / 2, 0.35)
            for i in range(4):
                add(noise(0.08, rng, 50), start + i * BEAT, 0.25)
        if layer == "game_intensity":
            for i in range(16):
                n = chord[i % 3] + 12 * (1 + (i // 3) % 2)
                add(tone(note(n), BEAT / 4, harmonics=2, release=0.05, decay=10), start + i * BEAT / 4, 0.3)
        if layer == "game_prism":
            for i in range(16):
                n = chord[(i * 2) % 3] + 24 + (i % 4 == 3) * 7
                add(tone(note(n), BEAT / 4, harmonics=1, release=0.06, decay=8), start + i * BEAT / 4, 0.22)
        if layer == "menu":
            for i in range(4):
                add(tone(note(chord[i % 3] + 12), BEAT, attack=0.05, release=0.3, decay=2), start + i * BEAT, 0.12)
    return out


def main() -> int:
    out_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "audio"
    out_dir.mkdir(parents=True, exist_ok=True)
    rng = random.Random(20261023)
    for name, (samples, peak) in sound_effects(rng).items():
        write(out_dir / f"{name}.wav", samples, peak)
    for layer in ("menu", "game_base", "game_intensity", "game_prism"):
        write(out_dir / f"music_{layer}.wav", music_loop(layer, rng), 0.6)
    print(f"Audio generado en {out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
