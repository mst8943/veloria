"""Veloria'daki yerelleştirme yüzeyini sayar; metni değiştirmez."""
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TURKISH = re.compile(r"[çğıöşüÇĞİÖŞÜ]")
STRING = re.compile(r'(?<!\\)"((?:\\.|[^"\\])*)"')
FORMAT = re.compile(r"%(?:\d+\$)?[+#0\- .]*\d*(?:\.\d+)?[sdif%]|\{[^{}]+\}")
TEXT_KEYS = {"title", "text", "news", "label", "name", "headline", "lead", "body", "head", "sub", "motto", "weather", "ad", "channel", "red_line", "weak_point", "desc"}
RECURSIVE_TEXT_FILES = {
    "content_reports.json",
    "content_council.json",
    "content_achievements.json",
    "content_history.json",
}


def gd_rows() -> tuple[list[tuple[str, int, str, str]], Counter[str], list[tuple[str, int, str]]]:
    rows: list[tuple[str, int, str, str]] = []
    counts: Counter[str] = Counter()
    risks: list[tuple[str, int, str]] = []
    for path in sorted((ROOT / "game").rglob("*.gd")):
        rel = path.relative_to(ROOT).as_posix()
        for no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            strings = [m.group(1) for m in STRING.finditer(line) if TURKISH.search(m.group(1))]
            if strings:
                counts[rel] += len(strings)
                for value in strings:
                    fmt = ", ".join(FORMAT.findall(value)) or "-"
                    rows.append((rel, no, value.replace("|", "\\|"), fmt))
            if "Sim.ek(" in line or ".ek(" in line:
                risks.append((rel, no, "ek() ek uyumu: tüm cümle ayrı çevirilmeli"))
            if strings and ("==" in line or ".has(" in line or "match " in line or "PRIZES" in line):
                risks.append((rel, no, "Türkçe metin iç anahtar/karşılaştırma olabilir; gösterimde çevir, anahtarı koru"))
    return rows, counts, risks


def json_stats() -> list[tuple[str, int, int, int]]:
    out: list[tuple[str, int, int, int]] = []
    for path in sorted((ROOT / "game" / "data").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        texts: list[str] = []
        recursive_text = path.name in RECURSIVE_TEXT_FILES

        def walk(value: object, key: str = "") -> None:
            if isinstance(value, dict):
                for k, v in value.items():
                    # Council expert lists are actor ids, never player text.
                    if path.name == "content_council.json" and k == "experts":
                        continue
                    walk(v, str(k))
            elif isinstance(value, list):
                for v in value:
                    walk(v, key)
            elif isinstance(value, str) and (recursive_text or key in TEXT_KEYS):
                texts.append(value)

        walk(data)
        out.append((path.name, len(texts), sum(len(t.split()) for t in texts), sum(1 for t in texts if TURKISH.search(t))))
    return out


def main() -> None:
    rows, counts, risks = gd_rows()
    print("# İngilizce yerelleştirme envanteri\n")
    print("Bu rapor `tools/i18n_scan.py` ile üretilir. Sayılar metin yüzeyini gösterir; oyun mantığını değiştirmez.\n")
    print("## GDScript Türkçe sabitleri\n")
    print("| Dosya | Sabit sayısı |")
    print("|---|---:|")
    for path, count in sorted(counts.items()):
        print(f"| `{path}` | {count} |")
    print(f"\nToplam: **{len(rows)}** Türkçe sabit.\n")
    print("## JSON oyuncu metinleri\n")
    print("| Dosya | Metin alanı | Kelime | Türkçe karakterli |")
    print("|---|---:|---:|---:|")
    for name, fields, words, turkish in json_stats():
        print(f"| `{name}` | {fields} | {words} | {turkish} |")
    print("\n## Riskli noktalar\n")
    print("| Dosya: satır | Risk |")
    print("|---|---|")
    for path, no, note in risks:
        print(f"| `{path}:{no}` | {note} |")
    print("\n## Çeviri girdileri\n")
    print("| Dosya: satır | Kaynak | Biçim yer tutucusu |")
    print("|---|---|---|")
    for path, no, value, fmt in rows:
        print(f"| `{path}:{no}` | {value} | `{fmt}` |")


if __name__ == "__main__":
    main()
