# Veloria — Geliştirici Rehberi

Godot 4.7 ile yazılmış, veri odaklı bir siyaset simülasyonu. Bu belge projeyi açmak, içerik eklemek, test etmek ve build almak için gerekenleri anlatır.

## Klasör yapısı

```
game/
  core/
    sim.gd        Simülasyon çekirdeği (autoload: Sim) — gizli dünya durumu, kurallar, kayıt
    actor.gd      Karakter modeli: güç, hırs, korku, sadakat nedenleri, sırlar
    sfx.gd        Ses sentezi ve ayarlar (autoload: Sfx)
    press.gd      Gazete ve TV içeriği: gizli durumdan, yayın sahibinin gözüyle üretilir
  data/
    actors.json   9 karakter
    events.json   Karar olayları (71)
    city_map.json (isteğe bağlı) harita bina konumları, yüzde olarak
  ui/
    main.gd       Arayüz: menü, oyun ekranı, kartlar, sinematikler, oyun sonu
    desk_view.gd  Çalışma Masası (art/desk/<id>.png varsa kullanır, yoksa kodla çizer)
    city_view.gd  Başkent Haritası (art/city_map.png varsa kullanır, yoksa kodla çizer)
    media_view.gd Medya Merkezi: iki gazete ve TV
    ui_kit.gd     Tema, renkler, animasyon yardımcıları, tr_upper (Türkçe büyük harf)
    cinema.gd     Sinematik katman (bantlar, Ken Burns, altyazı)
    truth_chart.gd Oyun sonu grafiği
    *.gdshader    Atmosfer, başlık parıltısı, gazete baskısı, TV tarama çizgileri
  fonts/          EB Garamond (başlık) + IBM Plex Sans (gövde), ikisi de OFL
art/
  portraits/      <karakter_id>.png
  events/         <olay_id>.png  (isteğe bağlı ikinci versiyon: <olay_id>_b.png)
  icons/          Arayüz ikonları
  *.png           Masa, menü ve dört final sahnesi
  _arsiv/         Kullanılmayan görseller (.gdignore ile Godot dışı)
tests/sim_test.gd Headless simülasyon, denge ve sistem testleri
tests/ui_shots.gd Arayüz ekran görüntüleri (oyun, menü sayfaları, oyun sonu sekmeleri)
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

Olay temposunu ölçmek için (haftalara göre olay yoğunluğu, en uzun olaysız seri):

```bash
Godot_console.exe --headless --path . --script res://tests/pacing_test.gd
```

Arayüzü baştan sona otomatik oynatmak için (masa, harita ve medya ekranlarını da açar):

```bash
Godot_console.exe --headless --path . -- --autoplay
Godot_console.exe --headless --path . -- --autoplay --mobile
Godot_console.exe --headless --path . -- --autoplay --full
```

Ekran görüntüleri (pencereli çalışır; headless çizim yapmaz; kayda ve arşive dokunmaz):

```bash
Godot_console.exe --path . --script res://tests/ui_shots.gd -- --out=C:/klasor
Godot_console.exe --path . --script res://tests/ui_shots.gd -- --out=C:/klasor --mobile
```

## Claude Code skill'leri

Projeye özel skill'ler `.claude/skills/` altında (Claude Code'da `/ad` ile çağrılır). Ortak proje bilgisi: `.claude/skills/game-design/VELORIA.md`. Klasörde `.gdignore` var; Godot bunları içe aktarmaz.

| Skill | Ne yapar |
|---|---|
| `/game-design` | Yeni özellik fikrini kodlamadan önce değerlendirir, kısa plan çıkarır |
| `/design-system` | Tek bir sistemi GDD seviyesinde tasarlar (`docs/design/`) |
| `/design-review` | Tasarım önerisini, GDD'yi ya da olay paketini eleştirel inceler |
| `/balance-check` | Bot simülasyonlarıyla denge, baskın strateji, tempo ölçer (`probe_template.gd`) |
| `/ux-design` | Ekran/HUD/akış spesifikasyonu (`docs/ux/`) |
| `/ux-review` | Ekran görüntüsü alıp arayüzü kalite kontrolünden geçirir |
| `/team-ui` | Arayüz işini uçtan uca yürütür: tasarım, uygulama, inceleme, test, belge |
| `/art-bible` | Görsel kimlik kitabı (`docs/ART_BIBLE.md`) |
| `/asset-spec` | Görsel spesifikasyonu + prompt; gelen görseli tanıyıp yerleştirir |
| `/tech-debt` | Teknik borcu ölçer, önceliklendirir (`docs/TECH_DEBT.md`) |
| `/project-stage-detect` | Projenin aşamasını ölçütlerle belirler |

Kod incelemesi için Claude Code'un yerleşik `/code-review` komutu kullanılır.

## Geliştirici ayarları

Proje ayarlarında `veloria/` altında; dağıtımdan önce hepsi kapalı olmalı:
`dev_autostart`, `dev_skip_weeks`, `dev_press_end`, `dev_choose`, `dev_end`, `dev_mobile`, `dev_tab`, `dev_select`, `dev_event`, `dev_modal`, `dev_intro`, `dev_desk`, `dev_city` (`map` ya da kurum id'si), `dev_media` (`state`, `free`, `tv`).

## Dikkat edilecekler

- **Tıklama yutan görünmez kontroller:** Görünmez ama `mouse_filter` açık bir kapsayıcı alttaki düğmeleri örtebilir. Arayüz değişikliğinden sonra Beckett `ui_snapshot` ile `occluded_by` alanını tara.
- **Web fontları:** Web sürümünde sistem yazı tipi yedeği yok. ◆ ⏳ → ● gibi semboller kutu olarak görünür; ya çiz ya da Latin karakter kullan.
- **Gizli kurulan Control'ler:** `hide()` ile kurulan ve CanvasLayer altında duran tam ekran Control'lerin boyutu açılırken açıkça ekrana eşitlenmeli (bkz. `cinema.gd`, `media_view.gd`).

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
- IBM Plex Sans: SIL OFL 1.1 (`game/fonts/OFL_IBMPlexSans.txt`, build'e dahil: export `include_filter` `game/fonts/*.txt`)
- Görseller: yapay zekâ ile üretilmiş özgün görseller
