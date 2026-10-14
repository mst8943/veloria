# Ana ekran: ferah "Bu hafta" paneli + Kişi dosyası belgesi

Hedefler (kullanıcının onayladığı tasarımlar):
- `docs/ux/ref/bu_hafta_ferah_hedef.webp` — sağ sütun: İzleme listesi + ferah "Bu hafta" paneli (meclis salonu görseli) + Raporlar + "Tüm raporlar (N)".
- `docs/ux/ref/kisi_dosyasi_hedef.webp` — bir kişi seçilince sayfanın ortasına açılan "Kraliyet İstihbarat Divanı" sicil dosyası.

## 1. Neyi değiştiriyor
Sağ sütundan **"Diğer kişiler Divan'da" satırı, seçili kişi paneli ve Eylemler paneli kalkar**. Yerlerini ferah "Bu hafta" ve "Raporlar" bölümleri alır. Kişiye dair her şey (bilgi + eylemler) artık kişi dosyasında olur. Ana ekranın geri kalanı (başlık, haber şeridi, sol sekmeler, adım çubuğu, izleme listesi, alt bilgi) AYNI kalır.

**Bilinçli kural değişikliği:** Ana ekran "onaylı, dokunulmaz" idi; bu görev onu kasten değiştirir. Görev dosyalarındaki "ana ekran değişmemeli" maddesi bu bölgeler için geçersizdir.

## 2. Ferah sağ sütun (hedef: bu_hafta_ferah_hedef.webp)
- İZLEME LİSTESİ + "+16 Divan" (Divan'a açılan bağlantı bu ikisinde zaten var; ayrı "Diğer kişiler Divan'da" satırı kalkar). Kartlara tıklamak dosyayı açar.
- **BU HAFTA** paneli (tek süslü çerçeve): başlık "◆ BU HAFTA ── yaptıklarının ve sonuçları" (daha büyük, serif); meclis/hükümet satırı ve haftanın yaptıkların satırları rahat satır aralığıyla; panelin alt yarısında dekoratif banner: meclis salonu görseli (`art/ui/bu_hafta_banner.png`, yoksa koyu degrade yedeği). "Bu hafta değişenler" bölümü doluysa bu panelin üstünde ayrı satırlar olarak çıkar, boşsa yer kaplamaz.
- **RAPORLAR** paneli (tek süslü çerçeve): başlık büyük; en çok 4 rapor satırı, her satır: ton çubuğu + büyük portre (~44 px, çerçeveli) + kalın ad + metin (14–15 px, satır başına rahat dikey boşluk ~10 px); altta tam genişlikte "Tüm raporlar (N)" düğmesi (mevcut tüm-raporlar penceresini açar).
- Üç bölüm arası boşluk ~12 px. Hepsi 1600×900 ve 1280×720'de kaydırmadan sığar (raporlar 4 satıra kadar; fazlası "Tüm raporlar"da).

## 3. Kişi dosyası (hedef: kisi_dosyasi_hedef.webp)
**Açılma:** izleme listesinde / Divan'da / rapor satırında / haritada bir kişiye tıklayınca. Konum: sayfanın ortası, sol panelin üstüne binen büyük belge (masaüstünde ekranın ~%80 genişliği, ~%88 yüksekliği; başlık bandı ve haber şeridi görünür kalır). Arkası hafif karartılır; sağ üstte kapatma "×" (Esc de kapatır, boşluğa tık da). Açılış animasyonu: kâğıt yığını aşağıdan hafifçe kayarak gelir (hareketi azalt açıkken anında).
**Çoklu seçim (Operasyon çemberi) korunur:** Ctrl/Çoklu seçim açıkken dosya AÇILMAZ; seçim şeridi ve op eylemleri için küçük bir "Operasyon" çubuğu sol panelin altında belirir (ya da dosyanın içinde "Operasyon" sekmesi). Ajan bunu mevcut op akışını bozmadan çözmeli ve belgelemeli.

**Yerleşim (belgede):**
- Üst başlık: arma + "VELORIA KRALİYET İSTİHBARAT DİVANI" + alt satır "GİZLİ SİCİL DOSYASI · NO: <ROL>-<n>" (kişi rolüne göre sabit: ORDU-01, İSTİHBARAT-01, MALİYE-01 …; EN: "SECRET FILE · NO: ARMY-01").
- Sol üst: fotoğraf (portre) + paper-clip + sancak + mühür görseli. Sağ üst: künye tablosu: [KİŞİ] ad, [MAKAM] unvan, [GÜÇ DERECESİ] nitel güç kademesi + tek cümle, [GÜNCEL TAVIR] Sakin/… + tek cümle (şüphe düzeyi, alametlerden).
- Sol sütun: **1. SARAY GÖZLEMİ & RUH HALİ** (kişiye özgü 2–3 madde + "Gözlem Notu"), **2. HASSAS VE GİZLİ BİLGİLER** (ZAYIF NOKTA: bilinmiyorsa "[ ? ]" + "Henüz öğrenilmedi, 'Araştır' ile ortaya çıkarılabilir"; KIRMIZI ÇİZGİ aynı), **3. HÜKÜMDARLA İLİŞKİ VE SİCİL** (doğruluk karnesi: doğrulanmış raporlardan nitel; bekleyen sözler; sadakat/borç nitel).
- Sağ sütun: **4. MÜDAHALE YOLLARI VE BEDELLERİ (EYLEMLER)** grupları A–E (Sadakat Kazan, Bağla/Söz Ver, Öğren & Denetle, Baskı & Emir, Devlet ve Ordu Yönetimi; kişiye uygun gruplar + Halk/Operasyon sekmelerinin karşılığı) — her eylem **tıklanabilir bir satır**: ad + "(1 Mesai)" + etki özeti ("→ İz bırakmaz, para istemez…"). Kullanılamayan eylem sönük + sebebi ("[KİLİTLİ] Zayıf nokta öğrenilmeden kullanılamaz", "[RİSKLİ] …"). Eyleme tıklamak mevcut `_act`/`Sim` akışını çağırır; sonuç dosyanın altındaki "Son eylem" satırında + Bu hafta panelinde görünür; mesai bitince satırlar sönük.
- Alt: kaleli şehir silueti (dekor). Dosya bir kez eylem yapılınca KAPANMAZ (art arda eylem yapılabilir); sonuç metni dosyada kısa süre vurgulanır.

**İçerik ilkesi:** "sayı yok" ve gizli değer sızdırma yasağı aynen geçerli. Hiçbir gizli sayı gösterilmez; zayıf nokta/kırmızı çizgi yalnızca `known_weak/known_red` iken; güç ve tavır mevcut nitel bantlar; doğruluk karnesi yalnızca doğrulanmış (cross_check) raporlardan "tutarlı/çelişkili/henüz çapraz sorgu yok". Kişiye özgü "Saray gözlemi" metinleri yeni içeriktir: her kişi için TR+EN, TAM 21 kişi (aşağıdaki kapsam tablosu); kısa (≤ 3 madde), karaktere özgü, sabit; durum değiştiren cümle (ör. "Gözlem notu") mevcut şüphe/alamet sistemine bağlı kalıbı kullanır, uydurma gizli bilgi vermez. Metinler `game/data/*.json` + `game/data/en/*.json` içine (yeni `person_files.json`).

## 3b. Kapsam: 21 kişinin tamamı (game/data/actors.json)
Dosya TÜM kişiler için açılır ve her biri için `person_files.json` içinde TR+EN içerik zorunludur; test her actor id için içerik varlığını doğrular (yeni kişi eklenirse test kırılır).
| Grup | id'ler | Dosya numarası ön eki | Eylem grupları |
|---|---|---|---|
| Güç merkezleri (9) | arden, voss, kessler, halden, lena, dorn, prens, brandt, falk | ORDU, İSTİHBARAT, MALİYE, MEDYA, BASIN, SARAY, HANEDAN, MUHALEFET, YARGI | A–E tam set (Kazan, Söz Ver, Öğren, Emret, Baskı) |
| Veliaht (1) | julian | HANEDAN-2 | Kazan/Öğren + "Veliahdı Yetiştir"; Baskı grubu uygun değilse gizli/sönük |
| Dış ilişkiler (4) | elena, claire, malenkov, lucien | DIŞİŞLERİ, ASTERIA, DRAKON, SERAVİA | Öğren + "Heyet Gönder" (delegation); dış temas şüphesi satırı (Sim.external_suspicion_level) |
| Valiler (4) | governor_capital, governor_industry, governor_farmland, governor_border | VALİ-BAŞKENT/SANAYİ/OVALAR/SINIR | Bölge yönetimi, atama/azil (R4b'deki vali eylemleri), bölgenin nitel durumu satırı |
| Komutanlar (3) | commander_capital, commander_border, commander_security | ORDU-BAŞKENT/SINIR/JANDARMA | Ordu düzeni, subay tayini, ikmal, garnizon (R5b), birlik durumu satırı |
Hangi eylemin hangi kişide görüneceği/kullanılabileceği mevcut kurallardan gelir (person_panel.gd `_update_action_states` ve ilgili Sim kontrolleri); dosya bu kuralları DEĞİŞTİRMEZ, yalnızca gösterir. Seçili kişiye bağlı olmayan eylemler (Devlet: vergi/kemer/teşvik/ihale/Bölge Yönetimi/Ordu Düzeni; Halk: halka konuş/saha/tören/gizlen) her dosyada E "Devlet ve Ordu Yönetimi" ve F "Halk" gruplarında görünür (kişiye bağlı olmadıkları satır başlığında belirtilir: "Genel"). Operasyon (çoklu seçim, 2 mesai) dosyada değil, çoklu seçim şeridinde kalır.

## 4. Mobil (yatay 1067×600)
Dosya tam ekran sayfa olarak açılır (çekmece değil); üstte "×"; içerik tek sütun, bölümler kaydırılır, eylem satırları ≥ 44 px, M1 dokunma kuralları. Sağ sütun mobilde zaten sekmelere ayrık (Kişiler/Raporlar); "Kişiler" sekmesindeki kişi bloğu ve eylem paneli yerine kart tıklaması dosyayı açar. Mobilde "Bu hafta" paneli görseli gizlenir (yer).

## 5. Görseller (kullanıcı üretir; gelene kadar koyu degrade/çizim yedeği, kod değişmeden görünür)
| Dosya | Boyut | Not |
|---|---|---|
| `art/ui/dosya_kagit.png` | 2200×1500, opak | eskimiş parşömen kâğıt yığını (3–4 üst üste kâğıt, altın köşe süsleri, solda tükenmez kalem, sağda yan yana ek kâğıtlar/harita parçası), içi BOŞ: yazı, kişi, arma, mühür YOK; yalnızca dekor ve boş başlık/ayraç çizgileri |
| `art/ui/dosya_arma.png` | 520×440, saydam | taçlı aslanlı kalkan arması (altın, koyu), yazı yok |
| `art/ui/dosya_muhur.png` | 300×300, saydam | kırmızı balmumu mührü, kabartma aslan |
| `art/ui/dosya_foto_cercevesi.png` | 700×820, saydam | fotoğraf köşe bantlı çerçeve + paper-clip + siyah sancak şeridi; ortası saydam (portre arkasına girer) |
| `art/ui/bu_hafta_banner.png` | 1400×420, opak | meclis salonu: uzun masa çevresinde oturan figürler, arkada taç, mumlar; koyu, sakin; yazı yok |
Saydamlık sorun olursa düz siyah zeminli üretilip arka plan temizlenir.

## 6. Etkilenen kod (ajan için)
`game/ui/main.gd` (sağ sütun kurulumu, `_select`/`_update_info`/`_style_cards` çağrıları), `game/ui/person_panel.gd` (kişi bloğu + eylem paneli: eylem tanım tablosu `groups`/`actions` BURADAN yeniden kullanılmalı, kopyalanmamalı; `_act`, `_op`, `_public_action`, `_preview`/ipucu metinleri), `game/ui/agenda_view.gd` (`_add_changes`, `_add_week_ledger`, `_fill_reports_compact`), `game/ui/divan_view.gd`, `game/ui/tour_view.gd` (tur hedefleri: `person_block` vb. yeni dosyaya bağlanmalı), `game/ui/city_view.gd` (kişi seçimi), yeni `game/ui/person_file.gd`, `tests/ui_input_test.gd`, `tests/ui_logic_test.gd`, `tests/tour_test.gd`, `tests/a11y_test.gd` (kırılan testleri güncellerken testi gevşetme; davranışın karşılığını doğrula). Yeni test: `tests/person_file_test.gd` (dosya açılır/kapanır, Esc, eylem satırı mesaiyi harcar, kilitli eylem tıklanmaz, çoklu seçimde açılmaz, EN/TR içerik her kişi için var, gizli bilgi sızmaz).

## 7. Claude doğrulaması (ilk uygulama sonrası) — düzeltilecekler
Ekran: `docs/ux/ref/kisi_dosyasi_ilk_uygulama.jpg`, hedef: `docs/ux/ref/kisi_dosyasi_hedef.webp`. Testler geçiyor ama dosya mockup'a UYMUYOR:
1. **Kâğıtla ilişkisiz koyu kutular:** künye ve eylemler yarı saydam koyu dikdörtgenler olarak kâğıdın ÜSTÜNE biniyor, kâğıttaki boş alanlarla (fotoğraf yeri, 4 başlık çubuğu, ayraçlar) hizalanmıyor. Mockup'ta tüm metin KÂĞIDIN ÜSTÜNDE koyu mürekkep (kahverengi-siyah) yazı; koyu kutu yok. Metin, kâğıt görselindeki bölümlere (sol üst fotoğraf alanı, sağ üst künye, sol sütun, sağ sütun başlık çubukları) pikselle oturmalı (kâğıt görselini `art/ui/dosya_kagit.png` aç, bölge koordinatlarını ölç, ızgara bindir).
2. **Üst başlık kesik:** "VELORIA KRALİYET İSTİHBARAT DİVANI" ilk harfleri arma/kenar tarafından yutuluyor; arma (`dosya_arma.png`) başlığın solunda/ortasında düzgün durmalı, başlık okunur olmalı.
3. **Metin kalem ve mührün üstüne biniyor:** sol sütun yazısı kalemle çakışıyor, mühür metnin üstünde duruyor. Sol sütun kalemin SAĞINDAN başlamalı; mühür mockup'taki gibi fotoğrafın sağ alt köşesine (fotoğrafla birlikte) yerleşmeli.
4. **Fotoğraf çerçevesi:** `dosya_foto_cercevesi.png` kullanılıyor ama içindeki portre çerçeveye oturmuyor/üstünde ayrı bir altın çerçeve daha var (çerçeve üstüne çerçeve). Portre çerçevenin saydam penceresinin arkasına girmeli; ikinci çerçeve YOK.
5. **Eylemler paneli taşıyor:** yalnızca KAZAN, SÖZ VER, ÖĞREN görünüyor, EMRET/BASKI/DEVLET/HALK kesik. Mockup'taki gibi sağ sütunda A–E grupları, her grup kendi başlık çubuğu altında, hepsi kaydırmadan ya da kâğıt içinde düzgün kaydırmayla görünsün; satır biçimi: "Huzura Çağır (1 Mesai) → etki özeti" (üç dar düğme değil, tam genişlik satır).
6. **Boyut:** belge ekranı yeterince kaplamıyor (mockup ~%80×%88); 1600×900'de kâğıt görselinin en-boy oranı korunarak mümkün olduğunca büyük.
7. **Mobil:** künye kutusu ile kâğıt çubukları üst üste, metin çubukların dışına taşıyor; mobilde kâğıt görselini arka plan olarak kullanıp içeriği tek sütun, kâğıt yüzeyine koyu mürekkep yazıyla dök (ya da düz parşömen dokusu), çubuk görsellerini mobilde gizle.
8. **Sağ sütun "Bu hafta":** banner çok küçük/yan bant gibi; mockup'ta panelin alt yarısını kaplayan geniş salon görseli. "Raporlar" 4 satır ve "Tüm raporlar (11)" iyi.
