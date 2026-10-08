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
