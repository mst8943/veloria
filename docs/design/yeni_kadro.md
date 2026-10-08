# Yeni kadro: eski aktörlerin yerine geçiş ve beş yeni rol

Durum: **Aşama A uygulandı** (2026-10-08). **Aşama B (beş yeni rol) tasarım önerisi; kodlanmadı.**

## 1. Aşama A — Eşleme (uygulandı)

İç kimlikler (`arden`, `voss`...) değişmedi: kayıtlar, 179 olay ve bayraklar bozulmasın. Yalnızca görünen ad, unvan, portre ve metinler değişti. Tam oyun (`--full`, tohum 101) ve tüm testler değişiklikten önceki taban ile birebir aynı sonucu veriyor.

| İç kimlik | Eski | Yeni | Not |
|---|---|---|---|
| `arden` | General Arden | **Marcus Arden**, Genelkurmay Başkanı | Metinlerde "Arden" kaldı |
| `voss` | Elias Voss | **Nadir Vale**, VIA İstihbarat Başkanı | Metinlerde "Vale" |
| `kessler` | Marta Kessler, Maliye Bakanı | **Selin Veyra**, Başbakan | Ekonomi ve maliye alanını yürütür; "Maliye Bakanlığı" kurumu aynı kaldı |
| `halden` | Viktor Halden | **Victor Sarne**, Sarne Grubu Başkanı | "Sarne Holding", "Sarne TV" |
| `lena` | Lena Ostrow | **Leyla Sarn**, Bağımsız Gazeteci | |
| `dorn` | Alaric Dorn, Saray Kâhyası | **Kraliçe Helena**, Kraliyet Vakfı Başkanı | Saray kapısı ve randevu listesini kraliçe yönetir; rüşvet olayı "Vakıf bağışı" oldu; zayıf nokta "Vakıftaki usulsüz bağışlar" |
| `prens` | Prens Cassian | **Prens Marcus** | |
| `brandt` | Teodor Brandt | **Adrian Voss**, Ana Muhalefet Lideri | Dikkat: eski "Voss" (istihbarat) artık "Vale" |
| `falk` | Yargıç Mira Falk | **Sophia Renn**, Başsavcı | |

Ek değişiklikler:
- Söz ödülü **"Başbakanlık" → "Naiplik"** (artık Başbakan Veyra var). Eski kayıttaki "Başbakanlık" ödülü de çalışır.
- Portreler `art/portraits/<eski_id>.png` adıyla yeni görseller; eskiler `art/_arsiv/eski_portreler/` (git geçmişinde de var).

Bilinen küçük tutarsızlıklar (kabul edildi):
- Olay görselleri (`art/events/*`) eski karakterleri gösterebilir (ör. kâhya, Halden masası). Sarne ve Veyra için benzerlik yüksek; kâhya görselleri kraliçeye uymuyor. Bkz. §4.
- Veyra hem Başbakan hem "Maliye Bakanlığı" kurumunun başı olarak okunur (Faz 4 kadro eylemleri).

## 2. Aşama B — Eşi olmayan beş karakter

Julian Valerius, Elena Varos, Claire Duvall, Viktor Malenkov, Lucien Vale. Hepsinin portresi hazır. Hepsi oyunda **bir işe yarayacak**; yalnızca süs olmayacak.

### 2.1 İlke
- Darbe yapabilen aktör sayısı ve gücü artmayacak (bilinen denge dersi: Arden ve Prens'e güç/hırs eklemek Normal'i bozdu).
- Yeni sistemler, mevcut sayıları değiştiren **küçük, kademeli** etkiler olacak; "sayı yok" ilkesi korunur (bant/kademe).
- Her aşamada ölçüt bot taban ±3, tempo yeni olay <= +0,2/hafta.

### 2.2 Roller

**Julian Valerius — Veliaht Prens (hanedan, meşruiyet).**
- Aktör (içeriden, `royal` değil: "Prens" kısa adı Prens Marcus'a kalsın). Güç düşük, hırs ≤ 20, sadakat yüksek; **darbe yapamaz**.
- Rolü: halefiyet. Yeni eylem "Veliahdı Yetiştir" (DEVLET sekmesi, 1 mesai, 6 hafta bekleme): Julian'ın "olgunluk" gizli değeri artar. Olgun veliaht: halk huzursuzluğunu yavaşça düşürür, taht krizlerinde kralın gücünü korur, Prens Marcus'un "veliaht" hamlelerini zayıflatır.
- Risk: Julian'ı fazla öne çıkarmak Prens Marcus'u ve Marcus Arden'i tedirgin eder (hırs +). Darbe krizinde Prens Marcus tarafı veliahdı "sembol" olarak kullanmaya çalışabilir (olay, sayı değişikliği yok).
- Olaylar: ~4 (veliaht halka konuşma, veliaht isyanı reddi, Prens Marcus'un veliaht oyunu, veliaht evlilik/ittifak).

**Elena Varos — Dışişleri Bakanı (dış ilişkiler danışmanı).**
- İçeriden aktör, alan `foreign`. Haftalık raporu üç dış gücün ilişki bandını verir; **yalana açıktır** (başkan olarak iyimser ya da kendi lehine). Doğrula eylemi gürültüsüz bant verir (kurum panelleriyle aynı düzen).
- Eylem "Heyet Gönder" (1 mesai, 4 hafta bekleme): seçilen dış gücün ilişkisini artırır, diğerlerini hafif düşürür.

**Claire Duvall (Asteria), Viktor Malenkov (Drakon), Lucien Vale (Seravia) — dış güçler.**
- İçeriden olmayan aktörler (Leyla Sarn ve Adrian Voss gibi): saray raporu vermezler, darbe yapamazlar. Her biri gizli bir **ilişki** (0–100) taşır; ekran üç kademe: "Soğuk / Mesafeli / Yakın" (Elena'nın bandı).
- İlişki haftalık olarak oyuncunun yaptıklarından kayar:

| Güç | İstediği | Yükselten | Düşüren | Yakınken verdiği | Soğukken getirdiği |
|---|---|---|---|---|---|
| Asteria (Claire) | Hukuk ve basın özgürlüğü | Leyla serbest, Renn bağımsız, hukuk kapasitesi yüksek | Tutuklama, mahkeme müdahalesi, medya baskısı | Kredi/yardım: kasa + | Yaptırım: ekonomi - |
| Drakon (Malenkov) | Güçlü merkez ve ordu | Marcus Arden güçlü, ordu kapasitesi, sıkı yönetim | Reform, ordu bütçesi kesintisi | Silah anlaşması: ordu kapasitesi +, darbe girişimi bastırma desteği | Sınır olayı, "gönüllü" kışkırtması |
| Seravia (Lucien) | Ticaret ve ihale | İhale, Sarne'nin holdingi, kasa dengeli | Kısıtlama, vergi artışı | Yatırım: ekonomi + | Ambargo, Sarne'ye gizli destek (holding +) |

- Dengeleme: Asteria ve Drakon birbirine zıt; ikisini birden memnun etmek zor. Üçünü de 70'in üstünde tutmak masrafı kasa ve itibar olarak çıkar (istismar kapısı).

### B2.2 parametreleri

Kayma `_world_tick` sonunda ve ayrı RNG çağrısı olmadan uygulanır. Başlangıçtaki pasif kayma, bir ilişkiyi tek başına eşikten geçirmez; eşikler oyuncunun heyet ve olay kararlarıyla açılır.

| Güç | Haftalık kayma | Yakın (`≥70`) | Soğuk (`≤30`) |
|---|---|---|---|
| Asteria | Leyla özgür +0,035; Renn görevde +0,025; hukuk kapasitesi farkı ×0,003; aksi durumda −0,07/−0,05 | kasa +0,12 | ekonomi −0,10 |
| Drakon | Arden güç farkı ×0,003; ordu kapasite farkı ×0,003; sıkı bütçe −0,08; liyakatli ordu ataması −0,03 | ordu kapasitesi +0,08, kriz savunması +0,03 | huzursuzluk +0,10 |
| Seravia | ihale başına +0,02 (en çok 3); holding farkı ×0,002; dengeli kasa +0,02; dengesiz kasa −0,06; saray payı −0,04 | ekonomi +0,08 | holding +0,08 |

Eşik etkileri Kolay ×0,7, Normal ×1,0, Zor ×1,1 ile uygulanır. Drakon'un desteği yalnızca mevcut darbe krizi savunma olasılığına eklenir; darbe yaratmaz.

### B2.3 bilgi ve heyet

Elena her hafta üç ilişkiyi **Soğuk / Mesafeli / Yakın** olarak anlatır. Başkanın iyimserliği ve ayrı üreteçten gelen küçük gürültü rapora karışır; Doğrula altı hafta boyunca aynı bantları gürültüsüz gösterir. İlişki ilk kez yakın ya da soğuk eşiğine vardığında gündeme bir `DIŞİŞLERİ:` satırı eklenir. Bu satırlar TV şeridine gitmez.

DEVLET sekmesindeki **Heyet Gönder** seçili Claire, Viktor veya Lucien için çalışır: 1 mesai, 4 hafta bekleme; seçilen ilişki +12, diğer iki ilişki −3. Bu açık takas üç gücü aynı anda yakın tutmayı engeller.

### B2.5 olaylar

Sekiz ilişki olayı yalnızca en az bir **Heyet Gönder** kararından sonra açılır; böylece dış ilişki sistemini kullanmayan kampanyanın olay havuzu değişmez. Asteria kredi ve basın notasıyla, Drakon silah anlaşması, sınır notası ve güvenlik teklifiyle, Seravia yatırım, ambargo ve Sarne kredisiyle temsil edilir. İlişki etkileri `fx.foreign` altında tanımlanır; olay doğrulayıcısı güç adını ve sayı tipini denetler. Eski `yabanci_elci` olayı genel dış politika kartı olarak kalır; yeni kartlar ilişki eşiklerine bağlıdır.

### 2.3 Sistem değişikliği (küçük)
- Alanlar: `foreign = {asteria, drakon, seravia}`, `heir_maturity`, `foreign_hint_until`. SAVE_VERSION 8, `_migrate_save` (eski kayıt: ilişkiler 50, olgunluk 30), save_test adımı.
- Olay koşulları: `min_foreign`/`max_foreign` (güç -> değer sözlüğü), `min_heir`/`max_heir`; `event_check` bilinmeyen güç adını denetler.
- Haftalık formüller `devlet_ve_patronaj.md` §5 ile aynı düzende parametre tablosu; hepsi etkisiz-bayrağıyla ayrı ölçülebilir olmalı.
- Arayüz: Başkent haritasına "Elçilikler" mahallesi (üç plaka); DEVLET sekmesine "Heyet Gönder" ve "Veliahdı Yetiştir"; haber şeridi eşik haberleri ("DIŞİŞLERİ:").

### 2.4 İçerik (~14 olay)
Kredi teklifi, yaptırım tehdidi, silah anlaşması, sınır olayı, Sarne'ye Seravia desteği, Seravia ambargosu, Asteria basın özgürlüğü notası, Drakon'un darbe desteği teklifi (bastırma), Drakon "gönüllüleri", Elena'nın istifası/ihaneti (Asteria'ya sızdırma), Elena'nın abartılı raporu ortaya çıkıyor, + Julian'ın dört olayı.

### 2.5 Kapı ölçütleri
Tüm testler; ölçüt bot taban ±3 ve bantta; dış ilişkileri/heyeti hiç kullanmayan ölçüt botun sonucu değişmez; `advice_heyet` botu (üç güce dönüşümlü heyet) ölçüt botu 8 puandan fazla aşmaz ve 20 puandan fazla altına düşmez; yeni alanlar kayıttan geri yüklenir; ekran görüntüleri (Elçilikler, DEVLET sekmesi, Elena raporu, veliaht kartı) masaüstü + mobil.

### 2.6 Uygulama sırası
1. B1: Julian + Elena (aktör, rapor, eylem, 4+4 olay; dış güçler henüz yok → Elena yalnızca genel "dış ilişki" havası verir).
2. B2: üç dış güç (ilişki alanları, haftalık kayma, eşik olayları, Heyet Gönder).
3. B3: arayüz (Elçilikler mahallesi), ölçüm, belgeler, sürüm 1.4.0.

## 3. Açık sorular (kullanıcıya)
1. Elena Varos ayrı bir tehdit mi olsun (casusluk/ihanet), yoksa yalnızca yararlı bir danışman mı? Öneri: yalana açık danışman + bir ihanet olayı.
2. Üç dış gücün "yaptırım/ambargo" etkisi oyunu zorlaştırır. Öneri: Kolay'da etkiler %70, Zor'da %110.
3. Başkent haritasında yeni mahalle için yeni görsel (`art/city_map.png` güncellemesi) gerekir; yoksa yalnızca mevcut haritaya üç plaka eklenir. Öneri: ilk sürümde yalnızca plaka.

## 4. Görsel işler (sizde)
- Olay görsellerinden kâhya içerenler (`events/dorn_*`, `dorn_sir`, `dorn_filtre`) kraliçeyle yeniden üretilmeli; referans: `art/portraits/dorn.png` (Kraliçe Helena).
- Julian, Elena, Claire, Malenkov, Lucien portreleri hazır (`art/portraits/`).

## B1 Sonuç (2026-10-08)

Julian ve Elena oyunda; portreleri, kartları, raporları ve sekiz olayları bağlandı. Julian'ın eğitimi 6 hafta beklemeli, olgunluğu üç bantlı. Ana RNG tüketimi korunuyor: 101 tohumlu tam oyun 104 hafta TAHTTA, Medya Rejimi, 112 olay. Kayıt sürümü 8 ve v7 göçü sınandı. 80 kampanya/zorlukta ölçüt bot %83/%46/%17; veliaht bot %90/%42/%22. Prens Marcus girişimi artışı en fazla 2,5 puan. Tempo alt dilimi 0,81; yeni olay yükü eski stratejide sıfır. Masaüstü ve mobil kart/rapor/olay PNG'leri `dist/qa_yeni_kadro_b1_*` altında incelendi. B2 henüz başlamadı.
