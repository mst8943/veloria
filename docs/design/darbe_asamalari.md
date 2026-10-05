# Darbe Aşamaları ve Alametler — Sistem Tasarımı

Faz 1 / Okunabilirlik. Durum: **uygulandı** (2026-10-04). Ölçülen sonuçlar §11, uygulamada değişenler §14.
Tasarım özeti §21: "Darbe bir sabah rastgele çıkmamalıdır. … Oyuncu 'Ben bu adamı fazla güçlendirdim' demeli."

## 1. Amaç ve oyuncu fantezisi
Darbe, kralın kaybının ana biçimi (kayıpların ~%95'i). Şu an bir anda geliyor ve oyuncu ne hazırlığı görüyor ne de onu çözebiliyor.
Hedef: **Komplo görünür izler bırakarak olgunlaşsın, oyuncu bu izleri okuyup araya girebilsin, son anda da tek bir dramatik karar
anı (kriz) olsun.** Ürettiği gerilim: "Arden'in subayları geceleri toplanıyor. Ona para mı vermeliyim, yoksa bu bir dedikodu mu?"

İlke uyumu: 1 (alametler gürültülü, bazıları yalan), 2 (krizden kurtulmanın her yolu bedel bırakır), 3 (komplo bir kişinin hikâyesi),
4 (komplo oyuncu başka işle uğraşırken büyür), 5 (kaskad korunur).

## 2. Mevcut durum
- `actor.gd`: `rebellion_drive() = ambition + 0.3·power + 0.4·obligation + 0.5·(60 − perceived_king) − 0.8·Σloyalty`.
- `sim.gd _run_cascade`: `drive > ready_drive` (Normal 43) → `ready = true` (kalıcı). Kaskad: `share ≥ threshold − drop` ve `drive > 12` → ready.
  `week ≥ grace` ve `ready payı ≥ coup_share` (Normal 0.68) ve hazır bir askerî/kraliyet "vurucu" varsa **aynı hafta** darbe.
- `ready` hiçbir yerde `false` olmuyor; komplo çözülemez.
- Görünür izler: yalnızca `gizli_toplanti` olayı (`needs_ready`), soruşturma ipucu (`_reveal_hint`), meclis görüşündeki sabotaj.
- **Hata:** `_domain_truth("intel")` tanımlı değil, varsayılan `unrest`'e düşüyor. İstihbarat raporu komployu hiç yansıtmıyor.
- Ölçüm (Normal, 40 kampanya):
  | | visible | advice_weighted |
  |---|---|---|
  | Darbe lideri | Arden 32, Prens 1 | Arden 17, Prens 2 |
  | Komplo payı ≥%30 → darbe (hafta, medyan) | 6 (¼'ü aynı hafta) | 18 |
  | Darbede hazır kişi sayısı | 3–4 | 3–4 |
  | İlk hazır olma (medyan hafta) | Arden 22, Halden 25, Prens 31, Voss 32 | Halden 30, Arden 31, Voss 36 |

## 3. Oyuncu kararları
| Karar | Kısa vadeli kazanç | Uzun vadeli bedel |
|---|---|---|
| Alametlere göre gizli ödeme / söz / terfi | Komplocu sakinleşir, komplodan çekilebilir | Para izi; terfi gücü artırır (sonraki komplo daha güçlü) |
| Alameti dedikodu sayıp görmezden gelmek | Mesai korunur | Gerçekse kaskad büyür |
| Şüpheliyi görevden almak | Komplo başsız kalır | Sırlarını bilen biri karşı saldırır (mevcut kural) |
| **Krizde:** sadık birlikleri topla | Başarırsa komplo ezilir, lider tutuklanır | Başarısızsa taht gider; başarılı olsa da baskı izi ve korku kalır |
| **Krizde:** taviz ver | Kesin kurtuluş | Lider çok güçlenir; kral zayıf görünür; komplo ileride daha güçlü döner |
| **Krizde:** halka seslen | Sokak seninleyse kaskad çözülür | Sokak öfkeliyse ayaklanma ve darbe |

## 4. Kurallar ve durum
**Aktör komplo aşaması** (`plot_stage`, 0–3) ve çekilme sayacı (`plot_calm`):
| Aşama | Ad | Giriş | Davranış |
|---|---|---|---|
| 0 | Sakin | — | yalnızca yanlış alamet (dedikodu) |
| 1 | Huzursuz (Tohum) | `drive ≥ ready_drive − UNEASY_GAP` | ara sıra şikâyet alameti |
| 2 | Komplocu (İşaret) | mevcut `ready` kuralları (`ready = true`) | gizli görüşme alametleri, emirleri geciktirir, raporunu güzelleştirir, meclisde sabotaj |
| 3 | Hazırlıkta (Gerilim) | aşama 2 ve `ready payı ≥ coup_share − PREP_MARGIN` | güçlü alametler, kendi adamlarını yerleştirir (`power += PREP_POWER`/hafta) |

**Çekilme (yeni):** Hazır bir aktörü komploda tutan iki şey var: kendi öfkesi (`drive > ready_drive − LEAVE_GAP`) ya da kaskadın çekimi
(başkalarının payı `≥ threshold − drop` ve `drive > CASCADE_MIN_DRIVE`). İkisi de yoksa `plot_calm` artar; `LEAVE_WEEKS` hafta üst üste
böyle kalırsa `ready = false`, aşama 1'e iner. Lider çekilince kaskad çözülebilir. **Oyuncunun alametlere tepkisi anlam kazanır.**

**Kriz (Sonuç öncesi karar anı):** Darbe koşulu sağlandığında (grace, coup_share, vurucu) darbe hemen olmaz:
1. `coup_crisis = {leader, week}` kurulur, gündemin başına özel bir **kriz kartı** eklenir (bekleyen sınırı 3'ü aşabilir).
2. Oyuncu o hafta kartı çözer ya da çözmez. Hafta biterken kart hâlâ bekliyorsa darbe gerçekleşir (bugünkü sonuç).
3. Kriz kartında meclis susar (görüş üretilmez): "Bu kararı yalnız vereceksin."

**Haftalık sıra:** `… _run_cascade (aşamalar, çekilme, kriz) → _plot_signs (alametler) → _generate_reports …`.
Kriz bekliyorsa `end_week` başında darbe uygulanır.

**Sonuç ve artçı:** Krizin üç sonucu → bayraklar (`DARBE_BASTIRILDI`, `DARBE_TAVIZ`, `DARBE_HALK`) ve aşağıdaki etkiler. Bayraklar ileride
artçı olaylar için kullanılabilir (§8).

## 5. Formüller
### 5.1 Alametler (`_plot_signs`, her hafta, her `insider` ve `moved = false` aktör için)
`p = SIGN_P[aşama]` olasılıkla bir alamet; ağırlığı `SIGN_W[aşama]`. Aşama 0 alametleri **yanlıştır** (dedikodu).
Alamet bir haber satırı olarak çıkar ("ALAMET: …") ve aktörün `signs` kaydına `{w, text, weight}` olarak yazılır.
Ayrıca: aşama ≥ 2 bir aktöre emir verilirse `fidelity *= ORDER_DELAY` ve "emri geciktirdi" alameti (ağırlık 2).

**Şüphe düzeyi** (arayüzün tek göstergesi): son `SUS_WINDOW` haftadaki alamet ağırlıkları toplamı `S`.
`S < 2` Sakin · `2–3` Huzursuz · `4–6` Şüpheli · `≥ 7` Tehlikeli. Sayı gösterilmez; yalnızca kelime + renk + alamet listesi.

### 5.2 Raporlar
- `_domain_truth("intel") = clamp(max(0.6·unrest, 120·ready_payı), 0, 100)`: Voss'un raporu artık komployu da ölçer.
- Komplocu kendi alanını güzeller: `_domain_reported` içinde lerp ağırlığı `flattery·0.6 + (PLOT_SPIN if ready)`.
  (Komplocu Arden "Ordu sağlam" der; komplocu Voss "Dosyalarda olağanüstü bir şey yok" der.)

### 5.3 Kriz sonuçları
`guard = Σ power (insider, askerî ya da kraliyet, hazır değil) / 100`
| Seçenek | Başarı olasılığı | Başarı | Başarısızlık |
|---|---|---|---|
| I Sadık birlikleri topla | `clamp(RALLY_BASE + (king − 50)/100 + guard·0.3 + (1 − pay)·0.5, 0.05, 0.85)` | lider tutuklanır (oyundan çıkar), diğer hazırlar: `fear +20, ambition −10, ready=false`; `king +5, unrest +8`; iz: "Darbe girişiminin bastırılması" (kral, 25) | darbe |
| II Taviz ver | kesin | lider: `power +15, l_career +20, obligation +20, ambition +5`; tüm hazırlar `ready=false`; `king −15`; herkes `perceived_king −5` | — |
| III Halka seslen | `clamp(APPEAL_BASE − unrest/100 − opp/200 + (king − 50)/200, 0.05, 0.8)` | lider dışı hazırlar `ready=false, fear +10`; `king +3, unrest −5` | `unrest +15`, darbe |
Kart metni o anki görünür durumu kabaca anlatır (sokak, muhafız, saray) ki seçim bilgisiz olmasın: sokak cümlesi basın raporunun
bandından, muhafız cümlesi `guard`'dan (bant), saray cümlesi kâhya raporunun bandından.

### 5.4 Parametreler
| Ad | Varsayılan | Not |
|---|---|---|
| UNEASY_GAP | 15 | huzursuzluk eşiği = ready_drive − 15 |
| leave_gap (zorluk) | 22 / 14 / 12 | kendi öfkesiyle komploda kalma eşiği = ready_drive − leave_gap (§14) |
| CASCADE_MIN_DRIVE | 8 | kaskadın tutabilmesi için en düşük öfke (giriş 12, histerezis) |
| LEAVE_WEEKS | 2 | |
| PREP_MARGIN | 0.15 | hazırlık: pay ≥ coup_share − 0.15 |
| PREP_POWER | 1.0 | hazırlıktaki vurucunun haftalık güç artışı |
| SIGN_P | [0.04, 0.15, 0.35, 0.6] | aşama 0..3 |
| SIGN_W | [1, 1, 2, 3] | |
| SUS_WINDOW | 8 hafta | |
| ORDER_DELAY | 0.6 | |
| PLOT_SPIN | 0.35 | |
| RALLY_BASE / APPEAL_BASE | 0.05 / 0.6 | × zorluk `crisis_odds` (0.95 / 0.65 / 0.55) |
| CRISIS_CONCEDE | [1.0, 0.5, 0.2] | taviz başarı olasılığı, önceki taviz sayısına göre |
| CRISIS_COOLDOWN | 6 | çözülen krizden sonra yeni kriz için en az hafta |
| SUMMON_* | bekleme 4, ele verme 0.6, yanlış 0.1, +6 algı, +4 kariyer, +6 korku | Huzura Çağır (§14) |
Zorluk: mevcut `ready_drive`, `coup_share`, `grace` kalır; denge ayarı §11'de bunlarla yapılır.

## 6. Bilgi tasarımı
- **Akış:** "ALAMET: Arden'in subayları geç saatlere kadar karargâhta toplanıyor." (haftanın haberleri / bildirimler)
- **Kişi kartı:** Şüpheli/Tehlikeli ise rol satırı rengi değişir (amber / kırmızı), alt satırda "ŞÜPHELİ" yazar.
- **Kişi paneli:** "Tavır · Şüpheli" göstergesi (3 dilim). İpucu son alametleri tarihleriyle listeler ve uyarır: "Alametler dedikodu da olabilir."
- **Raporlar:** Voss'un raporu komployu ölçer (o da komplocu değilse). Komplocunun raporu fazla iyimser: yankı odası ipucu.
- **Meclis:** Komplocu danışman kötü önerir (zaten var). Şüpheli biri meclisteyse görüşünün ipucunda "Son zamanlarda hakkında alametler var." notu.
- **Akış şeridi:** kriz varken en başta kırmızı "DARBE GİRİŞİMİ".
- **Gerçeğin açılması:** Hakikat Dosyası'nda **Komplo Defteri**: kim hangi hafta huzursuzlandı, komploya girdi, hazırlığa geçti, çekildi;
  hangi alametler dedikoduydu.

## 7. Etkileşimler
| Sistem | Etki |
|---|---|
| Kaskad | Korunur; çekilme ile iki yönlü olur. Lider çekilirse kaskad çözülebilir |
| Raporlar | `intel` artık komployu ölçer; komplocu raporunu güzeller |
| Emirler | Komplocu emri geciktirir (görünür alamet) |
| Meclis görüşleri | Sabotaj (K_READY) + şüphe notu |
| Sözler / ödeme / terfi | `drive`'ı düşürerek çekilmeyi tetikler; terfi gücü artırır (sonraki krizde lider daha güçlü) |
| Sırlar | Krizi bastırmak kral hakkında yeni bir iz bırakır |
| Olaylar | `gizli_toplanti`, `suikast` aynen; yeni bayraklar artçı olaylar için |
| Oyun sonu | Neden metni değişmez (darbe); Komplo Defteri eklenir |

## 8. İçerik ihtiyacı
- Alamet cümleleri: aşama × alan (ordu/istihbarat/medya/hanedan/genel), her biri 2–3 söyleyiş; dedikodu cümleleri.
- Kriz kartı: başlık, liderin alanına göre metin, durum cümleleri, 3 seçenek ve sonuç metinleri.
- Artçı olaylar (ilerisi için, bu turda isteğe bağlı): "Tutuklu generalin yargılanması" (`needs_flag: DARBE_BASTIRILDI`), "Başbakan Arden'in talepleri" (`DARBE_TAVIZ`).
- Görsel: kriz kartı için `art/events/darbe_krizi.png` (yoksa mevcut bir görsel; prompt asset-spec ile).

## 9. Arayüz
Kişi kartı rol satırı, kişi paneli göstergesi, kriz kartı (kırmızı çerçeve, meclis yerine "Meclis susuyor" notu), akış şeridi, Komplo Defteri.
Hepsi mevcut bileşenlerle (`_trait`, `_pill`, kart, `_section`); ayrı UX belgesi gerekmez.

## 10. İstismarlar ve uç durumlar
- **Her alamete rüşvet:** Alametlerin bir kısmı dedikodu; para izi ve servet sınırı bunu pahalı kılar.
- **Krizde hep taviz:** Lider güçlenir ve komplo tekrar döner; ikinci kriz daha erken. Ölçülecek: taviz sonrası tekrar kriz oranı.
- **Kriz kartını erteleme:** Hafta sonunda darbe. Kart sınırı ve mesai kontrolü: kriz kartı mesai 0 iken de görünür; çözümü 1 mesai ister. Mesai yoksa erteleme = darbe. Bu yüzden kriz, mesai yenilendiği hafta başında gelir.
- **Lider kriz sırasında görevden alınır:** Kriz iptal, hazır olanlar kalır; sonraki hafta koşul yeniden değerlendirilir.
- **Kayıt/yükleme:** `plot_stage`, `plot_calm`, `signs` → `SAVE_PROPS`; `coup_crisis` → `save_game`. Eski kayıtta varsayılanlar 0/[]/{}.
- **Grace öncesi:** Kriz olmaz; aşamalar ve alametler işler.

## 11. Denge hedefleri ve ölçülen sonuç
Hedef (`advice_weighted`, alametlere boş mesaide tepki verir): Kolay %70–85, Normal ~%45, Zor %15–30.

Ölçüm (80 kampanya, son parametreler):
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible (görüşsüz, alametsiz) | %56 | %23 | %15 |
| advice_naive | %90 | %61 | %32 |
| **advice_weighted (ölçüt)** | **%80** | **%48** | **%27** |
| visible_wise (tavan) | %100 | %98 | %88 |

Komplo davranışı (Normal, 80 kampanya, advice_weighted): komplo payı ≥%30 → darbe arası medyan ~13–20 hafta (önce 6);
aynı hafta patlayan darbe %25 → ~%5–10. Krize giren kampanyaların ~%40'ı krizden sağ çıkıyor (görüşsüz botta ~%27).
Alametlerin ~%70–85'i gerçek. `sim_test`'te "dikkatli" botun kazandığı ünvanlar belirgin biçimde çeşitlendi
(Generallerin Kuklası tekelinden Medya/Brandt/Prens/Gölge Devlet karışımına).

**Bilinen:** Alametlere tepki veren bot, tepki vermeyenle aşağı yukarı aynı sonucu alıyor (Normal %74'e karşı %76, aynı parametrelerle).
Alamet okumanın değeri şu an bot için nötr. Bot kaba bir oyuncu; insan oyuncu Huzura Çağır'ı daha seçici kullanabilir. Oyuncu testinde
izlenmeli: "alameti gördüm ama işe yaramadı" hissi çıkarsa Huzura Çağır'ın etkisi artırılabilir.

## 12. Uygulama planı
1. `actor.gd`: `plot_stage`, `plot_calm`, `signs`; `SAVE_PROPS`.
2. `sim.gd`: sabitler; `_run_cascade` → aşamalar, çekilme, kriz kurulumu; `_plot_signs`; `_domain_truth("intel")`; `_domain_reported` spin;
   `order` gecikme; `suspicion(id)` / `suspicion_level(id)`; kriz kartı üretimi ve `resolve_decision` içinde kriz eylemleri; `end_week` başında
   çözülmemiş kriz → darbe; `_pick_advisors` krizde boş; `plot_log` → `record["plot"]`; kayıt.
3. `main.gd`: kişi kartı ve paneli, kriz kartı stili, akış şeridi, Komplo Defteri.
4. `probe_template.gd`: advice botları şüpheliye tepki verir (gizli ödeme/söz); kriz kartında görünür ipuçlarına göre seçim.
5. `sim_test.gd`: çekilme çalışıyor, kriz kartı çıkıyor ve çözülmezse darbe oluyor, kayıt/yükleme, alametlerin doğruluk oranı.
6. Ölçüm → zorluk ayarı → ekran görüntüleri → belgeler → commit.

## 13. Açık sorular (varsayılanla ilerleniyor)
1. Şüphe göstergesi açık mı (varsayılan: açık, kelimeyle) yoksa yalnızca alamet akışı mı?
2. Krizden kurtulmanın ödülü ne kadar büyük olmalı? (varsayılan: bastırma komployu bitirir ama iz + korku bırakır)
3. Artçı olaylar bu turda mı? (varsayılan: hayır; bayraklar hazır, içerik turunda yazılır)

## 14. Uygulama sırasında değişenler
- **Kriz sertleştirildi.** İlk sürümde tartan bot krizlerin %92'sinden sağ çıkıyordu. `CRISIS_RALLY_BASE` 0.2 → 0.05; **taviz giderek
  zorlaşıyor** (`CRISIS_CONCEDE` = [1.0, 0.5, 0.2]: "Bir kez boyun eğen krala ikinci kez inanmazlar"; kart metni bunu söyler).
- **Yeni eylem: Huzura Çağır** (KAZAN satırı, 1 mesai, izsiz, kişi başına 4 haftada bir). Ölçüm, alametlere gizli ödemeyle tepki vermenin
  oyunu **kötüleştirdiğini** gösterdi (Normal %76 → %52): her ödeme bir iz bırakıyor, izler yayılınca kral zayıf görünüyor ve kaskad kolaylaşıyor.
  Oyuncunun alamete karşı izsiz bir aracı olmalıydı. Huzura Çağır kişiyi yatıştırır (`perceived_king +6`, `l_career +4`); komplocu %60
  ihtimalle kendini ele verir (alamet + `l_fear +6`); sakin biri %90 temiz çıkar ve hakkındaki dedikodular silinir. Alamet ile dedikoduyu
  ayırt etmenin yolu budur.
- **Zorluk tablosuna** `crisis_odds` ve `leave_gap` eklendi; zorluk başına değerler:
  | | ready_drive | coup_share | advice_noise | crisis_odds | leave_gap |
  |---|---|---|---|---|---|
  | Kolay | 48 → 44 | 0.74 | 0.8 → 0.9 | 0.95 | 22 |
  | Normal | 43 → 39 | 0.68 → 0.66 | 1.0 → 1.2 | 0.65 | 14 |
  | Zor | 38 → 36 | 0.63 | 1.25 | 0.55 | 12 |
- **Hata düzeltmeleri:** `_domain_truth("intel")` artık komployu ölçüyor (önceden varsayılan `unrest`'e düşüyordu). Oyun bitince `mesai = 0`:
  kriz hafta ortasında oyunu bitirebildiği için "mesai kaldıkça" dönen döngüler (testler, botlar) sonsuza kadar dönüyordu.
- **Kayıp metni** darbe gecesini anlatır ("Darbe gecesi halka seslendin; meydan boş kaldı.").
- `PLOT_LEAVE_GAP` sabiti kaldırıldı (zorluk tablosunda `leave_gap`).
