# Faz 4 — Devlet Kapasitesi, Bütçe ve Patronaj/Oligark

Durum: **tasarım (kodlanmadı)**. Tarih: 2026-10-07. Kaynak: Tasarım Özeti §6 (saray hazinesi ve kişisel servet), §17 (patronaj ve oligark), §24 (devlet kapasitesi). Yol haritası: `docs/YOL_HARITASI.md` Faz 4.

Belge üç parçadır ve bu sırayla uygulanır: **4a Devlet kapasitesi ve kasa**, **4b Patronaj ve oligark**, **4c Bağlama** (rejim, oyun sonu, başarımlar). 4a tek başına çalışır ve ölçülebilir; 4b, 4a'nın kasa/kapasite alanlarına yaslanır.

---

## 1. Amaç ve oyuncu fantezisi

Oyun şimdiye kadar "tahtta kalmak" üzerine kurulu ve iki hikâyeyi anlatamıyor:

1. **"Tahtını kurtarırken ülkeyi yönetilemez hâle getirdim."** (§24) Bugün oyuncu hiçbir şeyin bedelini devletin işleyişiyle ödemiyor. Ekonomi sabit bir rastgele yürüyüş, kral gücü 40. haftadan sonra ~%95–100'e doyuyor; yani "güçlü kral" ucuz. Sadık ama yetersiz bir bakan atamak ya da bağımsız savcıyı göndermek hiçbir kalıcı iz bırakmıyor.
2. **"Satın aldığım sadakat beni satın aldı."** (§17) Halden'in ihale/medya hikâyesi şu an yalnızca elle yazılmış olay zincirleri (`halden_ihale`, `halden_fatura`, `yay_halden_*`). Oyuncu ihale verip vermemeyi seçemiyor, medyaya ne kadar muhtaç olduğunu bilmiyor ve para (kişisel servet) hiçbir yerden kazanılmıyor.

**Fantezi:** "Elimdeki her kısayol bir devlet kurumunu aşındırıyor; ne kadar hızlı kurtulursam o kadar çabuk batıyorum ve bir gün bu hesabı biri bana çıkaracak."

Gerilim iki eksende: **güvenlik ↔ liyakat** (kurumlar) ve **kolaylık ↔ bağımlılık** (oligark). İkisi de gizli durumdur; oyuncu bunları rakamla değil, raporlardan, sonuçlardan ve sızıntılardan sezer.

---

## 2. Mevcut durum

### Kod (formüller olduğu gibi)
| Ne | Nerede | Şu an |
|---|---|---|
| Ekonomi | `sim.gd:1187` | `economy += rand(-2.5, 2.8) - unrest*0.02 + (55-economy)*0.03`: ortalamaya dönen rastgele yürüyüş; tek kol olaylar |
| Kral gücü | `sim.gd:1188` | `king -= unrest*0.012 + opp*0.004; += (economy-50)*0.01 + 0.4` |
| Kişisel servet | `sim.gd:1189` | `+= _diff("income")` (Kolay 1,2 / Normal 1,0 / Zor 0,8 haftada). **Başka kaynağı yok.** Harcama: Gizli Ödeme `BRIBE_COST=5.0` (`sim.gd:411`), olay maliyetleri, "Liman İhalesi" sözü +4 (`sim.gd:847`) |
| Yargı baskısı | `sim.gd:1917` | kralla ilgili sırların şiddet toplamı; kamuya açıldıkça ağırlık artar; `/2.4 − legal_relief` |
| Rapor gürültüsü | `sim.gd:2178` | `rand(-6, 6) * (1 - honesty*0.5)` |
| Emir uygulanması | `sim.gd:435` | `fidelity` kanala ve kırmızı çizgiye bağlı |
| Kurum başkanları | `actors.json` | Kessler (maliye), Falk (yargı), Arden (ordu), Dorn (kâhya), Voss (istihbarat), Halden (medya/oligark). **Yetkinlik alanı yok**; yalnızca güç, hırs, dürüstlük, sadakat |

### Ölçüm (2026-10-07, Normal, 60 kampanya, `advice_weighted` / `visible_wise`)
| Hafta | Ekonomi | Kişisel servet | Kral gücü (aw / vw) |
|---|---|---|---|
| 0–12 | 52 | 3 | 63 / 66 |
| 26–38 | 47 | 3 | 78 / 89 |
| 52–64 | 47 | 3 | 97 / 100 |
| 91–103 | 48 | 3 | 96 / 99 |

**Çıkarımlar:** (1) Ekonomi oyuncu için fiilen dekor; (2) servet hep ~3: gelir her hafta harcanıyor, birikim ya da kaynak kararı yok; (3) kral gücü 52. haftadan sonra doymuş, yani "daha da güçlen" kararı anlamsız; trajedi (§24) için gereken gerilim yok.

### Tasarım özeti ile fark
§6 devlet bütçesi ve kişisel serveti ayırır, "para kanıt üretir" der: kişisel servetin **kaynağı** siyasi risk olmalı. Kodda kaynak sabit maaş; kanıt yalnızca harcamada doğuyor. §17 oligarkın büyümesini, medya bağımlılığını ve tehdidi ister: kodda yalnızca betik. §24 kurumların bedelini ister: kodda hiç yok.

---

## 3. Oyuncu kararları

| Karar | Seçenekler | Kısa vadeli kazanç | Uzun vadeli bedel |
|---|---|---|---|
| **Kadro** (4a) | Sadık Ata / Liyakatli Ata, bir kurum başkanına | Sadık: başkan bağlanır (darbe/ihanet riski düşer) | Kapasite düşer, kurum işlemez; liyakatli: kapasite yükselir ama başkan hırslanır, bağımsızlaşır |
| **Çeyrek bütçe** (4a) | Sıkı / Dengeli / Cömert / Saray payı | Sıkı: kasa dolar; cömert: huzursuzluk düşer, kurumlar nefes alır; saray payı: kişisel servet | Sıkı: kurumlar yıpranır, sokak kızar; cömert: kasa erir, borç krizi; saray payı: iz, kasa erir |
| **İhale Ver** (4b) | Halden'e ihale (3 hafta bekleme) | Komisyon (servet), ekonomi kıpırtısı, Halden'in medya desteği | Halden büyür (bağımlılık), kasa ve maliye kapasitesi aşınır, iz bırakır |
| **Halden'in talebi** (4b) | Ver / Reddet / Rakip yayın kur / Savcılığa başvur | Ver: huzur; Reddet: bağımsızlık | Ver: fiyat artar; Reddet: düşman yayın + sızıntı tehdidi; Rakip: servet; Savcılık: Falk'a ve hukuk kapasitesine bağlı |
| **Mevcut kararlar** | Bastır, terfi, görevden al | — | Her biri artık kurum kapasitesine dokunur (bkz. §4.3) |

Hiçbir kararın "doğru" cevabı yok: sadıklarla kuşatılan kral darbeden korunur ama sınırda ordu hazırlıksız çıkar; liyakatli kral devleti işletir ama Arden'in hırsı yükselir.

---

## 4. Kurallar ve durum

### 4.1 Yeni durum alanları (hepsi gizli)
| Alan | Aralık | Başlangıç | Anlamı |
|---|---|---|---|
| `capacity.maliye / hukuk / ordu / idare` | 5–100 | 55 ±5 (kampanya başına) | kurumların fiilî işleyişi |
| `treasury` | 0–100 | 55 | devlet kasası (kişisel servetten ayrı) |
| `budget_stance` | −1 / 0 / +1 | 0 | son çeyrek bütçe kararı (sıkı / dengeli / cömert) |
| `court_share` | bool | false | saray payı seçildi mi (bir sonraki karta kadar) |
| `holding` | 0–100 | 40 | Halden'in şirket imparatorluğunun büyüklüğü |
| `halden_hostile_until` | hafta | 0 | Halden'in düşman yayın yaptığı son hafta |
| `halden_demands` | sayı | 0 | verilen/karşılanan talep sayısı (fiyat seviyesi `L`) |
| `lena_boost_until` | hafta | 0 | bağımsız yayına destek süresi |
| `kadro_log` | liste | boş | {hafta, kurum, tür} (oyun sonu) |
| `capacity_timeline` | liste | boş | haftalık kapasite kaydı (Hakikat Dosyası grafiği) |

Başlangıç kapasitesi kampanya başına ±5 oynar; **ana `rng` tüketilmez**, tohumdan türeyen ayrı bir üreteç kullanılır (meclis görüşlerindeki kalıp), böylece eski tohumların diğer akışları değişmez.

### 4.2 Haftalık sıra (`end_week` içindeki yeri)
`_world_tick` sonunda, ekonomi ve kral gücü güncellemesinden **sonra**: kapasite yıpranması ve bütçe etkisi → kasa → patronaj (holding, medya etkisi). Sonra mevcut `_decay_facts`, `_fire_events`, ... sırası değişmez. Sistem kartları (çeyrek bütçe, Halden talebi) `_fire_events` sonunda kriz kartlarıyla aynı yoldan `pending`'e girer; haftalık karar sınırına (en çok 2 yeni, bekleyen en çok 3) **sayılmaz** ama bekleyen sınırına sayılır.

### 4.3 Kurumlar (4a)
| Kurum | Başkan | Kapasite neye yarar |
|---|---|---|
| maliye | Kessler | ekonomi, kasa, vergi |
| hukuk | Falk | yargı baskısının şiddeti, suç/yolsuzluk, savcılık başvurusu başarısı |
| ordu | Arden | sınır/savaş olayları, sokağa sürme ve darbe bastırma başarısı |
| idare | Dorn | emirlerin uygulanması, rapor kalitesi |

**Yıpranma:** her hafta her kurum `−ATTRITION`. Yatırılmayan devlet çürür.
**Mevcut eylemlerin etkisi (tek tek, küçük):** Terfi (kurum başkanına): kapasite −1 (kayırma). Görevden Al (başkan): kapasite −12 bir kerelik (bilgi kaybı), 6 hafta sonra yeni başkan gelmiş sayılır ve kapasite +5 geri döner. Yazılı Emir / Bastır: ordu kapasitesi −0,5 (gönülsüz uygulama). Doğrula (Cross-check): bir kurum başkanında gürültülü gerçek okuma (§6).
**Kadro eylemleri** (1 mesai, aynı kurum için 8 hafta bekleme, hedef: Kessler, Falk, Arden veya Dorn):
- **Sadık Ata:** başkanın `l_career +8`, `ambition −3`, `obligation +3`; kurum kapasitesi `−8`.
- **Liyakatli Ata:** kurum kapasitesi `+7`; başkanın `ambition +3`, `l_career −3`, `obligation −2`.

**Kapasitenin sonuçları (sürekli):** formüller §5'te. **Eşik sonuçları (olaylar):** kapasite çok düşünce kurumun başarısız olduğu olay kartları (§8).

### 4.4 Kasa ve bütçe (4a)
- Kasa her hafta gelir/gider dengesiyle oynar (formül §5).
- **Çeyrek bütçe kartı** 13., 26., 39., 52., 65., 78., 91. haftalarda gelir (4 seçenek, bkz. §3). Seçim `budget_stance`'ı ve `court_share`'i bir sonraki karta kadar kalıcı yapar; etkisi haftalık akar (bir kerelik şok yok).
- **Kasa eşikleri:** `treasury < 30` bir kez "MALİYE:" uyarısı (haber şeridi + özet); `< 15` ve kapasite düşükse **"Maaşlar ödenemiyor"** olayı (3 seçenek: borç al, ordu maaşını öne al, kemer). Çözülmezse ordu kapasitesi −10, Arden hırsı +8 (darbe hesabına bağlanır, ayrı bir kayıp türü oluşturmaz). `> 80` bir kez "Beklenmedik fazla" kartı.
- **Kişisel servet kaynakları (yeni):** sivil liste (mevcut), saray payı (+0,6/hafta çeyrek boyunca, kasadan −0,6), ihale komisyonu (4b). Kişisel servet kasaya **geri akmaz**; kasadan servete akış tek yönlüdür ve her zaman iz bırakır.

### 4.5 Patronaj ve oligark (4b)
Tek oligark: **Halden**. (Birden çok iş insanı açık soru, §13.)
- **Büyüme:** `holding += 0,12 + halden.power/500` haftalık (organik, +%30 civarı bir oyun boyunca); İhale Ver +10; rekabet/soruşturma eksiltir.
- **İhale Ver** (KAZAN/DEVLET sekmesi, 1 mesai, 3 hafta bekleme, hedef Halden, `moved` değilse):
  - `holding +10`, `private_wealth +6`, `treasury −3`, `economy +1`, `capacity.maliye −2`;
  - Halden: `power +3`, `l_money +6`;
  - iz: "ihale komisyonu" sırrı (şiddet 18, bilenler Halden ve Kessler, sızma 0,5).
- **Medya etkisi (§17: "oligarkın medyasına muhtaç"):** Halden'in havası üç durum: **sıcak** (düşman değil ve sadakati ≥ 25), **mesafeli**, **düşmanca** (`week < halden_hostile_until` ya da `moved`). Haftalık: `unrest −= 0,6 × holding/100` sıcakken, `+=` düşmancayken; `king_strength ±= 0,25 × holding/100`. Büyüdükçe hem desteği hem tehdidi büyür.
- **Medya bağımlılığı** (türetilmiş, saklanmaz): `D = clamp(0,6·holding + 20 (Halden devlet gazetesinin sahibiyse) − 15 (Serbest Kalem açıksa) − 8 (lena_boost_until içindeyse), 0, 100)`.
- **Halden'in talebi** kartı: `holding` eşiklerini (40, 55, 70, 85) geçince ya da son talepten 12 hafta geçip `D ≥ 50` iken, en erken 8 hafta aralıkla. Fiyat seviyesi `L = halden_demands`.
  1. **Ver:** `holding +10+2L`, `wealth +3`, `treasury −(3+L)`, sır (şiddet `18+2L`), 10 hafta sıcak.
  2. **Reddet:** `halden_hostile_until = week + 6 + 2L`, Halden `ambition +8`, `unrest +2`; Halden'in bildiği sırların `common`'ı +0,25 (sızıntı tehdidi).
  3. **Rakip yayın kur** (Lena açıksa): `wealth −6`, 12 hafta bağımlılık −8, Lena `power +6`, Halden `ambition +4`.
  4. **Savcılığa başvur** (Falk açıksa): başarı olasılığı `clamp(0,25 + (capacity.hukuk − 40)/100 − holding/250, 0,10, 0,75)`. Başarıda `holding −25`, Halden `fear +15`, `ambition +6`; başarısızlıkta 8 hafta düşman yayın ve "soruşturmanın sızması" sırrı (şiddet 25).
- **Halden `moved` olursa** (düşman): İhale Ver kapanır, `holding −0,5/hafta` erir, medya etkisi sürekli düşmancadır.
- **Mevcut betikli olaylar** (`halden_ihale`, `halden_fatura`, `halden_kanal`, `halden_parti`, `halden_imparatorluk`, `halden_meclis`, `yay_halden_*`): **silinmez**; sistemle çelişenler (`halden_ihale`, `halden_fatura`) talep kartının seçenekleri aynı bayrakları yazacak şekilde (`halden_ihale_0` vb.) birleştirilir; böylece rejim hesabı ve Faz 3 yayları bozulmaz. `halden_imparatorluk` ve `halden_meclis` `min_holding` koşuluyla sistemin doruk olayları olur.

---

## 5. Formüller ve parametreler

Başlangıç değerleri **öneridir**; hedef, kapasite/kasa/holding hiç kullanılmadığında mevcut bot ölçümlerinin (Kolay %83, Normal %45, Zor %16) ±3 puan içinde kalmasıdır.

### Sürekli etkiler (haftalık)
```
cap_i       -= ATTRITION                                  (her kurum)
cap_i       += budget_stance * STANCE_CAP                 (hepsi)
cap_hepsi   clamp [5, 100]

economy     += (cap_maliye - 55) * 0.015
            +  (cap_hukuk  - 55) * 0.005
            +  budget_stance * 0.08
treasury    += (economy - 50) * 0.05
            +  (cap_maliye - 55) * 0.03
            -  TREASURY_COST
            -  budget_stance * 0.9
            -  (0.6 if court_share else 0)
            [clamp 0..100]
unrest      += (55 - cap_hukuk) * 0.01  (cap_hukuk < 55 iken)
            -  budget_stance * 0.15
            ∓  0.6 * holding/100        (Halden sıcak: -, düşmanca: +)
king        += ∓ 0.25 * holding/100
private_wealth += 0.6 (court_share iken)

legal_pressure() = (mevcut formül) * (1 + (cap_hukuk - 55) / 100)

other_chance("force")  += (cap_ordu - 55) / 250
crisis_chance("rally") += (cap_ordu - 55) / 400

emir fidelity          *= 0.85 + cap_idare / 370            (cap 55 -> 1.0)
rapor gürültüsü        *= 1 + (55 - cap_idare) / 110        (cap 55 -> 1.0, cap 20 -> 1.32)
Kessler raporunun "ekonomi" gerçeği = 0.7*economy + 0.3*treasury
```
### Parametreler
| Ad | Varsayılan | Aralık | Kolay / Normal / Zor çarpanı |
|---|---|---|---|
| `ATTRITION` | 0,08 | 0,04–0,15 | 0,7 / 1,0 / 1,2 |
| `STANCE_CAP` | 0,23 | 0,1–0,4 | 1,0 |
| `TREASURY_COST` | 0,15 | 0,05–0,4 | 0,8 / 1,0 / 1,2 |
| ihale komisyonu | 6 | 3–10 | 1,2 / 1,0 / 0,8 |
| kadro bekleme | 8 hafta | 6–12 | 1,0 |
| ihale bekleme | 3 hafta | 2–5 | 1,0 |
| talep aralığı | ≥ 8 hafta | 6–12 | 1,0 / 1,0 / 0,8 |

---

## 6. Bilgi tasarımı

Sayı yok. Dört gizli büyüklük, farklı gürültüyle ve farklı yerden görünür:

| Büyüklük | Nereden görünür | Gürültü ve yalan |
|---|---|---|
| **Kurum kapasitesi** | Başkent haritasında kurum panelinde **"İşleyiş: aksıyor / yürüyor / sağlam"**; rapor cümleleri; eşik haberleri ("ADLİYE: Savcılıkta boşalan kadrolar doldurulmuyor"); eşik olayları | Görünen değer `cap + flattery(başkan)*20 + gürültü`: korkak ya da dürüst olmayan başkan iyimser gösterir. **Doğrula** (cross-check) 6 hafta gürültüsüz bant verir |
| **Kasa** | Kessler'in raporu (ekonomi gerçeğinin %30'u kasadır); "MALİYE:" uyarıları; Maliye panelinde "Kasa: dolu / dengeli / sıkışık"; maaş krizi | Kessler dürüst (0,8) ama korkarsa süsler |
| **Halden'in büyüklüğü ve havası** | Kişi kartında iki gösterge: **"Nüfuz: sınırlı / yaygın / her yerde"** ve **"Medya: sıcak / mesafeli / düşmanca"**; talep kartının metni ("Gazeteleri de ona bağlı, kanalı ona bağlı..."); TV ve gazete başlıkları (düşmancadayken hükümet eleştirilir) | Halden dürüst değil (0,4); nüfuzu olduğundan küçük gösterir (kendi çıkarı) |
| **Bağımlılık `D`** | Hiçbir göstergede; yalnızca Halden talebinin metninde ve **Dorn'un meclis görüşünde** ("Gazeteler ona bağlı, Majesteleri") | Dorn kapıdaki haberi saklayabilir |

**Hakikat Dosyası (oyun sonu):** grafiğe iki yeni çizgi: **devlet kapasitesi (ortalama)** ve **Halden'in payı**; yeni bölüm **"DEVLET DEFTERİ — ne pahasına"**: kadro günlüğü (hangi kurumda kimi sadık atadın), kapasitenin en düşük anı ve o anki olay, ihale sayısı, Halden'in tehdit ettiği haftalar.

---

## 7. Etkileşimler

| Sistem | Giriş (bu sistemden ona) | Çıkış (ondan buna) |
|---|---|---|
| Sırlar / ortak bilgi | İhale komisyonu ve saray payı sır doğurur | Yargı baskısı hukuk kapasitesiyle çarpılır |
| Kaskad / darbe | Sadık Ata başkanın isyan eğilimini düşürür; liyakatli yükseltir; kasa krizi Arden hırsını artırır | Darbe sonrası kurum kapasitesi düşer |
| Kriz sistemi | Ordu kapasitesi sokağa sürme/bastırma olasılığını oynatır | Ayaklanma ve yetki krizleri maliye/hukuk kapasitesine yapışır |
| Sözler | "Liman İhalesi" sözünün komisyonu holding'e bağlanır | Söz bozmak Halden'i düşmanlaştırır |
| Raporlar | `idare` gürültüyü, `maliye` ekonomi gerçeğini değiştirir | Kapasite panelleri aynı yalan süzgecinden geçer |
| Basın / medya | Halden'in havası gazete ve TV başlıklarını belirler | Düşman yayın huzursuzluğu besler |
| Rejim (Faz 3) | `oligark += holding/12`; `patronajci += sadık atama sayısı`; `guvenlikci += ordu sadık ataması ×2` | Rejim tipi kapasite eşikleriyle çakışan hesaplaşma seçer (ör. oligark rejiminde kasa sızıntısı) |
| Aktör hamleleri | Kessler, Halden, Falk hamleleri kapasite/holding'e küçük değer yazabilir | — |
| Meclis görüşleri | `choice_value` (tek kaynak) kasa, kapasite ve holding terimleri kazanır | Kartlar (bütçe, talep) danışman görüşü taşır |
| Başarımlar / unvanlar | Yeni başarımlar ve "Harap Devletin Kralı" gibi unvanlar (§4c) | — |

`choice_value` genişlemesi (danışmanlar ve botlar bütçe kartını anlasın diye): `treasury ×0,25`, `capacity (her kurum) ×0,3`, `holding ×−0,1`.

---

## 8. İçerik ihtiyacı

**Sistem kartları (kodla kurulur, JSON'da metin):** `ceyrek_butce` (7 çeyrek, 4 seçenek, metin Kessler'in kasa değerlendirmesini taşır), `halden_talep` (4 seçenek, fiyat seviyesine göre 3 metin kademesi).

**Yeni olaylar (~16, `events.json`; yeni koşullar §12'de):**
| Id | Koşul | Fikir |
|---|---|---|
| `kasa_bos` | `max_treasury 15` | Maaşlar ödenemiyor: borç / ordu önce / kemer |
| `kasa_fazla` | `min_treasury 80`, tekrar | Beklenmedik fazla: yatırım / halka dağıt / sakla (servete aktarmak = iz) |
| `maliye_cokus` | `max_cap maliye 30` | Bakanlık vergi toplayamıyor |
| `adliye_cokus` | `max_cap hukuk 30` | Davalar yıllarca sürüyor; mahkemeler satılık |
| `idare_cokus` | `max_cap idare 30` | Emirler valiliklere ulaşmıyor |
| `ordu_zayif_sinir` | `max_cap ordu 40`, hafta ≥ 22 | `sinir_krizi`'nin hazırlıksız ordu varyantı (aynı bayrak adları); orijinal `min_cap ordu 41` ister |
| `ordu_zayif_sinir_ikinci` | aynı, hafta ≥ 66 | `sinir_ikinci` varyantı |
| `uzman_bakan` | `min_cap maliye 75` | Liyakatin ödülü: bir ekonomi atılımı |
| `sadik_komutan_sinav` | `min_stat sadik_ordu 1`, `flag_age` | Sadık atanan komutan ilk sınavda çuvallar |
| `liyakatli_savci` | `min_cap hukuk 70` ve `liyakatli_hukuk` bayrağı | Bağımsız savcı kralın sırrına yaklaşır |
| `kadro_ihaneti` | liyakatli atanan başkanın hırsı ≥ 60 | Liyakatli bakan kendi çizgisini çiziyor |
| `halden_yayin_kesti` | Halden düşmanca, `min_holding 60` | Tüm kanallar aynı anda hükümeti hedef alıyor |
| `ihale_sorusturmasi_sizinti` | savcılık başvurusu başarısız | Sızıntı |
| `holding_devrildi` | `moved` ve `holding` yüksek | Halden düşman olunca şirketlerine el koyma seçeneği (açık soru §13) |
| `saray_payi_sizdi` | `court_share` 2 çeyrek üst üste | Servetin kaynağı gazetede |
| `kurum_sessiz_cokus` | iki kurum `< 35` | "Devlet işlemiyor": tek kart, sonuçlar kümelenir |

**Rapor cümleleri** (`game/data/content_reports.json` biçimi; yeni alan `state`): kurum × bant × 3 söyleniş. Örnek:
- hukuk/aksıyor: *"Mahkemelerde dosyalar kuruyor; yargıçlar karar yazmaktan çekiniyor."*
- hukuk/sağlam: *"Savcılık dosyaları takvimine uygun ilerliyor."*
- idare/aksıyor: *"Valiliklere gönderilen emirler haftalarca masalarda bekliyor."*
- ordu/yürüyor: *"Kışlalarda mühimmat sayımı geç kaldı; subaylar bütçeyi soruyor."*
- maliye/sağlam: *"Vergi tahsilatı beklentinin üstünde; hazine nefes alıyor."*
- maliye/aksıyor: *"Kasa saat saat eriyor; maaşlar için ek kaynak aranıyor."*

**Görsel:** Başkent haritasına "Maliye Bakanlığı" isim plakası (`city_map.json`, yeni konum; harita görseli aynı); yeni olaylar için mevcut görsellere eşleme, yaklaşık eşleşmeler `ART_PROMPTS.md`'ye prompt olarak yazılır.

---

## 9. Arayüz (ux-design'a devredilecek noktalar)

- **Yeni eylem sekmesi "DEVLET"** (7. kategori): *İhale Ver*, *Sadık Ata*, *Liyakatli Ata*. Mobilde sekme sığmazsa KAZAN'a alt satır. Önizleme (`ACTION_META`): iz ve risk satırı; "Sadık Ata" ipucu: "Başkanı bağlar; kurumu zayıflatır."
- **Başkent haritası kurum panelleri:** Adliye (hukuk), Genelkurmay (ordu), Saray (idare), yeni Maliye: "İşleyiş" satırı (3 bant) + "Başkan" satırı. Halden Holding paneli: "Nüfuz" ve "Medya" göstergeleri.
- **Halden kişi kartı:** iki yeni gösterge (`_trait`), mevcut kademe noktası stiliyle.
- **Çeyrek bütçe kartı:** diğer kartlar gibi Gündem'de; seçeneklerde bedel/ödül **ifadeyle** (örn. "Kasa rahatlar; kurumlar yıpranır") ve kart altında meclis görüşü.
- **Geçen haftadan beri:** "MALİYE:", "ADLİYE:" gibi uyarılar ve "Halden'in havası değişti" satırı.
- **Oyun sonu:** grafiğe iki çizgi, "Devlet Defteri" bölümü.
- **Sayı yok kuralı:** kapasite ve holding hiçbir yerde sayı olarak görünmez; bantlar üç kademelidir.

---

## 10. İstismarlar ve uç durumlar

| Durum | Çare |
|---|---|
| **İhale spam'i** servet makinesi | 3 hafta bekleme, her ihale sır + kasa − maliye kapasitesi −; ölçülecek (`advice_patron`) |
| **Hep sadık atama** (darbe bağışıklığı) | Kapasite çöker: sınırda yenilgi, maaş krizi, `kurum_sessiz_cokus`; hedef: sadık bot ölçüt botun altında kalsın |
| **Hep liyakatli atama** | Başkanın hırsı ve bağımsızlığı artar (`kadro_ihaneti`), darbe riski yükselir |
| **Sürekli sıkı bütçe** | Kapasite yıpranır, sokak kızar; kasa dolar ama harcayacak yer yok (fazla kartı) |
| **Kessler görevden alınırsa** | Maliye kapasitesi −12, panelde "başkansız"; 6 hafta sonra +5; kasa gerçeği rapora yansımaz (rapor yok) |
| **Falk görevden alınırsa / yetki krizinde tasfiye** | Hukuk kapasitesi −15 (tasfiye mevcut `FALK_GITTI` yoluyla); savcılık başvurusu kapanır |
| **Halden `moved`** | İhale kapanır; `holding` erir; düşmanca medya kalıcı; "el koy" seçeneği açık soru |
| **Kayıt/yükleme** | Yeni alanlar kayıtta; eski kayıtta varsayılan: kapasite 55, kasa 55, `holding = clamp(Halden.gücü − 10)`; `SAVE_VERSION` 5, `_migrate_save` adımı, `save_test` eski sürüm adımı |
| **Zorluk** | §5 çarpanları |
| **Tekrar** | Çeyrek bütçe yalnızca takvim haftalarında; talep kartı aralıkla; kadro/ihale beklemeyle |
| **Eylem yok (idle bot)** | Kapasite yavaş çürür, çeyrek kartı varsayılan "Dengeli" seçilmiş sayılır (ertelenen karar kuralı: `ignore` fx = stance 0) |

---

## 11. Denge hedefleri

Ölçüm: `probe_template.gd`, 80 kampanya, üç zorluk. Yeni botlar: `advice_patron` (3 haftada bir ihale), `advice_loyal` (her kurumda Sadık Ata, bekleme biter bitmez), `advice_merit` (Liyakatli Ata), `advice_austere` (hep sıkı), `advice_lavish` (hep cömert). Hepsi `advice_weighted` tabanlı, görünür bilgiyle.

| Hedef | Ölçüt |
|---|---|
| **Taban korunur** | Yeni sistemleri hiç kullanmayan `advice_weighted`: Kolay %70–85, Normal %35–55, Zor %15–30; mevcut değerlerden ±3 puan |
| **Tek baskın strateji yok** | Hiçbir strateji botu `advice_weighted`'ı hiçbir zorlukta 8 puandan fazla aşmaz; hiçbiri −20 puandan fazla altına düşmez (kullanılabilir kalsın) |
| **Sadık bot** | Sonda ortalama kapasite < 40; en az bir zorlukta ölçüt bottan belirgin düşük; ordu krizi/maaş krizi sıklığı ≥ 2× taban |
| **Liyakat botu** | Sonda ortalama kapasite > 70; Arden'in darbe payı taban + en az 5 puan |
| **İhale botu** | Halden düşman yayını oyun başına 0,5–2; kişisel servet ≤ 4× taban; `yetkisiz` kayıp payı ≥ taban |
| **Tempo** | Yeni kartlar ve olaylar toplam ≤ +0,2 olay/hafta; hiçbir dilim 0,8'in altına düşmez |
| **Okunurluk** | Kapasite haritası paneli en az iki kurumda oyun içinde bant değiştirir (ekran görüntüsü kanıtı) |
| **Kayıp çeşitliliği** | Darbe dışı pay (ölçüt bot) %4–10'dan en az %12–15'e çıkar (maaş krizi ve düşük kapasiteli ayaklanma/yetki yolları) |

---

## 12. Uygulama planı

Her adım ayrı commit; refactor ile özellik aynı commit'e girmez. Her adımdan sonra: `sim_test`, `event_check`, `save_test`, `content_check`, `ui_input_test`, `--autoplay` (+`--mobile`, `--full`: tohum 101 sonucu yalnızca bilinçli değişiyorsa değişir), ve denge ölçümü.

### 4a — Devlet kapasitesi ve kasa
1. **Alanlar ve kayıt** (`sim.gd`): `capacity`, `treasury`, `budget_stance`, `court_share`, `capacity_timeline`; `new_game` sıfırlama (ayrı üreteç), `save_game`/`load_game`, `SAVE_VERSION 5`, `_migrate_save`; `save_test.gd` v4→v5 adımı.
2. **Haftalık tick ve etkiler:** §5 formülleri (`_world_tick`, `legal_pressure`, `other_chance`, `crisis_chance`, emir `fidelity`, rapor gürültüsü, Kessler ekonomi gerçeği). **Ölçüm: taban ±3 olmalı; ATTRITION ve çarpanlar buna göre ayarlanır.**
3. **Olay koşulları:** `min_cap`/`max_cap` (sözlük: kurum → değer), `min_treasury`/`max_treasury`; `_eligible`, `tests/event_check.gd` (bilinmeyen kurum denetimi), `VELORIA.md` şeması.
4. **Çeyrek bütçe kartı:** `_fire_budget()` (dinamik kart, `crisis_kind` değil `kind: "budget"`), ertelenen karar kuralı, `choice_value` terimleri (`advice.gd`).
5. **Kadro eylemleri** (`sim.gd`: `appoint(id, kind)`), mevcut eylemlerin küçük kapasite etkileri, `ACTION_META`/önizleme (`person_panel.gd`), eylem sekmesi, `autoplay.gd` bilmeli.
6. **Bilgi yüzeyi:** kurum panelleri (`city_view.gd`, `city_map.json` Maliye), eşik haberleri, `weekly_news` önekleri ve haber şeridi önceliği, "Geçen haftadan beri" satırları, `press.gd` filtreleri.
7. **İçerik:** kurum olayları, kasa olayları, rapor cümleleri (`content_reports.json`), `content_check.gd`.
8. **Bot ve ölçüm:** `advice_loyal`, `advice_merit`, `advice_austere`, `advice_lavish`; `sim_test`: kadro, bütçe, eşik testleri.
9. **Belgeler:** `OYUNCU_REHBERI.md`, `DURUM_VE_YAPILACAKLAR.md`, `VELORIA.md`, bu belgenin "Sonuç" bölümü.

### 4b — Patronaj ve oligark
1. **Alanlar ve kayıt:** `holding`, `halden_hostile_until`, `halden_demands`, `lena_boost_until`, `kadro_log`; kayıt sürümü 5'e eklenir ya da 6 (4a sürümü yayınlandıysa).
2. **İhale Ver** (`sim.gd`), Halden kişi kartı göstergeleri, önizleme.
3. **Medya etkisi** (`_world_tick`), `press.gd` düşman başlıkları, TV şeridi.
4. **Talep kartı** (`_fire_patronage()`), dört seçenek, savcılık başvurusu.
5. **Betikli olayların birleştirilmesi:** `halden_ihale`/`halden_fatura` seçenekleri talep kartına aynı bayraklarla taşınır; `halden_imparatorluk`, `halden_meclis` `min_holding` alır; `yay_halden_*` koşulları test edilir.
6. **Botlar ve ölçüm:** `advice_patron`; ihale spam'i ve düşman yayın sıklığı ölçülür.

### 4c — Bağlama
1. Rejim hesabı (`_choose_regime`): holding ve sadık atama terimleri; `content_labels.json`'a yeni rejim hesaplaşma metinleri gerekmez.
2. Oyun sonu: `end_screen.gd` grafik çizgileri ve **Devlet Defteri**; `record["state"]`; yeni unvanlar ("Harap Devletin Kralı": kapasite ortalaması < 35 ile tahtta kalmak; "Liyakat Kralı": > 70) ve başarımlar (`content_achievements.json`): *Harap Devlet*, *Liyakat Kralı*, *Oligarkın Esiri* (holding ≥ 90), *Oligarkı Dizginleyen* (holding ≥ 70 görüp < 40'a indirmek).
3. `ui_shots.gd`: `--state` bayrağı (kapasite panelleri ve Devlet Defteri).
4. Tam denge ölçümü (tüm botlar), belgeler, sürüm 1.3.0.

**Tahmini büyüklük:** 4a ~ 1,5× Faz 3; 4b ~ 0,7×; 4c ~ 0,3×. Codex'e verilecekse 4a, 4b ve 4c ayrı oturum; her biri bu belgeyle birlikte.

---

## 13. Kararlar (2026-10-07, kullanıcı: "önerilerine göre")

Tasarımın açık soruları şöyle kapatıldı. Uygulayıcı bunları değiştirmez; bir karar uygulanamazsa durur ve bildirir.

| # | Soru | Karar | Gerekçe |
|---|---|---|---|
| 1 | Tek oligark mı? | **Yalnızca Halden.** Birden çok iş insanı Faz 4 dışı. | Yeni aktör ızgara, rapor, hamle ve kayıt sistemlerini genişletir; çekirdek döngü Halden ile sınanmadan kapsam büyütülmez |
| 2 | Kapasite gösterilsin mi? | **Evet: üç kademeli bant, yalana açık** (başkanın iyimserliğiyle şişirilir; Doğrula gürültüsüz bant verir). "Hiç gösterme" kipi yok. | Sezilebilirlik ilkesi: körlük değil belirsizlik |
| 3 | Çeyrek bütçe kartı sıklığı | **13., 26., 39., 52., 65., 78., 91. haftalar (7 kart).** Tempo etkisi ~0,07 olay/hafta. Etkisi kalıcı duruşla haftalık aktığı için seyrek kart yeterli. | Daha seyrek (yılda 2) duruşu çok uzun tutar ve kararı ağırlaştırmadan sıkıcılaştırır |
| 4 | Yeni eylemler nerede? | **Masaüstünde yeni 7. sekme "DEVLET"** (İhale Ver, Sadık Ata, Liyakatli Ata). Mobilde sekme etiketleri kısaltılır ya da sekme satırı kaydırılır (1067x600'de sığmalı; ui_shots mobil kanıtı zorunlu). | Eylemler ortak bir temaya ("devlet işleri") ait; KAZAN'ı şişirmez |
| 5 | Halden `moved` olunca "el koy" | **Faz 4'e dahil değil.** Olası genişleme; `holding_devrildi` olayı yalnızca düşman yayın ve holding erimesiyle yetinir. | İlk sürümde tırmanmayı sınırlı tut |
| 6 | Atama oyuncuya ipucu versin mi? | **Hayır.** Yalnızca sonuç metni; başkanın Tavır göstergesi anında oynamaz. | Gizli bilgiyi sızdırmaz; ilke 1 |
| 7 | Başlangıç kapasitesi ±5 | **Evet**, tohumdan türeyen ayrı üreteçle (ana `rng` tüketilmez). | Tekrar oynanabilirlik; eski tohumların akışı korunur |
| 8 | Saray payının ahlaki sinyali | **Hayır (ilk sürüm).** Yalnızca sır doğar; danışman metni eklenmez. | Kapsamı dar tut |

Faz 4'ün üç parçası ayrı oturumda uygulanır; 4b, 4a'nın, 4c ise 4b'nin commit'lerini gerektirir.

## 4a Sonuç (2026-10-07)

Kapasite/kasa, yedi çeyrek kartı, dört başkan için iki kadro yolu, Başkent'teki yalana açık üç bant ve Doğrula, eşik haberleri, 15 olay ve kurum raporları uygulandı. Başlangıç kapasitesi ayrı tohum üreteciyle kuruluyor; ana rastgele sayı dizisi bundan etkilenmiyor. Kayıt sürümü 5, v4 göçü var. 4b ve 4c henüz uygulanmadı; 1.2.0 paketleri eski sürüm.

80 kampanya/üç zorluk kapısında ölçüt botu %83/%45/%16 ile tabanın aynısı. Sadık atama botunun ortalama son kapasitesi 24,9; liyakatli atama botunun 75,1. Liyakatlide Arden darbe **girişimi** toplam 175/240'tan 203/240'a çıktı (+11,7 yüzde puanı); başarıyla sonuçlanan darbeler ayrı tutuldu. Tarz botlarının hiçbiri ölçütü 8 puandan fazla aşmadı veya 20 puandan fazla geride kalmadı. Tempo testinde görünen bütün dilimler ≥0,8; 81–88 diliminde yalnız dört yaşayan oyun haftası olduğu için o dilimin kestirimi zayıf. Testler ve masaüstü/mobil kurum, bütçe, DEVLET görüntüleri `docs/FAZ4_ILERLEME.md` içinde.

## 4b Sonuç (2026-10-08)

Tek oligark Halden'in holdingi, medya havası, İhale Ver eylemi ve dört seçenekli talep kartı uygulandı. Eski iki ihale/fatura kartının seçenekleri talebe taşındı; bayrakları ve hikâye zincirleri korunuyor. Düşman yayın, başarısız savcılık, saray payı sızıntısı ve karşı safa geçen Halden olayları eklendi; el koyma seçeneği yok. Aynı ihalenin haftalar boyunca ürettiği izler yargı hesabında tek dosya olarak sayılır. Kayıt sürümü 6; v5 göçü var.

80 kampanya/zorluk kapısında ölçüt %85/%47/%18 (4a tabanına göre +2/+2/+2), ihale botu %66/%33/%23. Her iki botun son serveti tabanın dört katının altında. Ölçütte düşman yayın olayı üç zorluğun birleşik ortalamasında oyun başına 0,59; patron botu Halden'in taleplerine hep Ver dediği için düşman yayın görmez. Patron botunun yetkisiz kayıp payı tabanın üstünde. 1.000 Kolay tohumda yeni talep kartları dahil toplam tempo +0,024 olay/hafta; 97–104 diliminde 258 yaşayan oyun haftasında 1,04. `--full` tohum 101 104 hafta TAHTTA. Görseller ve tüm sayılar `docs/FAZ4_ILERLEME.md` içinde. 4c ve 1.3.0 paketleri henüz yapılmadı.
