# VELORIA — Imagen Görsel Prompt Seti

Oyun, görselleri aşağıdaki **dosya adlarıyla** `res://art/` altında arar. Dosya yoksa renkli yer tutucu gösterir, yani görselleri istediğiniz sırayla ekleyebilirsiniz. Görselleri ekledikten sonra Godot editörüne bir kez odaklanın (otomatik import için).

## Kurallar (hepsi için geçerli)

- **Görsel içinde yazı olmasın.** Imagen yazıyı bozar; yazıları oyun kendisi ekler.
- Gerçek kişilere benzemesin. Tüm karakterler kurgusaldır.
- Her prompta aşağıdaki **STİL BLOĞU**'nu ekleyin. Tutarlılığı o sağlar.
- Aynı karakteri tekrar üretecekseniz karakterin açıklamasını her seferinde aynen kopyalayın.
- Kare (1:1) için 1024x1024 üretip 512x512'ye küçültebilirsiniz. 16:9 için 1280x720 yeterli.

### STİL BLOĞU (her prompta sonuna ekleyin)

```
Stylized editorial illustration, oil-painting texture mixed with art-deco poster design, fictional Central European kingdom with modern institutions, restrained palette of charcoal black, deep olive green, aged gold and bone white, dramatic chiaroscuro lighting, subtle film grain, painterly brush strokes, moody political-thriller atmosphere, no text, no letters, no logos, no watermark
```

---

## 1. Arka planlar

| Dosya | Boyut | Prompt |
|---|---|---|
| `art/bg_desk.png` | 1920x1080 | `Top-down view of a massive dark walnut royal desk in a palace study at night, leather blotter, brass lamp casting warm light, scattered folders, a rotary telephone, sealed envelopes, newspapers, a gold fountain pen, the center of the image left calm and low-detail for overlaid interface, heavy vignette on the edges.` + STİL BLOĞU |
| `art/menu_bg.png` | 1920x1080 | `Wide shot of an empty throne room of a modern kingdom at dusk, a lone golden throne at the far end, long marble floor, tall windows with rain, a single beam of light, a shadow of a crown on the floor, vast and lonely mood.` + STİL BLOĞU |
| `art/end_coup.png` | 1920x1080 | `Armored vehicles in a rain-soaked palace square at dawn, soldiers silhouetted at the gate, the royal flag lowered, smoke in the air, cold blue light.` + STİL BLOĞU |
| `art/end_uprising.png` | 1920x1080 | `A huge crowd surrounding a palace at night holding torches and improvised banners (no readable text), police line retreating, dramatic orange firelight against dark blue.` + STİL BLOĞU |
| `art/end_scandal.png` | 1920x1080 | `Hundreds of newspapers and documents falling like snow in an empty parliament chamber, a lone crown resting on a desk, harsh white light.` + STİL BLOĞU |
| `art/end_victory.png` | 1920x1080 | `An aged monarch seen from behind on a palace balcony at golden hour, city below, quiet and cold victory, long shadow cast behind him.` + STİL BLOĞU |

## 2. Karakter portreleri (512x512, `art/portraits/<id>.png`)

Hepsi için ortak ek: `bust portrait, three-quarter view, neutral dark textured background, soft side lighting, serious expression, looking slightly off camera, highly detailed face.`

| Dosya | Prompt |
|---|---|
| `portraits/arden.png` | `Fictional army general in his late 50s, short grey hair, strong jaw, dark green dress uniform with gold braid but no readable insignia, quiet disciplined authority, a faint scar on the left cheek.` |
| `portraits/voss.png` | `Fictional intelligence chief in his 50s, thin, pale, rimless glasses, immaculate charcoal suit and dark tie, calm unreadable expression, hands clasped, gray eyes that notice everything.` |
| `portraits/kessler.png` | `Fictional finance minister, woman in her late 40s, sensible dark blazer, hair in a tidy bun, tired but honest eyes, a stack of ledgers faintly visible, worried yet composed.` |
| `portraits/halden.png` | `Fictional oligarch and media tycoon in his 60s, silver slicked-back hair, expensive navy double-breasted suit, a gold ring, confident faint smile that does not reach the eyes, city lights reflected in a window behind him.` |
| `portraits/lena.png` | `Fictional investigative journalist, woman in her early 30s, messy dark hair, worn trench coat, press card clipped to the coat, tired eyes, stubborn expression, a notebook in hand.` |
| `portraits/dorn.png` | `Fictional palace chamberlain in his late 50s, round face, thin mustache, black formal tailcoat with a silver key chain, soft polite smile hiding calculation, standing beside a heavy oak door.` |
| `portraits/prens.png` | `Fictional prince, the king's younger brother, early 40s, elegant dark suit with a subtle gold pin, handsome with a restless ambitious expression, glass of wine in hand, candlelit background.` |
| `portraits/brandt.png` | `Fictional opposition leader in his 50s, rolled-up shirtsleeves, loosened tie, short beard with grey, tired charismatic look, outdoor rally lights blurred behind him.` |
| `portraits/falk.png` | `Fictional chief justice, woman in her 60s, black judicial robe with white collar, silver hair, stern calm expression, tall courtroom columns behind her.` |
| `portraits/king.png` | `Fictional modern king in his early 40s, dark formal military-style coat with gold epaulettes, a crown on a table beside him, weary yet watchful expression, rendered as the player's own silhouette-like portrait, face partially in shadow.` |

## 3. Olay illüstrasyonları (1280x720, `art/events/<event_id>.png`)

| Dosya | Prompt |
|---|---|
| `events/gida_protestosu.png` | `Long bread queues in front of a bakery in a grey city street, tense crowd, riot police in the distance, steam from the ovens, overcast light.` |
| `events/gazeteci_ihale.png` | `A journalist alone in a dark newsroom at night, desk covered with documents and red string connecting contract papers, a single desk lamp.` |
| `events/general_atamalari.png` | `Rows of young officers in dress uniforms saluting a general in a marble hall, orderly yet slightly ominous, long shadows.` |
| `events/kis_krizi.png` | `A snowbound city at dusk with dark apartment windows and a few lit ones, a gas pipeline in the foreground, frozen breath of people in line.` |
| `events/kral_hasta.png` | `Closed palace curtains, a silhouette behind a window, whispering courtiers in a corridor, a doctor's black bag on a table.` |
| `events/prens_hirs.png` | `An elegant dinner table with nobles whispering around a candlelit table, a prince at the head, the king's empty chair visible in the background.` |
| `events/muhalefet_birlesme.png` | `Two opposition rallies merging into one street march, banners without text, dusk light, a leader raising a hand at the front.` |
| `events/yargic_dosya.png` | `A judge holding a thick case file in a vast empty courtroom, stacks of folders, shaft of light through tall windows.` |
| `events/voss_dosyalar.png` | `A secret archive room with rows of grey filing cabinets, a thin man in glasses reading a file, a lamp, hundreds of folders labelled only with symbols.` |
| `events/sinir_krizi.png` | `Border post at dawn, soldiers and barbed wire, a distant village with smoke rising, tense cold mist.` |
| `events/butce_acigi.png` | `A finance ministry office, empty vault door ajar, a woman reading a long red-lined ledger, coins scattered on the table.` |
| `events/halden_ihale.png` | `A tycoon at a long glass boardroom table overlooking a harbor, cranes and ships, blueprints on the table, a royal seal-like stamp beside them.` |
| `events/deepfake.png` | `A king's face split in two halves on a tablet screen, one half realistic, one glitching into pixels, crowds watching phones in a dark street.` |
| `events/gizli_toplanti.png` | `A dimly lit villa at night, black cars outside, silhouettes of several powerful figures through a curtained window.` |
| `events/ogrenci_eylem.png` | `University steps full of students holding blank placards, riot shields at the bottom of the steps, autumn leaves, tense stillness.` |
| `events/milletvekili_satin.png` | `A parliament chamber at night, envelopes passed under desks, one shadowy figure watching from the gallery.` |
| `events/cenaze.png` | `A grand state funeral for an old general, flag-draped coffin on a gun carriage, dignitaries in black, a sea of faces watching one another.` |
| `events/dorn_filtre.png` | `A chamberlain at a heavy door controlling a line of petitioners holding folders, the king's study glimpsed through the door.` |
| `events/toren.png` | `A grand royal ceremony on a palace square, golden carriages, honor guard, fireworks over a modern capital skyline.` |
| `events/enflasyon.png` | `A market stall with prices crossed out and rewritten many times on small chalkboards (no readable numbers), worried shoppers counting coins.` |
| `events/skandal_bakan.png` | `Cameras and microphones thrust at a minister in a suit on the steps of a ministry, camera flashes, a suitcase half-open on a car trunk.` |

### 3b. Zincirleme olaylar (yeni, 1280x720, `art/events/<event_id>.png`)

Her birini **ayrı istekte** gönderin ve başına şunu ekleyin: *"Tek bir görsel üret, kolaj veya grid değil, 16:9 yatay."* Sonuna STİL BLOĞU.

| Dosya | Prompt |
|---|---|
| `events/arden_bakanlik.png` | `A general in dress uniform standing before the king's desk, placing a folder on it with a firm hand, the king seen from behind in shadow, tense negotiation.` |
| `events/lena_kitap.png` | `A bookshop window in a foreign city, stacks of the same dark book cover with a palace silhouette (no readable title), passersby stopping to look.` |
| `events/halden_intikam.png` | `A wall of television screens in a dark control room all showing the same palace image, a silver-haired tycoon watching with a faint smile.` |
| `events/halden_fatura.png` | `A tycoon sliding a thick envelope across a royal desk, his ring glinting, the king's hand hesitating above it.` |
| `events/voss_hakkinda.png` | `A thick grey file folder marked only with a crown symbol lying under a desk lamp in a secret archive, a thin hand resting on it.` |
| `events/prens_kacis.png` | `An elegant prince speaking at a microphone in front of camera flashes in a foreign capital, night, a different flag-less city skyline behind.` |
| `events/prens_veliaht.png` | `A prince kneeling before an empty throne in a candlelit hall, nobles watching from the shadows, a crown on a velvet cushion.` |
| `events/brandt_hapis.png` | `A prison cell with a small barred window, a bearded man writing a letter by dim light, the same letters plastered on a city wall outside.` |
| `events/muhalefet_para.png` | `Bank statements and photographs spread on a table under a harsh lamp, a red pen circling transfers (no readable numbers).` |
| `events/falk_istifa.png` | `A silver-haired judge's robe hung on an empty chair in a vast courtroom, a sealed letter on the bench, cold morning light.` |
| `events/kessler_istifa.png` | `A tired finance minister leaving an office at night with a cardboard box, a resignation letter left on the desk under a lamp.` |
| `events/gercek_kayit.png` | `A smartphone in a hand showing an audio waveform, many people in a dark street listening to their phones, a palace in the distance.` |
| `events/terhis.png` | `Armored columns parked in a ring around a capital city at dusk, soldiers idling by their vehicles, city lights beyond.` |
| `events/liman_skandali.png` | `A harbor at night with cranes and container ships, a dock worker handing a folder to a journalist in the shadows.` |
| `events/dorn_rusvet.png` | `A chamberlain discreetly accepting an envelope from a well-dressed petitioner beside a heavy oak door, candlelit palace corridor.` |
| `events/butce_ifsa.png` | `A press conference room with two large charts side by side on screens, contradicting curves (no numbers), journalists raising hands.` |
| `events/arden_posterleri.png` | `City walls covered with propaganda-style posters of a stern general's face (no text), a rainy street, a lone passerby looking up.` |
| `events/yabanci_elci.png` | `Two men in suits shaking hands in a dim private library, a foreign ambassador's pin catching the light, a briefcase on the table.` |
| `events/erken_secim.png` | `A packed parliament chamber in uproar, members standing and shouting, papers in the air, the speaker's gavel raised.` |
| `events/yildonumu.png` | `Fireworks over a palace on its anniversary night, crowds on the square, golden light reflecting on wet cobblestones.` |

## 4. Küçük ikonlar (isteğe bağlı, 256x256, saydam arka plan)

Ortak prompt: `flat minimal icon, gold line-art on transparent background, single object centered, thick clean strokes, art-deco style, no text`

- `icons/mesai.png` — an ornate hourglass
- `icons/servet.png` — a closed golden chest with a key
- `icons/rapor.png` — a sealed envelope with a wax seal
- `icons/dosya.png` — an open folder with a thin red thread
- `icons/gunluk.png` — a leather diary with a gold clasp

## 5. Animasyon (isteğe bağlı)

Oyun hareketi kod içinde yapıyor (kart geçişleri, kayan metin). Video modeliniz varsa şu iki döngü yeterli:

- `art/menu_loop.webm` (1920x1080, 8 sn, döngü): `Slow cinematic push-in on an empty throne room at dusk, rain on tall windows, dust motes in a single beam of light, subtle flicker of candles, seamless loop.`
- `art/end_loop.webm` (1920x1080, 6 sn): `Slow zoom on a crown resting on a desk as newspapers drift past and light fades, seamless loop.`

## 6. Ses (isteğe bağlı, `audio/<ad>.ogg` veya `.wav`)

Oyun şu an bu sesleri kodla sentezliyor; aynı adla gerçek bir dosya koyarsanız otomatik onu kullanır. Müzik/SFX üreten bir araç (ör. ElevenLabs Sound Effects, Suno, Stable Audio) için:

| Dosya | Süre | Prompt |
|---|---|---|
| `audio/ambient.ogg` | 60–120 sn, döngü | `Dark minimalist political thriller underscore, low cello drones, distant timpani, sparse piano notes, slow and tense, no melody hook, seamless loop` |
| `audio/click.wav` | 0.1 sn | `Soft wooden desk tap, muted, short UI click` |
| `audio/hover.wav` | 0.05 sn | `Very subtle paper brush, tiny UI hover tick` |
| `audio/paper.wav` | 0.4 sn | `Single sheet of heavy paper slid across a wooden desk` |
| `audio/seal.wav` | 0.6 sn | `Wax seal stamp pressed firmly onto paper, deep thud` |
| `audio/bell.wav` | 2.5 sn | `Distant palace clock bell, single strike, long reverb tail` |
| `audio/stinger_loss.wav` | 4 sn | `Ominous low brass and string swell, tragic ending stinger` |
| `audio/stinger_win.wav` | 3.5 sn | `Restrained regal brass chord, bittersweet victory stinger` |

## Üretim sırası önerisi

1. `bg_desk.png`
2. 9 portre (+ king)
3. 4 son ekran görseli
4. En çok görülen olaylar: `gida_protestosu`, `gazeteci_ihale`, `general_atamalari`, `kral_hasta`, `prens_hirs`
5. Kalan olaylar, ikonlar, menü animasyonu
