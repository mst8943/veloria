"""art/ui/*_src.png (siyah zeminli üretim) -> şeffaf, kırpılmış, ölçeklenmiş oyun dokuları (art/ui/*.png)."""
import os, sys
import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "ui")

# Düğme/sekme dokularının iç dolgusu: (sol/sağ girinti, üst/alt girinti, RGBA)
FILL = {
    "btn_normal": (9, 4, (23, 21, 17, 235)), "btn_hover": (9, 4, (44, 39, 30, 240)), "btn_pressed": (9, 4, (16, 14, 11, 245)),
    "btn_primary": (22, 6, (58, 48, 26, 245)),
    "tab_active": (5, 12, (34, 30, 24, 245)), "tab_idle": (5, 12, (0, 0, 0, 70)),
}

# ad: hedef yükseklik/genişlik (piksel); None = otomatik
TARGET = {
    "frame_panel": ("w", 560), "frame_card": ("w", 240),
    "btn_normal": ("h", 52), "btn_hover": ("h", 52), "btn_pressed": ("h", 52), "btn_primary": ("h", 64),
    "tab_active": ("h", 60), "tab_idle": ("h", 60), "divider": ("w", 720),
}


def key_black(im: Image.Image) -> Image.Image:
    a = np.asarray(im.convert("RGB")).astype(np.float32)
    m = a.max(axis=2)
    alpha = np.clip((m - 6.0) / 34.0, 0.0, 1.0)
    rgb = np.where(alpha[..., None] > 0.004, np.clip(a / np.maximum(alpha[..., None], 0.004), 0, 255), 0)
    out = np.dstack([rgb, alpha * 255.0]).astype(np.uint8)
    return Image.fromarray(out)


def trim(im: Image.Image, thr=40) -> Image.Image:
    a = np.asarray(im)[..., 3]
    ys, xs = np.where(a > thr)
    return im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def remove_center_diamonds(im: Image.Image, band=0.07, strip=0.06) -> Image.Image:
    """Üst/alt kenar ortasındaki elmasları, yanındaki düz çizgi dilimiyle değiştirir (9 dilimde bozulmasın)."""
    a = np.array(im)
    w, h = im.size
    cx = w // 2
    half = int(w * band)
    sh = int(h * strip) + 40
    for rows in (slice(0, sh), slice(h - sh, h)):
        src = a[rows, cx - half * 3: cx - half * 2 + 1]
        for x in range(cx - half, cx + half):
            a[rows, x] = src[:, (x - (cx - half)) % src.shape[1]]
    return Image.fromarray(a)


def main() -> None:
    for name, (axis, size) in TARGET.items():
        p = os.path.join(ROOT, "src", name + "_src.png")
        if not os.path.exists(p):
            continue
        im = trim(key_black(Image.open(p)))
        if name == "frame_panel":
            im = remove_center_diamonds(im)
        w, h = im.size
        s = size / (w if axis == "w" else h)
        im = im.convert("RGBa").resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS).convert("RGBA")
        if name in FILL:
        	fx, fy, col = FILL[name]
        	base = Image.new("RGBA", im.size, (0, 0, 0, 0))
        	base.paste(Image.new("RGBA", (im.width - 2 * fx, im.height - 2 * fy), col), (fx, fy))
        	im = Image.alpha_composite(base, im)
        im.save(os.path.join(ROOT, name + ".png"))
        print(name, (w, h), "->", im.size)


if __name__ == "__main__":
    main()
