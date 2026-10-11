# VELORIA reklam filmi — Google Flow prompt paketi

Hedef: ~60 sn, İngilizce konuşmalı, altyazısız. 8 Flow klibi (her biri 8 sn; Flow/Veo klip sınırı güvenli aralıkta) + oyun görüntüsü ve başlık kartı (kurguda eklenir).
Tüm kimlikler `art/portraits/` içindeki oyun portrelerinden alındı (king, arden, voss=Nadir Vale, lena=Leyla Sarn, kessler=Selin Veyra).

## Çalışma yöntemi (her klip için)
1. Flow'da önce **görsel** üret (Image): ilgili portre PNG'sini referans olarak yükle, "STILL" promptunu yapıştır. 4 seçenekten en iyisini seç.
2. Sonra **Frames to Video**: seçtiğin görseli ilk kare yap, "VIDEO" promptunu yapıştır, 8 sn.
3. "CHAIN" yazan klipler için bir önceki klibin SON karesini al (Flow'da klipte "Save frame / Use as first frame") ve onu ilk kare yap; STILL adımını atla.
4. Her prompt kendi kendine yeter; Flow önceki promptu hatırlamaz, kimlik metni bilerek tekrar ediliyor.
5. Ses tutarlılığı için her klipte aynı SES tarifi yazılı. Ses yine kayarsa: replikleri ElevenLabs'te üretip kurguda değiştir.
6. Altyazı çıkarsa aynı klibi yeniden üret ya da kurguda kırp. Yazı/başlık HER ZAMAN kurguda eklenir (Flow harfleri bozar).

## Ortak kilit (hepsinin sonunda zaten var; kısaca)
Painterly cinematic realism, art-deco gold and olive-green palette, charcoal black shadows, warm lamp key light with cool moonlit window fill, subtle film grain, restrained acting, natural lip sync, no subtitles, no captions, no on-screen text, no logos, no watermark, no face distortion, no extra fingers, no costume change.

## Sabit mekân (Kral sahnelerinde aynen)
Dark wood-paneled royal study at night, tall banners with a golden lion crest, an ornate gold-carved dark wooden armchair, a green velvet-covered table with a gold crown resting on it, tall window with a night skyline of a domed cathedral, river and stone arch bridge, a quiet ticking clock.

---

## KLİP 1 — Soru (8 sn) · YENİ GÖRSEL

**STILL** (referans: king.png)
```
Use the attached image as the exact face reference: same man, same face, same dark wavy hair, same short salt-and-pepper beard and moustache, same grey-blue eyes. King Adrian IV, a cold intelligent monarch in his late 40s, wearing a black high-collared ceremonial coat with gold embroidery, gold fringed epaulettes, a small star-shaped order on the chest and a white ermine-trimmed mantle over his shoulders. He sits upright in an ornate gold-carved dark wooden armchair in a dark wood-paneled royal study at night, hands resting on the armrests, calm severe expression, looking toward a woman journalist who is in the foreground, seen from behind over her shoulder, out of focus (dark curly hair, beige trench coat). A gold crown rests on a green velvet table beside him. Tall banners with a golden lion crest behind him, a window with a night skyline of a domed cathedral and river bridge. Symmetrical medium-wide shot, 16:9, single image, not a collage. Painterly cinematic realism, art-deco gold and olive-green palette, charcoal shadows, warm lamp key light with cool moonlight, subtle film grain, no text, no logos.
```
**VIDEO**
```
Premium cinematic interview. King Adrian IV sits perfectly still in the ornate armchair, in the same royal study at night. The camera slowly pushes in from a medium-wide shot to a medium shot. The woman journalist in the foreground (back of her shoulder only) speaks first, then the King answers after a short pause, with his eyes steady and almost no movement. A clock ticks quietly. Voices: journalist = clear composed alto; King = low, calm, measured baritone with a slight aristocratic accent.
Journalist says: "Your Majesty, does all power in Veloria rest in your hands?"
The King says, after a pause: "Officially... yes."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
Son kare: King'in orta plan, bakışı sabit → Klip 2'ye CHAIN.

## KLİP 2 — Güç bir yanılsama (8 sn) · CHAIN (Klip 1 son karesi)
**VIDEO** (ilk kare = Klip 1 son kare)
```
Continue directly from the first frame. Same King Adrian IV, same black ceremonial coat with gold epaulettes and ermine mantle, same armchair, same royal study, same lighting. The camera slowly moves closer to a tight close-up of his face. The journalist's voice is heard off-screen, then the King speaks slowly and quietly, with total self-control; his expression barely changes. After the line he lets a brief silence hang, eyes fixed forward. Voices: journalist = clear composed alto; King = low, calm, measured baritone with a slight aristocratic accent.
Journalist (off-screen) says: "And in reality?"
The King says: "In reality... power is the favorite illusion of those who think they possess it."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
Son kare: gözlere yakın plan, sessizlik → kurguda sert kesme.

## KLİP 3 — General Arden (8 sn) · YENİ GÖRSEL

**STILL** (referans: arden.png)
```
Use the attached image as the exact face reference: same man, same face, same short grey crew-cut hair, same thin faint scar on the left cheek, same brown eyes. General Marcus Arden, chief of the general staff, early 60s, stern and unreadable, wearing a dark green dress uniform with gold leaf embroidery on the collar, gold braided aiguillette, gold shoulder epaulettes and a black tie, no readable insignia. He sits rigidly upright in a stately government office with a dark polished background, a golden lion banner faintly visible behind him, in the foreground the blurred shoulder of a woman journalist with dark curly hair and a beige trench coat. Medium shot, low-key dramatic lighting, 16:9, single image, not a collage. Painterly cinematic realism, art-deco gold and olive-green palette, charcoal shadows, subtle film grain, no text, no logos.
```
**VIDEO**
```
Cinematic interview shot of General Marcus Arden, stable medium shot with a very slow push-in. He sits rigid and composed. The woman journalist (back of her shoulder in the foreground) asks; he answers with controlled formality. At the second question he says nothing and simply looks at her in silence for the last two seconds, expression unreadable. Voices: journalist = clear composed alto; Arden = gravelly, firm, disciplined baritone.
Journalist says: "General, who is the army loyal to?"
General Arden says: "To Veloria."
Journalist says: "Not the King?"
Arden does not answer; he only stares.
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```

## KLİP 4 — Nadir Vale (8 sn) · YENİ GÖRSEL

**STILL** (referans: voss.png — oyunda Nadir Vale)
```
Use the attached image as the exact face reference: same man, same face, same slicked-back dark hair with a receding hairline, same thin rimless gold-framed glasses, same grey-blue eyes. Nadir Vale, director of the intelligence agency, early 50s, thin and pale, calm unreadable expression, wearing a black three-piece suit, white shirt, dark patterned tie and a small pocket square. He sits in a secure dark office, half of his face in soft shadow but both eyes and the glasses clearly visible, a gold-and-black eagle emblem faintly behind him; in the foreground the blurred shoulder of a woman journalist with dark curly hair and a beige trench coat. Medium close-up, 16:9, single image, not a collage. Painterly cinematic realism, art-deco gold and olive-green palette, charcoal shadows, subtle film grain, no text, no logos.
```
**VIDEO**
```
Tense cinematic interview shot of Nadir Vale, medium close-up, he sits almost motionless in partial shadow, minimal movement, only subtle eye contact. The woman journalist (back of her shoulder in the foreground) asks; he answers evenly. After her second question a very slight, faint, unreadable smile appears on his face and he gives no spoken answer; hold the smile for the last two seconds. Voices: journalist = clear composed alto; Vale = soft, dry, quiet voice.
Journalist says: "Is there any threat to the King?"
Vale says: "All known threats are under control."
Journalist says: "And the unknown ones?"
Vale only smiles faintly.
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```

## KLİP 5 — Fısıltılar 1 (8 sn) · YENİ GÖRSEL (Kral'a dönüş)

**STILL** (referans: king.png)
```
Use the attached image as the exact face reference: same man, same face, same dark wavy hair, same short salt-and-pepper beard and moustache, same grey-blue eyes. King Adrian IV in a black high-collared ceremonial coat with gold embroidery, gold fringed epaulettes, star-shaped order and white ermine-trimmed mantle, seated in the ornate gold-carved dark wooden armchair in the dark wood-paneled royal study at night, one hand resting on the armrest, the gold crown on the green velvet table beside him, golden lion banners and a night skyline of a domed cathedral behind. Medium shot, he watches the woman journalist (seen from behind in the foreground, dark curly hair, beige trench coat) calmly and does not move. 16:9, single image, not a collage. Painterly cinematic realism, art-deco gold and olive-green palette, warm lamp light with cool moonlight, subtle film grain, no text, no logos.
```
**VIDEO**
```
Return to King Adrian IV, same chair, same coat, same royal study, same lighting. The journalist (back of her shoulder in the foreground) is now more probing and speaks carefully. The King does not interrupt; he simply listens, eyes fixed on her, perfectly still. Very slow push-in, a clock ticking softly. Last two seconds: only silence, his stare unchanged. Voices: journalist = clear composed alto; King = low, calm, measured baritone with a slight aristocratic accent.
Journalist says: "There are whispers in the palace, Majesty. Your commanders and ministers are building alliances behind closed doors. Some say your grip is slipping."
The King does not answer.
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
Son kare: Kral sessiz, bakışı sabit → Klip 6'ya CHAIN.

## KLİP 6 — Fısıltılar 2 (8 sn) · CHAIN (Klip 5 son karesi)
**VIDEO**
```
Continue directly from the first frame. Same King Adrian IV, same coat, same chair, same royal study, same lighting. Tighter medium close-up. He slowly turns his eyes fully toward the journalist. A faint, almost pitying smile appears. His voice is soft, precise and cutting, never raised. End on his calm, faintly smiling face. Voice: low, calm, measured baritone with a slight aristocratic accent.
The King says, softly: "They believe that?"
After a short pause, the King says: "They sit in the shadow of the throne... and mistake it for sunlight."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
Son kare: Kral hafif öne eğilmeye başlıyor → Klip 7'ye CHAIN.

## KLİP 7 — Fısıltılar 3 (8 sn) · CHAIN (Klip 6 son karesi)
**VIDEO**
```
Continue directly from the first frame. Same King Adrian IV, same coat, same chair, same royal study. He leans slightly forward, his face moving into the warm light, eyes locked on the journalist. Extremely controlled, never shouted, always calm. After the last line he slowly leans back into the chair and regains full stillness; the clock ticks once. Voice: low, calm, measured baritone with a slight aristocratic accent.
The King says: "Too deaf to hear them? Too weak to seal those doors?"
After a beat, the King says: "Let them plan."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
Son kare: Kral koltuğa yaslanmış, tamamen sakin → Klip 8'e CHAIN.

## KLİP 8 — Dosya / "Not yet." (8 sn) · CHAIN (Klip 7 son karesi)
**VIDEO**
```
Continue directly from the first frame. Same King Adrian IV, same coat, same chair, same royal study. A palace aide in a dark formal suit steps in from the side (face not shown, only a gloved hand and sleeve) and sets a thin black confidential folder with a gold seal on the green velvet table beside the crown, then withdraws. The King opens it and reads; his face barely changes, only a tiny pause in his eyes. The journalist (off-screen) speaks. He closes the folder, looks up and answers with calm menace. End on a chilling stillness, close-up of his eyes. Voices: journalist = clear composed alto; King = low, calm, measured baritone.
Journalist (off-screen) says: "Is something wrong, Your Majesty?"
The King says: "Not yet."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```

---

## OPSİYONEL KLİP 4B — Başbakan Veyra (6–8 sn) · YENİ GÖRSEL
**STILL** (referans: kessler.png — oyunda Selin Veyra)
```
Use the attached image as the exact face reference: same woman, same face, same shoulder-length chestnut hair with a distinct silver streak at the left temple, same hazel eyes. Prime Minister Selin Veyra, early 50s, composed and intelligent expression, wearing a dark navy blazer, cream silk blouse and a small plain gold lapel pin. She sits in a refined government office, muted bookshelves and an art-deco gold window arch behind her, in the foreground the blurred shoulder of a woman journalist with dark curly hair and a beige trench coat. Medium shot, 16:9, single image, not a collage. Painterly cinematic realism, art-deco gold and olive-green palette, soft dramatic lighting, subtle film grain, no text, no logos.
```
**VIDEO**
```
Premium cinematic interview shot of Prime Minister Selin Veyra, medium shot, subtle slow push-in. She answers with polished confidence, but there is a hint of evasion in her eyes. Voices: journalist = clear composed alto; Veyra = smooth, controlled mezzo voice.
Journalist says: "Is Veloria's economy truly secure?"
Prime Minister Veyra says: "There is nothing beyond our control."
Natural lip sync, restrained acting, no subtitles, no captions, no on-screen text, no face distortion, no costume change.
```
(Süre kısaltmak istersen bu klibi çıkar: Arden ve Vale yeterli.)

---

## Kurgu planı (CapCut / DaVinci)
| Sıra | İçerik | Süre | Geçiş |
|---|---|---|---|
| 1 | Klip 1 → Klip 2 | 16 sn | Aynı sahne, kesme yok |
| 2 | Klip 3 (Arden) | 8 sn | Sert kesme (1–2 kare siyah) |
| 3 | Klip 4 (Vale) | 8 sn | Sert kesme |
| 4 | (ops.) Klip 4B (Veyra) | 6–8 sn | Sert kesme |
| 5 | Klip 5 → 6 → 7 → 8 | 32 sn | Zincir; 7→8 arası sessizlikte kesme |
| 6 | Oyun görüntüsü: Gündem ekranı, bekleyen karar kartı, şüphe/darbe uyarısı | 5–6 sn | Klip 8 sonunda "Not yet." sonrası siyaha, sonra oyun |
| 7 | Başlık kartı: VELORIA (kurguda yaz) + "Everyone serves the king. Until they don't." | 3 sn | Fade |

Toplam ~75 sn (Veyra'sız ~68 sn). Kısa sürüm (30 sn): Klip 1 → Klip 3 (Arden'in sessizliği) → Klip 7 son yarısı → Klip 8 ("Not yet.") → oyun + başlık.

## Notlar
- Oyun kralı yaklaşık 45–50 yaş, sakallı ve koyu dalgalı saçlı; ChatGPT taslağındaki "clean-shaven, silver-streaked" tarifi oyunla çelişiyordu, kaldırıldı.
- Mekân oyundaki portre dilinde: altın aslan armalı sancaklar, taç, kubbeli katedral ve köprülü siluet.
- Leyla Sarn (röportajcı) çoğunlukla omuz üstü/arkadan gösteriliyor: yüz tutarlılığı sorunu ve dudak senkron riski azalır. İstersen bir kez ön planda göstermek için `lena.png` referansıyla ayrı bir plan üret.
- Aynı kişide yüz kayarsa: STILL adımında portre PNG'sini yeniden yükle, "same face" cümlesini koru.
