# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-05 (beşinci oturum: görsel dil v2). Dal: `veloria`.

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
- **Beşinci oturum: Görsel dil v2 ("devlet arşivi" cilası)**
  - Kullanıcı: "renk/tasarım fena değil ama daha profesyonel olsun". Ayrıntı ve kabul ölçütleri: `docs/ux/gorsel_dil_v2.md`.
  - Nötrler sıcak kömüre çekildi (mor kayma gitti; `UIKit.HOVER/SHADE/PLATE`), gövde fontu IBM Plex Sans (`UIKit.sans()`, metrikleri eski yedek fonta yakın, boyutlar korundu; CanvasLayer altındaki bildirim/perdeye tema ayrıca verildi), tüm kutular en fazla 3 px köşe (`UIKit.RADIUS`), köşebentli paneller çift çerçeve (iç kıl çizgisi), düğmeler 1 px kalkık, sekmeler üst çizgiyle seçili, alamet şeridi, rapor satırında yalnızca sol renk çizgisi, oyun sonu başlık bandı.
- **Beşinci oturum (devam): Medya Merkezi v2** — ayrıntı `docs/ux/medya_merkezi_v2.md`.
  - Gazeteler: kâğıt shader'ı (lif, sararma, katlanma izi), yarım ton fotoğraf baskısı + fotoğraf yazısı, künye kulakçıkları ve çift çizgi, iki yana yaslı serif gövde ("BAŞKENT —"), "Devamı sayfa N'de", çift çerçeveli ilan. Serbest Kalem kendi kimliğinde: gri ucuz kâğıt, kırmızı blok, kalın sans logo.
  - Halden TV: çizilmiş ceviz kasalı tüplü televizyon (VELTRON, düğmeler, hoparlör, güç ışığı); `crt.gdshader` ekran dokusunu okuyup görüntüyü ve kanal grafiklerini birlikte eğer (tarama, fosfor maskesi, parazit). Alt üçlü bant ve "HABERLER" bloklu şerit. Ekran boyutu eldeki alana göre (mobil sığar).
  - Hata: TV şeridi `ALAMET:` satırlarını yayınlıyordu (kralın gizli gözlemleri); `press.gd::broadcast` filtreler. `scanlines.gdshader` kaldırıldı. `ui_shots.gd` artık Serbest Kalem ve TV görüntüsünü de alır (`1_medya_serbest`, `1_medya_tv`).
  - Yayın durdurma mührü: prompt `ART_PROMPTS.md` (`art/media/yayin_muhru.png`, saydam ya da beyaz zemin). Kod hazır (`media_view.gd::_build_closed`, çarpma karışımı); görsel yerleşti (beyaz zemine yassılaştırılmış; çarpma karışımı saydamlığı yok sayar).
- **Beşinci oturum (devam): Gündemde "BU HAFTA" defteri** (masaüstü): karar kartlarının altında haftanın eylem sonuçları (`main.gd::_add_week_ledger`, `_week_log`); boşken sıradaki adımı söyler. Açılış/yükleme mesajı deftere girmez. Mobil TV kasası alt kenara taşmıyor.
- **Beşinci oturum (devam): Faz 1 tamamlandı** — `docs/design/faz1_okunabilirlik.md`.
  - `Sim.week_changes` (`_visible_snapshot` / `_diff_visible`, `end_week` içinde): yalnızca görünür göstergelerin farkı (rapor tonu, güç kademesi, tavır, düşmanlık, sözler, KULİS/MANŞET, kendiliğinden çözülen kararlar), en çok 6 satır, rng tüketmez. Gündemde "GEÇEN HAFTADAN BERİ" (masaüstü + mobil).
  - `Sim.report_prev`: rapor satırında çizilmiş yön oku (raporun söylediği bandın değişimi). İkisi de kayda yazılır.
  - Eylem önizlemesi: `main.gd::ACTION_META` + `_preview()` (mesai, servet, iz, tahmini risk; seçili kişiye göre bağlam). `Sim.power_tier()`, `Sim.BRIBE_COST` tek kaynak.
  - Hatalar: ertelenen kararların "ERTELENDİ" haberi eklendiği anda siliniyordu (`weekly_news.clear()` sırası) — artık oyuncuya ulaşıyor. TV şeridi yalnızca OLAY satırlarını yayınlar (önceden söz ve soruşturma notları da sızıyordu). Kategori sekmesi koddan değişince iki sekme basılı kalıyordu.
  - Mekanik değişmedi: `--full` sonucu birebir aynı (tohum 101, aynı ünvan, 54 olay).
  - Yayın durdurma mührü yerleşti (`art/media/yayin_muhru.png`).
- **Beşinci oturum (devam): Faz 0 güvence**
  - Kayıt sürümü: `Sim.SAVE_VERSION` (=2), `_migrate_save` (1 -> 2), `SAVE_REQUIRED` denetimi `new_game`'den önce; yeni sürüm/eksik alan/bozuk dosya çökmeden reddedilir, menüde nedeni pencerede gösterilir (`Sim.load_error`). Test: `tests/save_test.gd`.
  - Olay doğrulayıcısı: `tests/event_check.gd` (71 olay temiz). Kendisi de sınandı: bilerek bozulmuş kopyada 8 hatanın 8'i yakalandı (`-- --file=`).
- **Beşinci oturum (devam): İkinci yıl paketi** — `docs/design/ikinci_yil.md`.
  - 30 yeni olay (71 -> 101): Bedellerin Dönüşü (oyuncu geçmişine bağlı; yeni koşul `min_stat`/`max_stat`), Hesaplaşma (ordu muhtırası, Halden'in meclisi, çadır kent, soylular meclisi, Saray dosyası, gölge kabine), ortam olayları, iki zincir devamı. Hepsi mevcut görsellere bağlı.
  - Tempo: 57–96 dilimleri 0,6 -> 0,8–1,1 olay/hafta. Denge (advice_weighted): Kolay 85, Normal 48, Zor 21 (bantta).
  - Açık: kayıp çeşitliliği değişmedi (~%95 darbe). sim_test ulaşılabilirlik kontrolü `min_stat` ve `min_week`'i artık hesaba katıyor.
- **Beşinci oturum (devam): Kayıp çeşitliliği** — `docs/design/kayip_cesitliligi.md`.
  - Teşhis: ayaklanma ve yetkisizlik yolları ölüydü (eşik 100, aktif oyuncuda en yüksek huzursuzluk ~40, yargı baskısı ~30). Bastırma bedelsizdi, her yol Arden'in darbesine çıkıyordu.
  - Sokak öfkesi (bastırma borçtur), ayaklanma krizi (huzursuzluk ≥ 54), yetki krizi (yargı baskısı ≥ 40); darbe kartı kalıbında, o hafta çözülmezse düşüş. SOKAK/MAHKEME uyarı satırları, Bastır önizlemesinde öfke uyarısı. Kayıt sürümü 3.
  - Sonuç: kayıp oyun tarzına bağlı (kirli %16, yumuşak %11, bastıran %4 darbe dışı). Ölçüt bot Kolay 81, Normal 40, Zor 18 (bantta). Sondaja `advice_soft` / `advice_dirty` botları eklendi.
  - Açık: darbe hâlâ baskın; daha fazla çeşitlilik için darbe sıklığının kendisi düşürülmeli.

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
- Sağ üstteki bildirimler masa ve haritanın, mobilde alamet şeridinin üstünde kalıyor (masaüstünde şerit artık bildirim sütununa girmiyor).
- Masada soldaki günlük lambadan uzak olduğu için karanlık kalıyor; okunurluk için `desk_lit` `ambient` ya da günlüğün yeri ayarlanabilir.
- Meclis görüşü metinleri genel kalıplardan kuruluyor (danışmana özgü ses yalnızca kılıf cümlelerinde). İçerik turunda danışman başına söyleyiş eklenebilir.
- Kullanıcı henüz tam bir saltanat oynamadı; denge, metin ve ses geri bildirimi bekleniyor. Linux build gerçek makinede denenmedi. Android/iOS kasıtlı yapılmadı.

## Kullanıcı tercihleri
Sormadan ilerle; büyük özellikte önce tasarla (`CLAUDE.md`). Sonuçta kısa Türkçe özet. Commit'e izin var, push yok.
