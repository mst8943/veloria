"""Oyun ses efektlerini sentezler (numpy/scipy) -> audio/*.wav. Aynı adlı .ogg varsa oyun onu tercih eder."""
import os
import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio")
rng = np.random.default_rng(7)


def t(sec): return np.arange(int(SR * sec)) / SR
def env_exp(x, k): return np.exp(-x * k)
def noise(n): return rng.uniform(-1, 1, n)


def lp(x, fc, order=2): return signal.sosfilt(signal.butter(order, fc, "low", fs=SR, output="sos"), x)
def hp(x, fc, order=2): return signal.sosfilt(signal.butter(order, fc, "high", fs=SR, output="sos"), x)
def bp(x, lo, hi, order=2): return signal.sosfilt(signal.butter(order, [lo, hi], "band", fs=SR, output="sos"), x)


def reverb(x, sec=1.2, wet=0.3, damp=3500):
    n = int(SR * sec)
    ir = noise(n) * np.exp(-np.arange(n) / SR * (5.5 / sec))
    ir = lp(ir, damp)
    ir[: int(SR * 0.012)] *= np.linspace(0, 1, int(SR * 0.012))
    y = signal.fftconvolve(x, ir)[: len(x) + n // 2]
    y /= max(1e-9, np.abs(y).max())
    x = np.pad(x, (0, len(y) - len(x)))
    return x * (1 - wet) + y * wet * np.abs(x).max()


def fade(x, a=0.005, b=0.02):
    x = x.copy()
    na, nb = int(SR * a), int(SR * b)
    x[:na] *= np.linspace(0, 1, na)
    x[-nb:] *= np.linspace(1, 0, nb)
    return x


def save(name, x, peak=0.7):
    x = x / max(1e-9, np.abs(x).max()) * peak
    wavfile.write(os.path.join(OUT, name + ".wav"), SR, (x * 32767).astype(np.int16))
    print(name, round(len(x) / SR, 2), "s")


def saw(f, tt, harm=14):
    y = np.zeros_like(tt)
    for k in range(1, harm + 1):
        y += np.sin(2 * np.pi * f * k * tt) / k
    return y


def click():
    x = t(0.14)
    body = np.sin(2 * np.pi * 190 * x) * env_exp(x, 60)
    tick = bp(noise(len(x)), 1800, 5200) * env_exp(x, 220)
    save("click", fade(reverb(body * 0.6 + tick * 0.9, 0.15, 0.08)), 0.55)


def hover():
    x = t(0.09)
    y = bp(noise(len(x)), 2500, 7000) * np.sin(np.pi * np.clip(x / 0.09, 0, 1)) ** 2
    save("hover", fade(y), 0.25)


def paper():
    x = t(0.7)
    n = noise(len(x))
    mod = np.abs(lp(noise(len(x)), 30)) * 6 + 0.2
    rustle = bp(n, 900, 6500) * np.minimum(mod, 1.5)
    env = np.sin(np.pi * np.clip(x / 0.45, 0, 1)) ** 1.5 * (x < 0.45)
    laydown = (lp(noise(len(x)), 500) * env_exp(np.clip(x - 0.46, 0, None), 25) * (x >= 0.46)) * 1.4
    save("paper", fade(reverb(rustle * env * 0.8 + laydown, 0.35, 0.15)), 0.6)


def seal():
    x = t(0.9)
    f = 55 + 95 * np.exp(-x * 22)
    ph = 2 * np.pi * np.cumsum(f) / SR
    thump = np.sin(ph) * env_exp(x, 11)
    squish = lp(noise(len(x)), 900) * env_exp(x, 45) * 0.5
    ring = (np.sin(2 * np.pi * 1180 * x) + 0.6 * np.sin(2 * np.pi * 2210 * x)) * env_exp(x, 9) * 0.07
    y = thump * 1.0 + squish + ring
    save("seal", fade(reverb(y, 0.6, 0.12)), 0.75)


def bell():
    x = t(4.5)
    partials = [(1.0, 1.0, 0.9), (2.0, 0.6, 1.3), (2.4, 0.5, 1.5), (3.0, 0.35, 2.0), (4.2, 0.25, 2.6), (5.4, 0.18, 3.4), (6.8, 0.1, 4.4)]
    y = np.zeros_like(x)
    f0 = 233.0
    for r, a, d in partials:
        y += np.sin(2 * np.pi * f0 * r * x + rng.uniform(0, 6)) * a * env_exp(x, d)
    strike = bp(noise(len(x)), 600, 3500) * env_exp(x, 90) * 0.7
    y = lp(y * 0.8 + strike, 5200)
    save("bell", fade(reverb(y, 2.2, 0.4, 3000), 0.003, 0.4), 0.7)


def timpani(dur, f=70):
    x = t(dur)
    ff = f * (1 + 0.5 * np.exp(-x * 18))
    ph = 2 * np.pi * np.cumsum(ff) / SR
    return (np.sin(ph) * env_exp(x, 3.2) + lp(noise(len(x)), 300) * env_exp(x, 30) * 0.5)


def chord(freqs, dur, attack, rel, harm=10, cutoff=2200, detune=0.003):
    x = t(dur)
    y = np.zeros_like(x)
    for f in freqs:
        for d in (-detune, 0, detune):
            y += saw(f * (1 + d), x, harm)
    y = lp(y, cutoff)
    env = np.minimum(x / attack, 1) * np.where(x > dur - rel, np.clip((dur - x) / rel, 0, 1), 1)
    return y * env


def stinger_win():
    dur = 8.0
    x = t(dur)
    y = np.zeros_like(x)
    c = chord([130.8, 196.0, 261.6, 329.6, 392.0], 7.0, 1.2, 3.0, 12, 2600)
    y[: len(c)] += c * 0.5
    br = chord([65.4, 98.0, 130.8], 6.0, 0.6, 2.5, 14, 1800)
    y[: len(br)] += br * 0.55
    tp = timpani(2.5, 65)
    y[: len(tp)] += tp * 0.9
    y = np.pad(y, (0, 0))
    save("stinger_win", fade(reverb(y, 3.0, 0.38, 3200), 0.01, 1.2), 0.72)


def stinger_loss():
    dur = 9.0
    x = t(dur)
    y = np.zeros_like(x)
    ff = 110 * (1 - 0.18 * np.clip(x / 5.0, 0, 1))
    ph = 2 * np.pi * np.cumsum(ff) / SR
    low = np.zeros_like(x)
    for r in (1.0, 1.0595, 1.4983, 1.5874):
        low += saw(1, x, 1) * 0 + np.sin(ph * r) + 0.5 * np.sin(2 * ph * r) + 0.25 * np.sin(3 * ph * r)
    low = lp(low, 900) * np.minimum(x / 0.4, 1) * env_exp(np.clip(x - 3.0, 0, None), 0.6)
    y += low * 0.5
    tp = timpani(3.5, 48)
    y[: len(tp)] += tp * 1.1
    cx = t(5.0)
    cello = (saw(98.0, cx, 12) * 0.5) * (np.minimum(cx / 0.9, 1)) * env_exp(np.clip(cx - 1.0, 0, None), 0.7)
    cello = lp(cello * (1 + 0.04 * np.sin(2 * np.pi * 5.2 * cx)), 1400)
    y[int(SR * 4.2): int(SR * 4.2) + len(cx)] += cello[: len(y) - int(SR * 4.2)] * 0.8 if int(SR * 4.2) + len(cx) <= len(y) else cello[: len(y) - int(SR * 4.2)] * 0.8
    save("stinger_loss", fade(reverb(y, 3.4, 0.4, 2400), 0.01, 1.5), 0.72)


def cutscene():
    dur = 3.2
    x = t(dur)
    sw = chord([55.0, 82.4, 110.0], dur, 1.6, 1.0, 10, 1500)
    bellp = np.sin(2 * np.pi * 330 * x) * env_exp(np.clip(x - 1.4, 0, None), 2.0) * (x > 1.4) * 0.35
    n = bp(noise(len(x)), 200, 1800) * np.minimum(x / 1.6, 1) * 0.12
    save("cutscene", fade(reverb(sw * 0.7 + bellp + n, 2.0, 0.35, 2800), 0.01, 0.9), 0.65)


def alert():
    x = t(1.1)
    y = (np.sin(2 * np.pi * 196 * x) + 0.6 * np.sin(2 * np.pi * 294 * x)) * env_exp(x, 5)
    y2 = np.zeros_like(x)
    k = int(SR * 0.28)
    y2[k:] = y[:-k] * 0.7
    save("alert", fade(reverb(lp(y + y2, 2400), 0.9, 0.3)), 0.55)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for fn in (click, hover, paper, seal, bell, stinger_win, stinger_loss, cutscene, alert):
        fn()
