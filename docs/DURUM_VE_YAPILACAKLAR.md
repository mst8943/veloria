# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-04 (dördüncü oturum: meclis görüşleri + darbe aşamaları). Dal: `veloria`.

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
- `sim_test.gd` (TEST: OK), `pacing_test.gd`, `-- --autoplay` (`--mobile`, `--full`), `ui_shots.gd` (pencereli ekran görüntüsü; `--only-desk`, `--only-decision`, `--only-world`, `--mobile`, `--guide` = 1. hafta)
- Denge sondajı: `.claude/skills/balance-check/probe_template.gd` (`-- --n=40 --all-diffs`, `--bots=advice_weighted,visible`)
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
- **Üçüncü oturum:**
  - Proje analizi raporu verildi (aşağıdaki "Yol haritası" ondan çıktı).
  - 11 projeye özel skill eklendi (`.claude/skills/`, `docs/SKILL_KULLANIMI.md`).
  - **Boş masa arka planı yerleşti:** yeni `art/bg_desk.png`, eskisi `art/_arsiv/bg_desk_esyali.png`; `desk_view.gd` `LAYOUT` yeni masaya göre ayarlandı.
- **Dördüncü oturum: Meclis görüşleri (Faz 1'in ilk maddesi) — tamamlandı**
  - Tasarım: `docs/design/danisman_gorusleri.md` (GDD, ölçümler, uygulamada değişenler §14).
  - Her karar kartında iki danışman (taraf olan + uzman) bir seçenek önerir, gerekçesi doğru ama seçicidir; ÇIKARI VAR etiketi; darbeye hazır olan kötü önerir; korkan meclis kaçamak konuşur.
  - Oyun sonu Hakikat Dosyası'nda Meclis Sicili, Özet'te "seni en çok X yanılttı".
  - `Sim.choice_value(fx)` tek doğruluk kaynağı; **sadakat terimi eklendi** (eski formül sadakati saymıyordu; tavan bot %80 → %95).
  - `probe_template`: `advice_naive`, `advice_weighted`, `advice_kessler` botları, `--bots=` süzgeci. `sim_test`: meclis testleri. `ui_shots`: `1_karar`, `5_son_3_meclis`, `--only-decision`.
- **Dördüncü oturum (devam): Darbe aşamaları ve alametler (Faz 1) — tamamlandı**
  - Tasarım: `docs/design/darbe_asamalari.md` (§11 ölçümler, §14 uygulamada değişenler).
  - Komplo aşamalı (sakin → huzursuz → komplocu → hazırlıkta) ve **geri çekilebilir**. Haber şeridinde "ALAMET: …" (bir kısmı dedikodu), kişi kartında ŞÜPHELİ/TEHLİKELİ, panelde "Tavır" göstergesi.
  - Darbe koşulu oluşunca **kriz kartı**: sadık birlikleri topla / taviz ver (giderek zorlaşır) / halka seslen. Çözülmezse ertesi hafta darbe. Krizde meclis susar.
  - Yeni eylem **Huzura Çağır** (izsiz; komplocu çoğu zaman ele verir, temiz çıkanın dedikoduları silinir).
  - Oyun sonu: Komplo Defteri, Özet'te "ilk kıvılcım", kayıp metninde darbe gecesi.
  - Hatalar: İstihbarat raporu komployu ölçmüyordu; hafta ortası oyun sonunda mesai döngüleri sonsuza dönüyordu (`_end` mesaiyi sıfırlar).
  - Zorluk yeniden ayarlandı (tablo tasarım belgesi §14).
- **Dördüncü oturum (devam): Ana ekran sadeleştirme (UX turu 4)**
  - Kullanıcı: "ilk sayfa kalabalık; özellik silme, gerekirse taşı; ilk girince ne yapacağını anlasın". Ayrıntı: `docs/ux/ana_ekran_sadelestirme.md`.
  - Eylemler kategori sekmelerinde; raporlar sağ sütunda kaynaklarının altında; ilk 3 haftada "Bu hafta ne yapmalı?" yol göstericisi; kompakt bildirim ve kâtip notu; mobil kartlar kısaldı.
  - Analiz raporunun durumlu sürümü: `docs/YOL_HARITASI.md` (yapılan / kalan).

## Ölçülmüş denge (probe_template, 80 kampanya, darbe aşamalarından sonra)
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible (görüşsüz, alametsiz) | 56% | 23% | 15% |
| advice_weighted (**ölçüt**) | 80% | 48% | 27% |
| advice_naive | 90% | 61% | 32% |
| visible_wise (tavan) | 100% | 98% | 88% |

Üç seviye de hedef aralığında. Aynı hafta patlayan darbe %25 → ~%5–10. Kayıpların çoğu hâlâ askerî darbe (artık kriz kartından geçerek); ünvanlar çeşitlendi ama "… Kuklası" ağırlıklı. İkinci yılda olay yoğunluğu ~0,5/hafta.

## Yol haritası (analiz raporundan; durumlu tam sürüm: `docs/YOL_HARITASI.md`)
**Faz 0 — Güvence**
- kendi deposunu açması (kullanıcı)
- kayıt dosyasına `version` alanı ve göç (`/tech-debt`)
- `events.json` doğrulayıcı
- ~~boş masa~~ (yapıldı)
- ~~görünür bilgi botu~~ (probe_template'te var; `sim_test`'e de eklenebilir)

**Faz 1 — Okunabilirlik (en yüksek etki)**
- ~~seçeneklerde yanılabilir danışman görüşleri~~ (yapıldı)
- ~~darbeyi aşamalı ve görünür yapmak, kişi kartında "huzursuz/şüpheli" sinyali~~ (yapıldı)
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

Önerilen sıradaki iş: Faz 1'in kalanları. **Raporlarda geçen haftaya göre değişim** ve **hafta sonu "neler değişti" özeti** küçük ve yüksek etkili. Ardından **eylem önizlemesi** (maliyet / risk / iz). Arayüz işleri için `/team-ui`.
Oyuncu testinden sonra karar verilecekler: meclis görüşlerinin açık soruları (danisman_gorusleri.md §13) ve darbe aşamalarınınkiler (darbe_asamalari.md §13). Bir de alamete tepki vermenin botta nötr çıkması: oyuncu "gördüm ama işe yaramadı" derse Huzura Çağır güçlendirilmeli.
Faz 2 adayı: kayıp çeşitliliği (darbe dışı kayıplar hâlâ nadir).

## Bilinen küçük sorunlar
- Sağ üstteki bildirimler masa ve haritanın, mobilde haber şeridinin üstünde kalıyor (menü açılınca temizleniyor).
- Masada soldaki günlük lambadan uzak olduğu için karanlık kalıyor; okunurluk için `desk_lit` `ambient` ya da günlüğün yeri ayarlanabilir.
- Meclis görüşü metinleri genel kalıplardan kuruluyor (danışmana özgü ses yalnızca kılıf cümlelerinde). İçerik turunda danışman başına söyleyiş eklenebilir.
- Kullanıcı henüz tam bir saltanat oynamadı; denge, metin ve ses geri bildirimi bekleniyor. Linux build gerçek makinede denenmedi. Android/iOS kasıtlı yapılmadı.

## Kullanıcı tercihleri
Sormadan ilerle; büyük özellikte önce tasarla (`CLAUDE.md`). Sonuçta kısa Türkçe özet. Commit'e izin var, push yok.
