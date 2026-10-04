# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-04 (üçüncü oturumun sonu). Dal: `veloria`.

## Yeni oturumda ilk iş
1. Bu dosyayı oku.
2. `CLAUDE.md` (kullanıcının çalışma kuralları: önce incele, tasarla, sonra kodla; kalite > hız).
3. `.claude/skills/game-design/VELORIA.md`: mimari, olay şeması, komutlar, tuzaklar, ölçülmüş denge.
4. Skill'ler: `docs/SKILL_KULLANIMI.md` (hangi iş için hangi skill).

## Dokunulmayacaklar
- Çalışma ağacındaki `.mcp.json`, `BECKETT_SETUP.md`, `project.godot` değişiklikleri (Beckett token'ının kaldırılması), `CLAUDE.md` ve `.cursor/` kullanıcınındır. Commit'e katma.
- Godot `--import` ya da export `.mcp.json` portunu değiştirebiliyor (8772 gibi). İşlemden sonra `"url": "http://127.0.0.1:8770/mcp"` olarak geri al; token satırını geri ekleme.
- Push YOK: `origin` Beckett'in deposu. Kullanıcıya kendi deposunu açması önerildi, henüz cevap yok. Kodun uzak yedeği yok.

## Proje
Godot 4.7.2, Türkçe, yatay. Kral Adrian IV, 104 hafta tahtta kalma simülasyonu. Kullanıcı: Mesut Canturk. Görselleri kullanıcı ChatGPT/Imagen ile üretiyor, prompt'ları ben veriyorum (`ART_PROMPTS.md`). Görselleri rastgele adla `art/` içine atıyor; yerleştirme süreci `/asset-spec` skill'inde tanımlı.

## Çalıştırma ve test (ayrıntı: VELORIA.md > Komutlar)
- Godot console: `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- `sim_test.gd` (TEST: OK), `pacing_test.gd`, `-- --autoplay` (`--mobile`, `--full`), `ui_shots.gd` (pencereli ekran görüntüsü; `--only-desk`, `--only-world`, `--mobile`)
- Denge sondajı: `.claude/skills/balance-check/probe_template.gd` (`-- --n=40 --all-diffs`)
- İçe aktarma (editör kapalıyken): `--headless --path . --import`

## Yapılanlar (tamamı commit'li)
- **Simülasyon:** gizli durum + yalan söyleyen raporlar, ortak bilgi ve eşik kaskadı/darbe, emir kanalları, operasyonlar, şantaj/araştır/kırmızı çizgi, söz defteri, 3 zorluk, 71 olay, 15 başarım, tarihçiler, Hakikat Dosyası + grafik, arşiv, otomatik kayıt.
- **Arayüz turları 1–3:**
  - akış şeridi
  - sekmeli oyun sonu
  - sayfalı menü (4 düğme, Yeni Oyun'da zorluk, Ayarlar ayrı sayfada)
  - masada ışık ve gölge (`desk_lit` / `desk_shadow` gölgelendiricileri)
  - masa etiketlerinin altında tek satır özet
  - kişi paneli göstergeleri
  - ortak görsel imza (`UIKit.band_style`, `ornament`, `divider`, `caps`, `_section`)
  - tam dolu portre kartları
- **Bu oturum:**
  - Proje analizi raporu verildi (aşağıdaki "Yol haritası" ondan çıktı).
  - 11 projeye özel skill eklendi (`.claude/skills/`, `docs/SKILL_KULLANIMI.md`).
  - **Boş masa arka planı yerleşti:** yeni `art/bg_desk.png`, eskisi `art/_arsiv/bg_desk_esyali.png`; `desk_view.gd` `LAYOUT` yeni masaya göre ayarlandı.

## Ölçülmüş denge (Normal, 40 kampanya, probe_template)
| Bot | Kazanma | Ort. hafta | Not |
|---|---|---|---|
| idle | 0% | 25 | hep askerî darbe |
| visible (kararlar rastgele) | 17% | 53 | gerçek oyuncuya en yakın |
| visible_wise (kararlarda etkiyi tahmin eder) | 75% | 94 | |
| omniscient | 12% | 85 | hedef değil |

Kararların kalitesi sonucu belirliyor ama oyuncu seçeneklerin etkisini göremiyor. Kayıpların çoğu askerî darbe. Kazananlar çoğunlukla "… Kuklası" ünvanı alıyor. İkinci yılda olay yoğunluğu ~0,5/hafta.

## Yol haritası (analiz raporundan; kullanıcı henüz faz seçmedi)
**Faz 0 — Güvence**
- kendi deposunu açması (kullanıcı)
- kayıt dosyasına `version` alanı ve göç (`/tech-debt`)
- `events.json` doğrulayıcı
- ~~boş masa~~ (yapıldı)
- ~~görünür bilgi botu~~ (probe_template'te var; `sim_test`'e de eklenebilir)

**Faz 1 — Okunabilirlik (en yüksek etki)**
- seçeneklerde yanılabilir danışman görüşleri
- darbeyi aşamalı ve görünür yapmak (tohum → işaret → gerilim → kriz), kişi kartında "huzursuz/şüpheli" sinyali
- raporlarda geçen haftaya göre değişim
- hafta sonu "neler değişti" özeti
- eylem önizlemesi (maliyet / risk / iz)

**Faz 2 — Strateji derinliği ve denge**
- kayıp çeşitliliği
- rüşvete azalan getiri
- hedefli "birbirine düşür"
- aktörlerin kendi hamleleri
- denge hedefleri `/balance-check`'te

**Faz 3 — Kampanya ve içerik:** dönemler, ikinci yıl için 20–30 olay, karakter hikâye yayları, rejim tipi ve buna bağlı final tehdidi.

**Faz 4 — Belgedeki büyük sistemler:** devlet bütçesi/kapasitesi, patronaj/oligark.

**Faz 5 — Cila ve altyapı:** gerçek ses ve müzik, `main.gd`'yi bölmek, artırımlı arayüz güncellemesi, yerelleştirme.

Önerilen başlangıç: Faz 1, "seçeneklerde danışman görüşü". Önce `/design-system` ile tasarlanmalı.

## Bilinen küçük sorunlar
- Sağ üstteki bildirimler masa ve haritanın üstünde kalıyor (menü açılınca temizleniyor).
- Masada soldaki günlük lambadan uzak olduğu için karanlık kalıyor; okunurluk için `desk_lit` `ambient` ya da günlüğün yeri ayarlanabilir.
- Kullanıcı henüz tam bir saltanat oynamadı; denge, metin ve ses geri bildirimi bekleniyor. Linux build gerçek makinede denenmedi. Android/iOS kasıtlı yapılmadı.

## Kullanıcı tercihleri
Sormadan ilerle; büyük özellikte önce tasarla (`CLAUDE.md`). Sonuçta kısa Türkçe özet. Commit'e izin var, push yok.
