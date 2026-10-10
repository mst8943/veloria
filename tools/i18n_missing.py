"""tr("...") kaynak dizgilerinden en.po'da bulunmayanları listeler (çevrilmemiş arayüz metni).
Kullanım: python tools/i18n_missing.py"""
import glob
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")
po = open("game/i18n/en.po", encoding="utf-8").read()
ids = set()
for m in re.finditer(r'^msgid ((?:"(?:[^"\\]|\\.)*"\n?)+)', po, re.M):
    ids.add("".join(re.findall(r'"((?:[^"\\]|\\.)*)"', m.group(1))))

pat = re.compile(r'\b(?:tr|ntr|Loc\.tr|Loc\.ntr)\(\s*"((?:[^"\\]|\\.)*)"')
miss = {}
for f in sorted(glob.glob("game/**/*.gd", recursive=True)):
    for i, line in enumerate(open(f, encoding="utf-8").read().split("\n"), 1):
        for m in pat.finditer(line):
            raw = m.group(1)
            if raw not in ids:
                miss.setdefault(raw, []).append("%s:%d" % (f, i))
print(len(miss), "tr() kaynağı en.po'da yok")
for k, v in miss.items():
    print(v[0], "|", k[:110])
