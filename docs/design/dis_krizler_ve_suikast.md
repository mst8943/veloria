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

## Ayar

Probe: `advice_weighted`, 80 kampanya/zorluk, tohum dizisi 1–80; TR ve EN aynı. Başlangıç tabanı Kolay 68/80, Normal 36/80, Zor 16/80 idi. İlk ayarda sınır ve mali baskı kampanyaların çoğunda kriz eşiğine ulaşmadı; Drakon beslemesi ×2,6, Asteria/Seravia beslemesi ×1,5 olarak kalibre edildi. Seed 101'in 79. haftasında kredi krizi açılıp tam koşuyu değiştirdiği için mali kriz eşiği 62'den 65'e çıkarıldı. Suikast alameti olasılığı uygun haftada %3,5; saldırı kartı yalnızca önceki hafta alamet kaydı varsa açılıyor.

| Zorluk | Taban kazanma | Son kazanma (TR = EN) | Fark | Son kayıplar: darbe / yabancı / mali / suikast / diğer |
|---|---:|---:|---:|---|
| Kolay | 68/80 (%85) | 62/80 (%77,5) | −7,5 puan | 11 / 1 / 3 / 3 / 0 |
| Normal | 36/80 (%45) | 30/80 (%37,5) | −7,5 puan | 33 / 2 / 3 / 4 / 8 |
| Zor | 16/80 (%20) | 13/80 (%16,25) | −3,75 puan | 58 / 0 / 2 / 2 / 5 |

Toplam 240 kampanyada 135 kayıp var: darbe (askerî + saray) 102/135 = **%75,6**; dış kriz 20/135 = **%14,8** (tüm kampanyaların %8,3'ü). Dış kriz alt türleri: yabancı müdahalesi 3/135 = **%2,2**, mali çöküş 8/135 = **%5,9**, suikast 9/135 = **%6,7**. Kazanma oranı ve dış kriz dağılımı hedef bantlarında; **darbe payı ≤%65 kapısı geçmedi**. Eşikler ve içerik bu sonucu gizlemeyecek şekilde kaydedildi; B1'in toplam denge kapısı bu ölçümle açık kalıyor.
