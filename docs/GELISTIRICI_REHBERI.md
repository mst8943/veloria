# Veloria — Geliştirici Rehberi

Godot 4.7 ile yazılmış, veri odaklı bir siyaset simülasyonu. Bu belge projeyi açmak, içerik eklemek, test etmek ve build almak için gerekenleri anlatır.

## Klasör yapısı

```
game/
  core/
    sim.gd        Simülasyon çekirdeği (autoload: Sim) — gizli dünya durumu, kurallar, kayıt
    actor.gd      Karakter modeli: güç, hırs, korku, sadakat nedenleri, sırlar
    sfx.gd        Ses sentezi ve ayarlar (autoload: Sfx)
  data/
    actors.json   9 karakter
    events.json   Karar olayları (55)
  ui/
    main.gd       Arayüz: menü, masa, kartlar, sinematikler, oyun sonu
    ui_kit.gd     Tema, renkler, animasyon yardımcıları
    cinema.gd     Sinematik katman (bantlar, Ken Burns, altyazı)
    truth_chart.gd Oyun sonu grafiği
    *.gdshader    Atmosfer (vinyet, gren, mum) ve başlık parıltısı
  fonts/          EB Garamond (OFL)
art/
  portraits/      <karakter_id>.png
  events/         <olay_id>.png  (isteğe bağlı ikinci versiyon: <olay_id>_b.png)
  icons/          Arayüz ikonları
  *.png           Masa, menü ve dört final sahnesi
  _arsiv/         Kullanılmayan görseller (.gdignore ile Godot dışı)
tests/sim_test.gd Headless simülasyon, denge ve sistem testleri
ART_PROMPTS.md    Tüm görsellerin üretim prompt'ları
export_presets.cfg Windows, Linux, Web
```

## Mimari

- **Sim** gerçeği tutar (tahtın gücü, huzursuzluk, ekonomi, muhalefet, sırlar). Oyuncu bu sayıları asla görmez.
- Her hafta aktörler kendi hamlelerini yapar, sırlar yayılır, olaylar tetiklenir, **eşik kaskadı** hesaplanır: her aktörün "kaç kişi kıpırdarsa ben de kıpırdarım" eşiği vardır; kamuya açık zayıflıklar bu eşikleri düşürür.
- Raporlar, gerçeğin aktörün korkusu ve dürüstlüğüyle süslenmiş hâlidir. Süslenen her rapor **Hakikat Dosyası**'na yazılır.
- Arayüz Sim'in sinyallerini (`changed`, `week_advanced`, `game_ended`) dinler.

## Yeni olay eklemek

`game/data/events.json`'a bir nesne ekle. Kod değişikliği gerekmez.

```json
{
  "id": "ornek_olay", "min_week": 10, "title": "Başlık",
  "text": "Olayın anlatımı.",
  "choices": [
    {"label": "Seçenek", "text": "Sonuç metni", "fx": {"unrest": -5, "actors": {"arden": {"power": 4}}}}
  ],
  "ignore": {"text": "Ertelenirse", "fx": {"king": -2}}
}
```

**Koşullar** (hepsi isteğe bağlı):

| Anahtar | Anlamı |
|---|---|
| `min_week`, `max_week` | Hafta aralığı |
| `min_unrest`, `max_unrest`, `min_economy`, `max_economy`, `min_opposition` | Gizli durum eşikleri |
| `min_power` | `{"arden": 55}` |
| `actor_min`, `actor_max` | `{"kessler": {"fear": 50}}` — herhangi bir aktör özelliği |
| `needs_flag`, `blocks_flag`, `any_flag` | Bayrak koşulları |
| `flag_age` | `{"gida_protestosu_0": 8}` — o karar en az 8 hafta önce verilmiş olmalı (gecikmeli sonuç) |
| `alive`, `needs_fact`, `needs_ready` | Aktör hayatta / sır var / biri darbeye hazır |
| `once`, `cooldown`, `chance` | Tekrarlanabilirlik ve olasılık |
| `art` | Başka bir olayın görselini kullan |

Her seçim otomatik olarak `<olay_id>_<seçenek_no>` bayrağını, erteleme `<olay_id>_ertelendi` bayrağını koyar. Zincir olaylar bunlara `flag_age` ile bağlanır.

**Etkiler (`fx`)**: `unrest`, `economy`, `king`, `opp`, `wealth`, `actors` (özellik değişimi; `l_<neden>` sadakat nedenini değiştirir, örn. `l_career`), `fact` (yeni sır), `flag`, `leak` (sırrı kamuya aç), `remove` (aktörü oyundan çıkar).

Görseli için `art/events/<id>.png` ekle; yoksa kart görselsiz çıkar.

## Yeni karakter eklemek

`game/data/actors.json`'a ekle (`domain` rapor alanını belirler), `art/portraits/<id>.png` koy. Yeni bir `domain` kullanılırsa `sim.gd` içindeki `PHRASES` ve `_domain_truth`'a karşılığını ekle.

## Görsel ekleme

1. Görseli doğru adla `art/` altına koy.
2. Godot editörüne odaklan (otomatik içe aktarma) ya da `--import` çalıştır.
3. `.import` dosyasında boyut sınırı (portre 512, olay 960), `compress/mode=1` ve `mipmaps/generate=true` kullan. Mevcut dosyalar örnek.

## Testler

Godot console exe ile:

```bash
Godot_console.exe --headless --path . --script res://tests/sim_test.gd
```

Bu test 40'ar kampanyalık bot oyunlarıyla dengeyi ölçer (pasif, rastgele, dikkatli botlar), zorluk seviyelerini, kayıt/yükleme, şantaj, söz defteri, tarihçiler ve zincir olayların ulaşılabilirliğini kontrol eder. Testler oyuncunun kaydına ve arşivine dokunmaz.

Arayüzü baştan sona otomatik oynatmak için:

```bash
Godot_console.exe --headless --path . -- --autoplay
Godot_console.exe --headless --path . -- --autoplay --mobile
```

## Geliştirici ayarları

Proje ayarlarında `veloria/` altında; dağıtımdan önce hepsi kapalı olmalı:
`dev_autostart`, `dev_skip_weeks`, `dev_press_end`, `dev_choose`, `dev_end`, `dev_mobile`, `dev_tab`, `dev_select`, `dev_event`, `dev_modal`, `dev_intro`.

## Build

```bash
Godot_console.exe --headless --path . --export-release "Windows Desktop" dist/windows/Veloria.exe
Godot_console.exe --headless --path . --export-release Linux dist/linux/Veloria.x86_64
Godot_console.exe --headless --path . --export-release Web dist/web/index.html
```

Not: Beckett eklentisi headless export sırasında `.mcp.json` portunu değiştirebilir; export sonrası `8770` olduğunu kontrol et.

Web sürümünü yerelde denemek için: `python -m http.server 8060 --directory dist/web`

## Lisanslar

- Godot Engine: MIT (bildirim oyunun Hakkında ekranında)
- EB Garamond: SIL OFL 1.1 (`game/fonts/OFL.txt`, build'e dahil)
- Görseller: yapay zekâ ile üretilmiş özgün görseller
