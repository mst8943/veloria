"""EN arayüzünde kalan Türkçeyi sözlük farkıyla bulur (Türkçe harf / kelime listesine bağımlı değildir).

Yöntem: Türkçe kaynaklardaki (en.po msgid + game/data/*.json) kelimelerden, İngilizce kaynaklarda
(en.po msgstr + game/data/en/*.json) hiç geçmeyenler "yalnız-Türkçe" sayılır. Dökümdeki bir metin
bunlardan birini içeriyorsa, ya da kaynak (Türkçe) msgid'in aynısıysa şüphelidir.

Kullanım:
  godot ... --script res://tests/en_dump.gd  -- --out=a.tsv [--mobile]
  godot ... --script res://tests/en_dump2.gd -- --out=b.tsv
  python tools/i18n_leak_scan.py a.tsv b.tsv      # şüpheli varsa çıkış kodu 1
"""
import glob
import json
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")
WORD = re.compile(r"[A-Za-zÇĞİÖŞÜçğıöşü]{3,}")
NAMES = {"veloria", "sarne", "arden", "veyra", "vale", "voss", "sarn", "malenkov", "duvall", "lucien", "marcus", "helena",
         "varos", "renn", "adrian", "leyla", "nadir", "victor", "viktor", "sophia", "selin", "julian", "valerius", "claire",
         "elena", "seravia", "drakon", "asteria", "via"}
ALLOWED_EXACT = {"Türkçe", "English"}
SKIP_KEYS = {"id", "art", "flag", "actor", "subject", "fx"}


def words(s: str) -> set[str]:
    return {w.lower() for w in WORD.findall(s)}


def json_strings(o):
    if isinstance(o, dict):
        for k, v in o.items():
            if k not in SKIP_KEYS:
                yield from json_strings(v)
    elif isinstance(o, list):
        for v in o:
            yield from json_strings(v)
    elif isinstance(o, str):
        yield o


def main() -> int:
    po = open("game/i18n/en.po", encoding="utf-8").read()
    pairs = re.findall(r'^msgid "(.*)"\nmsgstr "(.*)"', po, re.M)
    tr_words, en_words, same = set(), set(), set()
    for a, b in pairs:
        tr_words |= words(a)
        en_words |= words(b)
        if a == b:
            same.add(a)
    for f in glob.glob("game/data/*.json"):
        if f.endswith(("city_map.json", "cutscenes.json")):
            continue
        for s in json_strings(json.load(open(f, encoding="utf-8"))):
            tr_words |= words(s)
    for f in glob.glob("game/data/en/*.json"):
        for s in json_strings(json.load(open(f, encoding="utf-8"))):
            en_words |= words(s)
    only_tr = tr_words - en_words - NAMES
    msgids = {a for a, b in pairs}
    total, bad = 0, 0
    seen = set()
    for path in sys.argv[1:]:
        for line in open(path, encoding="utf-8"):
            ctx, _, text = line.rstrip("\n").partition("\t")
            total += 1
            if text in seen or text in ALLOWED_EXACT:
                continue
            hit = sorted(words(text) & only_tr)
            exact = text in msgids and text not in same
            if hit or exact or re.search(r"[çğıöşüİÇĞÖŞÜ]", text):
                seen.add(text)
                bad += 1
                print("[%s] %s  <- %s%s" % (ctx[:40], text[:140], hit[:5], " TR-KAYNAK-AYNEN" if exact else ""))
    print("TARANAN %d metin, ŞÜPHELİ %d" % (total, bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
