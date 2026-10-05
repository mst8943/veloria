# Danışman Görüşleri (Meclisin Fısıltısı) — Sistem Tasarımı

Faz 1 / Okunabilirlik. Durum: **uygulandı** (2026-10-04). Ölçülmüş sonuçlar §11, uygulama sırasında değişenler §14.

## 1. Amaç ve oyuncu fantezisi
Bir kral karar verirken yalnız değildir; masanın etrafında herkes bir şey söyler ve herkesin bir hesabı vardır.
Bu sistem karar kartlarına **iki danışmanın kısa görüşünü** ekler. Görüşler gerçek etkilerden türetilir ama
danışmanın **çıkarı, dürüstlüğü, uzmanlığı, korkusu ve gizli niyeti** ile bükülür.

Ürettiği gerilim: "Kessler dürüsttür ama ordu hakkında ne bilir? Arden haklı olabilir ama bu seçenek onu güçlendiriyor."
Oyuncu seçenekleri körlemesine değil, **kime inandığına** göre seçer. Bu, oyunun ana fantezisiyle (yalan söyleyebilen
insanların sözlerinden gerçeği sezmek) aynı kas; raporlardaki beceri kararlara da taşınır.

İlke uyumu: 1 (belirsiz ama sezilebilir), 2 (danışmanı güçlendiren seçenek iz bırakır), 3 (öneriler isimlere bağlı),
5 (yankı odası: korkan meclis "takdir sizindir" der).

## 2. Mevcut durum
- Kart: başlık + metin + 2–3 seçenek düğmesi (`main.gd:2037-2110`). Düğme ipucu yalnızca "1 mesai harcar".
- Seçenek etkileri `events.json` içindeki `fx` alanında; oyuncuya hiçbir şekilde görünmez (sonuç metni seçimden sonra gelir).
- Ölçüm (Normal, 40 kampanya, `probe_template`): görünür bilgiyle rastgele seçen bot %17, `fx` okuyan bot %75.
  **Kararın kalitesi sonucu belirliyor, oyuncu kaliteyi göremiyor.** En büyük kaldıraç budur.
- 71 olay, 69'u 3 seçenekli. Kralın çıkarı açısından seçenek değeri `V` (aşağıda) −18…+16, sd 5,3;
  en iyi ile ikinci arasındaki fark medyanı 2,7 (41 olayda < 3). Yani seçenekler çoğu zaman yakın; doğru danışman gerçekten fark yaratır.
- Seçeneklerde en sık taraf olan aktörler: Halden 25 olay, Arden 22, Voss 16, Kessler 12, Prens 9, Brandt 9, Falk 7, Dorn 3.
- Tasarım özeti §4 "Saray danışmanları"nı bilgi kaynağı olarak sayar; kararlara bağlı danışman sistemi belgede yok (yeni).

## 3. Oyuncu kararları
| Karar | Kısa vadeli kazanç | Uzun vadeli bedel |
|---|---|---|
| Çoğunluğa / dürüst bilinen danışmana uy | Ortalama olarak iyi seçim | Onun uzmanlığı dışındaki konularda yanılabilir |
| Çıkarı olan danışmana uy | Danışmanın kariyer/güç sadakati artar (seçenek bunu zaten yapıyorsa) | Danışman güçlenir, hırsı büyür (darbe sürücüsü) |
| Görüşlerin tersini seç | Şüphelenilen bir danışmanı "test etmek" | Yanlışsa sonuç kötü |
| Danışmanın raporlarını Doğrula (mevcut eylem, 1 mesai) | Karnesi dolar, kime güveneceğin netleşir | Mesai |

İkincil sinyal: **Hazır (darbeye kararlı) bir aktör bilerek kötü öneri verir.** Bir danışmanın önerileri sürekli diğerleriyle
çelişiyorsa bu bir uyarıdır. Bu, gizli darbe durumuna yeni ve okunabilir bir pencere açar (Faz 1'in "darbeyi görünür yapma" maddesine köprü).

## 4. Kurallar ve durum
**Kim danışman olabilir:** sarayın içindekiler (`insider = true`), yaşıyor, `moved = false`.
Lena ve Brandt meclis üyesi değildir (onların sesi basın ve muhalefet raporlarıdır).

**Ne zaman üretilir:** Kart ilk kez gösterilecekken (`Sim.advice_for(pending_index)`), tembel üretim; sonuç
`pending[i]["advice"]` içine yazılır. `pending` zaten kayda girdiği için yeniden yüklemede görüşler değişmez.
Kart ertelenip ikinci haftaya kalsa da görüş sabittir (danışman sözünü geri almaz).

**Rastgelelik:** Görüş gürültüsü ana `rng`'yi **tüketmez**; `hash(seed, olay_id, eklenme_haftası, aktör_id)` ile tohumlanan
yerel bir `RandomNumberGenerator` kullanılır. Böylece görüşlere bakmayan bir oyunun simülasyonu bugünküyle birebir aynı kalır
ve denge karşılaştırması temiz olur.

**Seçim (hangi iki danışman):**
1. **Taraf olan:** Seçeneklerin `fx.actors` alanında en büyük mutlak kişisel etkiye sahip uygun aktör (eşitlikte güç).
2. **Uzman:** Olayın baskın boyutuna göre (bkz. 5.4) birincil, yoksa ikincil uzman; birinciyle aynıysa sıradaki.
3. Taraf olan yoksa iki uzman. Uygun danışman yoksa görüş bloğu gösterilmez.

**Haftalık tick:** Değişiklik yok. Kayıt: `resolve_decision` her kart için görüşleri `advice_log`'a işler (oyun sonu raporu için).

## 5. Formüller

### 5.1 Kralın çıkarı (tek doğruluk kaynağı)
`V(fx) = 2·king − unrest + 0.7·economy − 0.5·opp + 0.3·wealth − Σ_aktör(0.3·power + 0.4·ambition + 0.3·obligation − 0.3·Σ l_*) − 3·[fact] − 5·[promise_break]`
(`Sim.choice_value(fx)`; botlar ve `--full` otomatik oynatması da onu çağırır. Sadakat terimi (`ADVICE_LOYALTY_VALUE` = 0.3) uygulama sırasında eklendi; bkz. §14.)

### 5.2 Kişisel çıkar (danışman `a` için)
`S_a(fx) = fx.actors[a].power + 0.6·Σ l_* + 0.5·obligation − 0.6·fear + 3·[a ∈ fact.knowers]·(a.ambition/50) − 40·[a ∈ remove] + 12·[promise_keep kendi sözü] − 15·[promise_break kendi sözü] − 0.25·Σ_rakip(power artışı)`
Rakip = diğer `insider` aktörler.

### 5.3 Danışmanın gözündeki puan
```
P_a(c) = V(c) + N(0, σ_a)                   σ_a = σ_base · (1 − yetkinlik) · zorluk_gürültüsü
puan_a(c) = k_a · P_a(c) + w_a · S_a(c)
w_a = clamp(W0 + (ambition/100) · (1 − honesty) · W1, 0, W_max)
k_a = 1, hazır (ready) ise K_READY
```
`öneri = argmax puan`, `uyarı = argmin puan` (yalnızca `max−min ≥ WARN_GAP` ise söylenir).
`max−min < FLAT_GAP` ise danışman "fark etmez" der.
Kaçamak: `a.fear ≥ FEAR_EVASIVE` ya da `echo_level() > 0.75` ise öneri yok, "takdir sizindir" cümlesi (yankı odası sinyali).

### 5.4 Yetkinlik ve uzmanlık
Olayın boyut ağırlıkları: tüm seçeneklerde `|katkı|` toplamı (katkı = 5.1'deki terimler). Baskın boyut → uzman:
| Boyut | Birincil | İkincil |
|---|---|---|
| economy, wealth | kessler | halden |
| unrest | arden | halden |
| opp | voss | halden |
| fact (kral hakkında iz) | falk | voss |
| king | dorn | prens |
| actors (kişi güçlenmesi) | voss | dorn |
`yetkinlik = YETKIN_UZMAN` danışmanın uzman olduğu boyut baskınsa, aksi hâlde `YETKIN_GENEL`.

### 5.5 Parametreler
| Ad | Varsayılan | Aralık | Not |
|---|---|---|---|
| σ_base (`ADVICE_SIGMA`) | 10.0 | 6–12 | |
| YETKIN_UZMAN / İKİNCİL / GENEL | 0.5 / 0.35 / 0.15 | | σ: uzman 5, ikincil 6,5, genel 8,5 |
| W0 / W1 / W_max | 0.4 / 6.0 / 2.0 | | Falk≈0.46, Kessler≈0.7, Arden≈1.1, Dorn≈1.1, Prens≈1.5, Voss≈2.0, Halden≈2.0 |
| ADVICE_LOYALTY_VALUE | 0.3 | | V'deki sadakat değeri |
| K_READY | −0.4 | −1…0 | hazır aktör kralın zararına çeker |
| FEAR_EVASIVE | 60 | 50–70 | korku sistemiyle (şantaj, bastırma) bağ |
| WARN_GAP | 6.0 | | |
| FLAT_GAP | 1.5 | | |
| MISLEAD_GAP | 4.0 | | oyun sonu "yanılttı" sayımı: V(en iyi) − V(öneri) ≥ bu |
| STAKE_MIN | 1.0 | | "ÇIKARI VAR" için en küçük doğrudan pay |
| zorluk_gürültüsü | Kolay 0.8 · Normal 1.0 · Zor 1.25 | | `DIFFICULTY[*].advice_noise` |
Her kampanyada dürüstlük ve hırs zaten ±rastgele; w_a bu sayede kampanyadan kampanyaya değişir (kim güvenilir sorusu ezberlenemez).

## 6. Bilgi tasarımı
- **Sayı yok, yön var.** Görüş cümlesi seçeneği Roma rakamıyla anar ve tek bir **gerekçe** söyler: önerilen seçeneğin kral için
  en olumlu gerçek etkisi ("sokak sakinleşir"). Uyarıda en olumsuz gerçek etki ("muhalefete koz verir").
- **Seçici doğruluk:** Danışman gerekçede yalan söylemez; **seçerek** doğru söyler. Kişisel çıkarla önerdiği seçeneğin
  bedelini anmaz. Önerdiği seçeneğin kral için hiçbir olumlu tarafı yoksa kendi alanına özgü bir **kılıf cümlesi** kurar
  ("Ordu güçlüyse taht da güçlüdür") — dikkatli oyuncu için bir ele veriş.
- **ÇIKARI VAR etiketi:** Seçeneklerden en az biri danışmanı doğrudan etkiliyorsa (|doğrudan pay| ≥ STAKE_MIN) adının yanında küçük amber etiket.
  İpucu: "Seçeneklerden en az biri onu doğrudan etkiliyor. Önerisi tarafsız olmayabilir."
- **Düğme ipucu:** Her seçenek düğmesinin tooltip'inde o seçenek hakkında kim ne dedi ("Kessler: öneriyor · Arden: karşı").
- **Kaçamak cümle** (yankı odası): "Takdir sizindir, Majesteleri." İki danışman da kaçamaksa bu, korkunun meclisi susturduğunun işaretidir.
- **Gerçeğin açığa çıkması:** Oyun sonu Hakikat Dosyası'nda **Meclis Sicili**: her danışman için verdiği öneri sayısı, kaçında
  dinlediğin, kaçında seni yanılttığı (MISLEAD_GAP) ve en pahalı yanıltma örneği. Oyun içinde doğrudan doğruluk gösterilmez.

## 7. Etkileşimler
| Sistem | Girdi (danışmana) | Çıktı (danışmandan) |
|---|---|---|
| Kaskad/darbe | `ready` → K_READY ile kötü öneri | Oyuncu çelişkiden şüphelenip araştır/doğrula yapar |
| Korku/şantaj | `fear` yüksek → kaçamak | Korku politikasının gizli bedeli: meclis susar |
| Raporlar/karne | Dürüstlük hem raporu hem öneriyi büker | Karne, öneriye güven için de kullanılır (tek "güvenilirlik" dili) |
| Sözler | Kendi sözünün tutulması/bozulması S_a'da | Söz kartlarında alacaklı tarafın görüşü beklenen şekilde taraflı |
| Sırlar | `fact.knowers` olmak hırslı danışmanı cezbeder | İz bırakan seçenekler hırslılarca desteklenebilir |
| Görevden alma | Danışman havuzu daralır | Uzman yoksa ikincil uzman (genelde Halden) konuşur |
| Olaylar | Yeni şema alanı gerekmez | İsteğe bağlı `advisors: ["kessler", …]` ile elle seçim (yalnızca özel olaylar) |

## 8. İçerik ihtiyacı
- Gerekçe cümleleri (`ADVICE_REASONS`, her boyut×yön için 2–3 söyleyiş) ve kılıf cümleleri (`ADVICE_COVER`, danışman başına 1–2).
- Kaçamak ve "fark etmez" cümleleri (2–3'er).
- Yeni olay ya da görsel gerekmez. Portreler mevcut `_initial_art`.

## 9. Arayüz
Kartta açıklama metninin altına, seçeneklerin üstüne **MECLİSİN GÖRÜŞÜ** bloğu (ince ayraç, 2 satır):
```
[portre 28] KESSLER  (Maliye)          "II, Majesteleri. Hazine nefes alır. III ise bütçeyi deler."
[portre 28] ARDEN  ÇIKARI VAR          "I. Meydanlar boşalır."
```
- Ad: altın caps; etiket: turuncu küçük caps; cümle: italik serif, açık krem. Mobilde portre 24, cümle alt satıra.
- Düğme tooltip'i: mevcut mesai metni + boş satır + görüş özeti.
- Ayrıntılı yerleşim ve durumlar için ux-design'a gerek yok; mevcut kart içinde küçük bir blok.

## 10. İstismarlar ve uç durumlar
- **"Hep Kessler'e uy":** Kessler yalnızca ekonomi baskın olaylarda uzman; başka alanlarda σ büyük. Ölçülür (bot `follow_honest`).
- **Kaydet/yükle ile görüş yenileme:** Görüş `pending` içinde kalıcı; yeniden üretilmez.
- **Danışman görevden alındı / düşman oldu (kart beklerken):** Görüş gizlenir; yerine yeni danışman üretilmez (meclis eksik konuşur).
- **İki seçenekli kart, tüm seçenekler eşit:** "Fark etmez" cümlesi.
- **Ertelenen kart:** Görüş sabit.
- **Eski kayıt (advice alanı yok):** Tembel üretim nedeniyle sorunsuz; `advice_log` yoksa boş dizi.
- **Performans:** Kart başına en çok 9 aktör × 3 seçenek; ihmal edilebilir. `_rebuild_agenda` her çağrıda önbellekten okur.

## 11. Denge hedefleri ve ölçülen sonuç
Hedef (Normal): görüşsüz oyun değişmesin; görüşleri tartan oyuncu %35–55; tavanın altında kalsın; tartmak körü körüne uymaktan kötü olmasın.

Ölçüm (`probe_template`, 80 kampanya, son parametreler):
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible (görüşsüz, rastgele karar) | %55 | %16 | %10 |
| advice_naive (ilk danışmana uyar) | %91 | %52 | %30 |
| advice_weighted (oyları tartar) | %86 | %58 | %26 |
| advice_kessler (Kessler'e uyar) | %78 | %52 | %22 |
| visible_wise (gerçek etkiyi okur, tavan) | %100 | %95 | %60 |

Öneri kalitesi (Normal, 40 kampanya; V kaybı = en iyi seçenek − önerilen): tarafsız 1,3 · taraf olan 2,5 · darbeye hazır 3,8–7,1.
- Görüşsüz oyun birebir aynı (ana rng'ye dokunulmuyor) ✔
- Normal'de danışmanı dinleyen oyuncu ~%55: hedefin üst sınırında. Zorluk genel olarak kolaylaştı; Faz 2 denge çalışmasında
  zorluk eğrisi yeniden ele alınmalı (ör. Normal'de `coup_share`/`ready_drive`).
- naive ile weighted farkı gürültü içinde (±5 puan). Sebep: taraf olan danışmanın çıkarı çoğu zaman **sadakat** (kariyer) yönünde,
  bu da kral için gerçekten iyi. Tarafgirliğin asıl zararı güç artışında. Bu, sistemin bir hatası değil; "satın alınan sadakat" ilkesinin
  bir yansıması. Ayırt edici beceri, "ÇIKARI VAR"dan çok çelişkiyi ve hazır aktörün kötü önerisini fark etmekte.
- Kaçamak görüş (yankı odası) bot oyunlarında neredeyse hiç tetiklenmiyor (korku ≥ 60 nadir); korku politikası izleyen oyuncuda görünür.

## 12. Uygulama planı
1. `sim.gd`: `choice_value(fx)`, `_self_interest(a, fx)`, `_event_dims(e)`, `_pick_advisors(e)`, `advice_for(pi)` (tembel, önbellekli),
   `ADVICE_*` sabitleri, `DIFFICULTY[*].advice_noise`. `resolve_decision` → `advice_log`'a işleme. `new_game`/`save_game`/`load_game`: `advice_log`.
2. `sim.gd` `_end`: `record["council"]` = meclis sicili özeti.
3. `main.gd` karar kartı: MECLİSİN GÖRÜŞÜ bloğu + düğme tooltip'i; oyun sonu Hakikat sekmesine Meclis Sicili.
4. `probe_template.gd`: `advice_naive`, `advice_weighted` botları; `visible_wise` → `sim.choice_value`.
5. `sim_test.gd`: görüşlerin deterministik olduğu, kayıt/yüklemede korunduğu, hazır aktörün daha kötü önerdiği (istatistiksel) testleri.
6. Ölçüm → parametre ayarı → ekran görüntüsü (masaüstü + mobil) → belgeler (`VELORIA.md`, `OYUNCU_REHBERI.md`, devir notu) → commit.

## 13. Açık sorular (varsayılanla ilerleniyor)
1. **Üçüncü görüş satın alma** ("Başka birine sor", 1 mesai): Şimdilik yok (gereksiz düğme riski). Oyuncu testinden sonra değerlendirilir.
2. **Oyun içi doğruluk geri bildirimi:** Şimdilik yalnızca oyun sonunda. İleride gecikmeli olaylar "Voss'un önerisi pahalıya patladı" diyebilir.
3. **ÇIKARI VAR etiketi açık mı, sezdirme mi?** Okunabilirlik için açık. Oyun fazla kolaylaşırsa yalnızca Araştır'dan sonra gösterilebilir.

## 14. Uygulama sırasında değişenler
- **V'ye sadakat eklendi.** İlk ölçümde "ilk danışmana uy" botu, gürültü ve çıkar ağırlığı ne olursa olsun %60 civarında kaldı.
  Sebep, `V`'nin sadakat artışını saymamasıydı. Oysa `rebellion_drive` sadakatle azalıyor; taraf olan danışman kendi sadakatini artıran
  seçeneği önerdiğinde krala gerçekten iyilik ediyordu. Sadakat terimi eklenince `visible_wise` %80'den %95'e çıktı. Bu, eski formülün
  eksik olduğunu doğruladı.
- **Yetkinlik düşürüldü** (0.85/0.5 → 0.5/0.35/0.15). İlk sürümde tarafsız uzmanın ortalama kaybı 0,23'tü; bu bir kâhin olur, yanılabilir danışman olmaz.
- **Çıkar ağırlığı artırıldı** (W0 0.15→0.4, W1 2→6, W_max 1.2→2.0). "ÇIKARI VAR" ancak bu ağırlıkla anlamlı bir uyarı oluyor.
- **Danışman kendinden söz etmez.** Gerekçe parçalarından danışmanın kendi kişi terimi çıkarıldı ("Arden'i fazla güçlendirir" diyen Arden).
- Dilbilgisi: `Sim.ek(isim, "i")` (belirtme hâli: Voss'u, Arden'i, Lena'yı) eklendi.
