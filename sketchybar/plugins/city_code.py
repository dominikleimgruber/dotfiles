#!/usr/bin/env python3
"""Reads "<lat> <lon> [city words...]" on stdin, writes "<lat> <lon> <CODE>".

The short code keeps the cache line space-free and is what shows on the bar:
multi-part names become initials (Villars-sur-Glane -> VSG, capped at 4),
single words become their first three letters (Zurich -> ZUR). Accents are
stripped first so the label stays ASCII.
"""
import re
import sys
import unicodedata


def code_for(city: str) -> str:
    flat = unicodedata.normalize("NFKD", city)
    flat = "".join(ch for ch in flat if not unicodedata.combining(ch))
    parts = [p for p in re.split(r"[\s\-/]+", flat) if p]
    if len(parts) >= 2:
        return "".join(p[0] for p in parts).upper()[:4]
    if parts:
        return parts[0][:3].upper()
    return ""


def main() -> int:
    line = sys.stdin.read().strip()
    if not line:
        return 1
    bits = line.split()
    if len(bits) < 2:
        return 1
    lat, lon = bits[0], bits[1]
    try:
        float(lat), float(lon)
    except ValueError:
        return 1
    print(lat, lon, code_for(" ".join(bits[2:])))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
