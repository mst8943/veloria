# Dış krizler ve suikast: yeni kayıp yolları

Tarih: 2026-10-11. Faz 6-B1. Kalıp: `darbe_asamalari.md` ve `kayip_cesitliligi.md` (aşamalı, görünür, cevap verilebilir kriz; oyuncu yaklaşmayı ALAMETLERDEN görür, sayıdan değil).

## Neden
Kayıp yolları şu an darbe (baskın), ayaklanma, yetkisizlik, elit koalisyonu. Dış dünya (Asteria, Drakon, Seravia) yalnızca olay ve rapor üretiyor; kaybettiremiyor. Suikast olay olarak var ama bir son değil. Üç yeni yol: **Yabancı müdahalesi / egemenlik kaybı**, **Mali kuşatma ve iflas**, **Suikast**. Hedef: darbe payı düşsün, her biri farklı karar setiyle önlensin, "başarısızlık hikâye" ilkesi korunsun.

## 1. Dış baskı izi (gizli, 0–100, üç güç için ayrı)
`ext_pressure[asteria|drakon|seravia]`. Sayı gösterilmez. Beslenme: ilgili elçiyle kötü ilişki (heyet reddi, sızdırılan sır `elena_asteria_sizinti`), sınır/ticaret olaylarında kötü seçimler, `foreign` (dış itibar) düşüklüğü, kasa boşluğu (Seravia/Asteria için borç), ordu zayıflığı (Drakon için; `ordu_zayif_sinir*` olayları zaten var). Sönme: Heyet Gönder, elçiyi kabul, antlaşma kararları, haftalık %6 doğal sönüm. Elena'nın raporu üç bantta yaklaşmayı verir (mevcut dış ilişki raporu). Elçi kartında yanılabilir şüphe sinyali.

## 2. Üç dış kriz
Her biri: alamet (haber) → AŞAMA 1 nota (karar kartı, soft) → AŞAMA 2 kriz kartı (bir hafta, tepki ver) → başarısızsa SON. Aşamalar arasında en az 4 hafta; tüm dış ve iç krizler tek "aktif kriz" bekleme süresini paylaşır.

**Drakon: sınır ve müdahale** (eşik ~62): nota → tatbikat → ültimatom kartı.
- *Ordu sınıra, taviz yok*: başarı orduya, Arden'in sadakatine, kasaya bağlı; başarırsa Arden güçlenir (darbe riski ↑), kasa ↓.
- *Müzakere / sınır tavizi*: ilk sefer %85 tutar, sonra azalır (darbe tavizi gibi); bedel: kralın gücü, halk öfkesi, Drakon güçlenir.
- *Asteria'dan güvence iste*: Asteria'ya borç/ilişki bedeli.
- SON: "Yabancı müdahalesi": tarih metni "Drakon birlikleri sınırı geçti; elit koalisyonu seni teslim etti." Unvan: "Çöken Egemen".

**Seravia + Asteria: mali kuşatma** (eşik ~60, kasa düşükken daha kolay): ambargo notası → kredi kesilmesi kartı.
- *Kemer sıkma*: kasa ↑, huzursuzluk ↑ (sokak öfkesi mekaniği ile bağ).
- *Sarne'nin sermayesini seferber et*: Sarne gücü ↑, patronaj bağı ↑ (oligark rejimi yolu).
- *Taviz paketi (liman/ticaret)*: dış baskı ↓, `foreign` ↓, kapasite (maliye) ↓.
- SON: "Mali çöküş": maliye kapasitesi ≤ eşik ve kredi kesik: "Devlet maaş ödeyemedi."

**Suikast** (eşik: komplo + iç kriz birlikte; düşük olasılık): alamet (muhafız değişimi, "gece arabaları") → hazırlık haftası (kriz kartı "Kortej planı") → saldırı gecesi.
- *Güvenlik tasfiyesi* (Vale'ye güven; Vale iyi/kötü niyetli olabilir: gizli sadakate bağlı), *Rotayı değiştir ve gizle* (şans, sır bırakmaz), *Halkın karşısına çık* (cesaret: kamuoyu ↑, risk ↑).
- Başarı: yaralı kurtuluş (saray iç sır kazanır, "suikast sonrası" olay zinciri, ünvan etkisi), başarısızlık: SON "Suikast". Çok düşük baz oran; hazırlık haftası olmadan asla.

## 3. Bağlantılar
- Elçi eylemleri (Heyet Gönder, Huzura Çağır) baskıyı düşürür; Elena raporu doğruluğa göre yanılır (rapor yalan sistemi).
- Hakikat Dosyası: oyun sonunda "Dış dünya" satırı (hangi elçi ne dedi, gerçekte ne yapıyordu).
- Rejim tipi: dış kriz yönetimi yeni unvanlar verir ("Kuşatılmış Egemen" vb., en az 3 yeni başarım).
- Final tehdidi/rejim hesabı: aktif dış kriz varken tahtta kalan oyuncu "Kuşatma" bayrağı alır.

## 4. Denge ve istismar
- Taviz/uzlaşma ilk %85, sonra azalır; aynı güce üst üste taviz verilemez (bekleme).
- Tek baskın strateji olmasın: dış krizi sadece ordu ile, sadece para ile, sadece diplomasi ile çözmek her biri bedel taşır.
- Hedefler (80 kampanya/zorluk, ölçüt botu): tahtta kalma oranı mevcut tabanın (Kolay 68/80, Normal 36/80, Zor 16/80) en çok ±8 puan yakınında; kayıp nedeni dağılımında darbe payı ≤ %65; dış kriz kayıpları (müdahale+iflas+suikast) toplamda %10–20; her biri en az %2. Tempo dilimleri ≥ 0,8 olay/hafta. `--full` tohum 101'in sonucu DEĞİŞMEMELİ (aynı 104/TAHTTA/Medya Rejimi): dış krizler bu tohumda tetiklenmeyecek şekilde ayarlanmalı ya da yeni taban kayda geçirilmeli (onayla).
- Yeni RNG tüketimi kampanya sonuçlarını kaydırır; ayrı üreteç kullan (`supporting` aktör örüntüsü) ki mevcut tohumlar bozulmasın.

## 5. Uygulama notları (Codex için)
- Yeni durum alanları kayda (SAVE_VERSION artır, eski kayıt göçü), `Sim.ext_pressure`, `other_crisis` kalıbı (kind: "border"|"siege"|"assassination"), mevcut `_start_other/_resolve_other/_fail_other` ve kriz kartı kalıbı yeniden kullanılsın.
- Metinler çift dilli üretilsin (bkz. docs/i18n/sizinti_gorevi.md "Kararlar"); içerik `game/data/events.json` + `game/data/en/events.json`.
- Testler: sim_test'e dış baskı birim testleri, event_check, save_test (eski kayıt), probe_template'e dış kriz kayıp sayacı, en_leak_test.
