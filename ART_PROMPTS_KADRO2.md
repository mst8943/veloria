# Karakter portre promptları — yeni kadro (14 kişi)

Hedef: her karakterin yüzü TÜM sayfalarda tam görünür ve aynı kişi olarak tanınır.
Not: `ART_PROMPTS.md` §2'deki eski kadro (Arden, Voss, Halden...) ayrı; bu liste yeni kadrodur. Eski ve yeni "Arden/Vale/Marcus" adları çakışıyorsa kod tarafında id'leri ayırın (ör. `arden2`).

## Kullanım (tutarlılığın sırrı)

1. **Önce kanonik portre.** Her karakter için aşağıdaki promptu BİR KEZ, tek başına üretin (1024x1024). En iyi sonucu seçin: bu, karakterin "kimlik kartıdır". `art/portraits/<id>.png` olarak kaydedin.
2. **Sonraki her görselde** (olay, sayfa, sahne) kanonik portreyi isteğe EKLEYİN (ChatGPT'de görseli yükleyin) ve şu cümleyi başa koyun:
   `Use the attached image as the exact face reference: same person, same face, same hair, same age. Only the scene, pose and clothing context change.`
3. Karakter açıklamasını (aşağıdaki "KİMLİK" metni) her promptta aynen yeniden yapıştırın; kelime değiştirmeyin.
4. Aynı sohbet/oturumda üretin; kolaj değil tek görsel isteyin.

## Ortak YÜZ KİLİDİ (her prompta KİMLİK'ten sonra ekleyin)

```
Single image, not a collage. Head-and-shoulders bust portrait, facing the camera in a slight three-quarter view, the whole face fully visible and evenly lit, both eyes clearly visible and sharp, no shadow across the face, no hat, no sunglasses, no hand or object covering the face, no heavy motion blur, neutral dark textured background, soft side lighting, highly detailed realistic face.
```

Sahne varyantlarında (gerekirse tam boy ya da orta plan): `the face stays large, sharp, unobstructed and facing the viewer; background and props are secondary`.

## Stil bloğu (en sona, `ART_PROMPTS.md` ile aynı)

```
Stylized editorial illustration, oil-painting texture mixed with art-deco poster design, fictional Central European kingdom with modern institutions, restrained palette of charcoal black, deep olive green, aged gold and bone white, dramatic chiaroscuro lighting, subtle film grain, painterly brush strokes, moody political-thriller atmosphere, no text, no letters, no logos, no watermark
```

Gerçek kişi ve gerçek bayrak benzerliği yok; tüm kişiler kurgusaldır.

---

## Devlet ve toplum

| Dosya | KİMLİK (prompt) |
|---|---|
| `portraits/selin_veyra.png` | `Fictional prime minister Selin Veyra, woman in her early 50s, shoulder-length chestnut hair with a distinct silver streak at the left temple, hazel eyes, high cheekbones, composed and intelligent expression, tailored navy suit, white blouse, a small plain gold lapel pin.` |
| `portraits/marcus_arden.png` | `Fictional chief of the general staff Marcus Arden, man in his late 50s, short grey crew cut, strong square jaw, deep-set brown eyes, a thin faint scar on the left cheek, quiet disciplined authority, dark green dress uniform with gold braid and no readable insignia.` |
| `portraits/nadir_vale.png` | `Fictional intelligence director Nadir Vale, thin pale man in his early 50s, dark hair slicked back with a receding hairline, rimless glasses, grey eyes that notice everything, calm unreadable expression, immaculate charcoal suit and dark tie.` |
| `portraits/leyla_sarn.png` | `Fictional independent journalist Leyla Sarn, woman in her early 30s, messy dark curly hair, olive skin, tired brown eyes, stubborn expression, a small silver hoop earring, worn beige trench coat with a press card clipped to the lapel.` |
| `portraits/victor_sarne.png` | `Fictional industrial magnate Victor Sarne, man in his 60s, thick silver hair swept back, tanned clean-shaven face, strong nose, heavy dark eyebrows, a confident smile that does not reach the eyes, navy double-breasted suit, white pocket square, a gold signet ring.` |
| `portraits/adrian_voss.png` | `Fictional opposition leader Adrian Voss, man in his mid-50s, dark wavy hair greying at the sides, short salt-and-pepper beard, blue-grey eyes, tired charismatic look, white shirt with rolled-up sleeves and a loosened tie.` |
| `portraits/sophia_renn.png` | `Fictional chief prosecutor Sophia Renn, woman in her 60s, silver hair in a low chignon, black-framed reading glasses on a thin chain, sharp grey eyes, stern calm expression, black judicial robe with a white collar.` |

## Hanedan

| Dosya | KİMLİK (prompt) |
|---|---|
| `portraits/julian_valerius.png` | `Fictional crown prince Julian Valerius, slim young man around 20, fair skin, light brown wavy hair, clear blue eyes, earnest and slightly uncertain expression, dark navy formal coat with small gold buttons, no crown.` |
| `portraits/kralice_helena.png` | `Fictional Queen Helena, elegant woman in her late 50s, ash-blonde hair in a low twist, green eyes, fine lines of dignity, restrained cool expression, a single strand of pearls, deep burgundy high-collared dress.` |
| `portraits/prens_marcus.png` | `Fictional prince Marcus, the king's younger brother, man in his late 30s, dark tousled hair, neatly trimmed stubble, dark eyes, handsome with a restless ambitious expression, elegant black suit with a subtle gold pin.` |

## Dış ilişkiler

| Dosya | KİMLİK (prompt) |
|---|---|
| `portraits/elena_varos.png` | `Fictional foreign minister Elena Varos, woman in her mid-40s, sleek black chin-length bob, olive complexion, dark attentive eyes, polite diplomatic half-smile, charcoal grey tailored jacket over a cream blouse.` |
| `portraits/claire_duvall.png` | `Fictional ambassador of the fictional country Asteria, Claire Duvall, woman in her late 40s, auburn hair pinned up, light freckles, blue-green eyes, warm confident smile, emerald green jacket with a small silver brooch (no flag, no text).` |
| `portraits/viktor_malenkov.png` | `Fictional ambassador of the fictional country Drakon, Viktor Malenkov, heavily built man in his 60s, broad face, bald head with grey hair at the sides, thick grey moustache, heavy-lidded watchful eyes, dark wool double-breasted overcoat over a dark suit.` |
| `portraits/lucien_vale.png` | `Fictional economic envoy of the fictional country Seravia, Lucien Vale, man in his mid-40s, light brown skin, short curly black hair, neat short beard, round tortoiseshell glasses, relaxed shrewd smile, light tan suit with an open collar and no tie.` |

---

## Tam prompt şablonu (kanonik portre)

```
[KİMLİK metni] + [ortak YÜZ KİLİDİ] + [Stil bloğu]
```

Örnek (Selin Veyra):

```
Fictional prime minister Selin Veyra, woman in her early 50s, shoulder-length chestnut hair with a distinct silver streak at the left temple, hazel eyes, high cheekbones, composed and intelligent expression, tailored navy suit, white blouse, a small plain gold lapel pin. Single image, not a collage. Head-and-shoulders bust portrait, facing the camera in a slight three-quarter view, the whole face fully visible and evenly lit, both eyes clearly visible and sharp, no shadow across the face, no hat, no sunglasses, no hand or object covering the face, no heavy motion blur, neutral dark textured background, soft side lighting, highly detailed realistic face. Stylized editorial illustration, oil-painting texture mixed with art-deco poster design, fictional Central European kingdom with modern institutions, restrained palette of charcoal black, deep olive green, aged gold and bone white, dramatic chiaroscuro lighting, subtle film grain, painterly brush strokes, moody political-thriller atmosphere, no text, no letters, no logos, no watermark
```

## Sahne (olay/sayfa) şablonu

```
Use the attached image as the exact face reference: same person, same face, same hair, same age. Only the scene, pose and clothing context change. [KİMLİK metni, aynen] Scene: [sahne]. The face stays large, sharp, unobstructed and facing the viewer; background and props are secondary. Single image, not a collage, 16:9. [Stil bloğu]
```

## Kabul ölçütü
- Yüz tam görünür, iki göz net; gölge/eşya/el yüzü kapatmıyor.
- Ayırt edici işaret her görselde var (Veyra: gümüş perçem; Arden: yanak izi; Vale: gözlük; Sarn: küpe/basın kartı; Renn: zincirli gözlük; Malenkov: bıyık; Lucien: yuvarlak gözlük + sakal).
- Yazı, logo, gerçek bayrak yok. İki karakter yan yana durduğunda silüet ve saç/renk farkıyla ayrılıyor.
