from pathlib import Path
from PIL import Image, ImageStat
import sys
names = ['2_menu', '1_karar', '1_masa', '1_medya', '1_harita', '5_son_0']
if len(sys.argv) != 5:
    raise SystemExit('usage: python tools/gece_hsv.py BEFORE_DESKTOP AFTER_DESKTOP BEFORE_MOBILE AFTER_MOBILE')
def measure(directory):
    result = {}
    for name in names:
        stats = ImageStat.Stat(Image.open(Path(directory) / f'{name}.png').convert('HSV'))
        result[name] = (stats.mean[1] / 255 * 100, stats.mean[2] / 255 * 100)
    return result
pairs = [(sys.argv[1], sys.argv[2]), (sys.argv[3], sys.argv[4])]
for before_path, after_path in pairs:
    before, after = measure(before_path), measure(after_path)
    print(f'[{before_path} => {after_path}]')
    sat_deltas, value_deltas = [], []
    for name in names:
        bs, bv = before[name]; ass, av = after[name]
        ds, dv = (ass / bs - 1) * 100, (av / bv - 1) * 100
        sat_deltas.append(ds); value_deltas.append(dv)
        print(f'{name}: S {bs:.2f} -> {ass:.2f} ({ds:+.1f}%), V {bv:.2f} -> {av:.2f} ({dv:+.1f}%)')
    print(f'Average per screen: S {sum(x[0] for x in before.values())/len(names):.2f} -> {sum(x[0] for x in after.values())/len(names):.2f} ({sum(sat_deltas)/len(names):+.1f}%), V {sum(x[1] for x in before.values())/len(names):.2f} -> {sum(x[1] for x in after.values())/len(names):.2f} ({sum(value_deltas)/len(names):+.1f}%)')
