# Veloria — Analiz ve Yol Haritası (durumlu)

İlk analiz raporu: 2026-10-04 (üçüncü oturum). Bu sürüm: 2026-10-04, dördüncü oturum sonu.
İşaretler: ✅ yapıldı · 🟡 kısmen · ⬜ kalan · 👤 kullanıcıda

## 1. Oyun ne durumda?
Baştan sona oynanabilir, sağlam bir dikey dilim (erken alfa): 104 hafta, 9 güç merkezi, 71 olay, 3 zorluk, otomatik kayıt,
4 kaybetme yolu, ünvanlı sonlar; Windows / Linux / Web sürümleri.

**Ölçülen denge — eski (analiz anında, Normal, 40 kampanya)**
| Oyun tarzı | Kazanma | Not |
|---|---|---|
| Hiçbir şey yapmamak | 0/40 | hep ~25. haftada askerî darbe |
| Rastgele | 0/40 | |
| "Dikkatli" test botu | 19/40 | gizli değerleri okuyor |
| Görünür bilgiyle oynayan basit bot | 0/40 | |

**Ölçülen denge — şimdi (80 kampanya, `balance-check/probe_template.gd`)**
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| Görüşsüz, alametsiz (görünür bilgi) | %56 | %23 | %15 |
| **Meclis görüşlerini tartan (ölçüt, gerçek oyuncuya en yakın)** | **%80** | **%48** | **%27** |
| Seçenek etkilerini okuyan (tavan) | %100 | %98 | %88 |

## 2. En güçlü taraflar (değişmedi, güçlendi)
1. Tema ile mekanik aynı şeyi anlatıyor; artık **danışmanlar** da yalan söyleyebiliyor ve **alametlerin** bir kısmı dedikodu.
2. Sistemler birbirine bağlı (sırlar → kaskad → darbe; şimdi bunlara meclis ve alametler eklendi).
3. Oyun sonu ödülü güçlü; eklendi: **Meclis Sicili**, **Komplo Defteri**.
4. Olay sistemi veriyle çalışıyor.
5. Teknik disiplin: testler genişledi (meclis, darbe aşamaları, kriz, kayıt).

## 3. Sorunlar ve durumları
**A. Okunabilirlik ve geri bildirim**
- ✅ Karar seçeneklerinde ipucu yok → **Meclis görüşleri** (`docs/design/danisman_gorusleri.md`)
- ✅ Darbe görünmeden geliyor → **Darbe aşamaları, alametler, şüphe göstergesi, kriz kartı** (`docs/design/darbe_asamalari.md`)
- 🟡 Kararların sonucu görünmüyor → oyun sonunda Meclis Sicili; oyun içi geri bildirim hâlâ zayıf
- ⬜ Raporlar geçen haftaya göre değişimi göstermiyor
- ⬜ Hafta sonu "neler değişti" özeti

**B. Strateji derinliği ve denge**
- 🟡 Tek baskın kayıp türü (darbe) → artık kriz kartından geçiyor, ara sıra elit koalisyonu; ama hâlâ baskın
- 🟡 Tek baskın kazanma yöntemi (rüşvet) → rüşvetin izleri ölçülebilir biçimde zarar veriyor; izsiz alternatif **Huzura Çağır** eklendi; azalan getiri yok
- ⬜ "Rakibi Zayıflat" hedef seçtirmiyor ("birbirine düşür" yok)
- ⬜ Görevden almanın sonucu tahmin edilemiyor (gizli eşikler)
- ⬜ Bütün eylemler aynı maliyette

**C. Belge ↔ kod farkları**
- ⬜ Devlet bütçesi / kapasitesi · ⬜ Patronaj / oligark · ✅ Aktörlerin kendi hamleleri · ✅ Kampanya dönemleri · ✅ Rejim tipi ve final tehdidi
- ⬜ Belgede 10 kayıp yolu, kodda 4 · ✅ Kişisel hikâye yayları

**D. Arayüz ve görünüm**
- ⬜ Masa/harita ile ana ekran iki paralel gezinme yolu
- ✅ Ana ekran sadeleştirildi: eylemler kategori sekmelerinde (17 düğme → 6 sekme + 3 düğme), raporlar kaynaklarının altında, ilk haftalarda "Bu hafta ne yapmalı?" yol göstericisi (`docs/ux/ana_ekran_sadelestirme.md`)
- ✅ Eylem önizlemesi (maliyet / risk / iz)
- ⬜ Ses sentetik
- 🟡 Bildirimler kompakt ve en çok 2 (mobilde 1); mobilde haber şeridinin üstüne binmesi sürüyor
- ⬜ Yerelleştirme altyapısı yok

**E. Teknik borç ve riskler**
- ✅ `main.gd` 3249 -> 1390 satır (gündem ve kişi paneli dahil bileşenler ayrıldı; bkz. `docs/TECH_DEBT.md`), `sim.gd` 2205 satır
- ⬜ Tam yeniden kurulum (her değişiklikte gündem/kartlar baştan)
- ◐ Kayıt sürümü ve göç yapıldı; tek yuva ve bekleyen olayların metinle gömülü olması duruyor
- ✅ `events.json` doğrulayıcısı (`tests/event_check.gd`)
- 👤 **Kodun uzak yedeği yok** (origin Beckett'in deposu)

## 4. Fazlar
**Faz 0 — Güvence**
1. 👤 Kendi deponu aç (bağlamayı ben yaparım)
2. ✅ Boş masa görseli
3. ✅ Kayıt sürüm alanı + göç (`Sim.SAVE_VERSION`, `tests/save_test.gd`); ✅ `events.json` doğrulayıcısı (`tests/event_check.gd`)
4. ✅ Görünür bilgiyle oynayan bot (+ danışman botları, `--bots=` süzgeci)

**Faz 1 — Okunabilirlik ve geri bildirim**
- ✅ Darbe aşamalı ve görünür; kişi kartında yanılabilir şüphe sinyali
- ✅ Karar seçeneklerinde yanılabilir danışman görüşleri
- ✅ Raporlarda değişim + hafta sonu "neler değişti" özeti (`docs/design/faz1_okunabilirlik.md`)
- ✅ Eylem önizlemesi (maliyet / risk / iz)

**Faz 2 — Strateji derinliği ve denge**
- ✅ Kayıp çeşitliliği (sokak/mahkeme krizleri, `docs/design/kayip_cesitliligi.md`; ölçüt botta kısmi) · ✅ Rüşvete azalan getiri (ölçüldü: gerek yok; rüşvet botu Kolay %51, Normal %40, Zor %20 — mahkeme yolu bedeli zaten yaratıyor) · ✅ Hedefli "birbirine düşür" (`docs/design/birbirine_dusur.md`) · ✅ Aktörlerin kendi hamleleri (`docs/design/aktor_hamleleri.md`)
- ✅ Denge hedefleri görünür bilgiye dayalı botla (hedefler güncellendi: ölçüt botu Kolay %70–85, Normal ~%45, Zor %15–30)

**Faz 3 — Kampanya ve içerik: ✅** dönemler (Bedellerin Dönüşü / Hesaplaşma) · ✅ ikinci yıl için 30 olay (`docs/design/ikinci_yil.md`) · ✅ dokuz karakterin hikâye yayı (`docs/design/hikaye_yaylari.md`) · ✅ altı rejim tipi ve final tehdidi (`docs/design/rejim_tipi.md`)
**Faz 4 — Büyük sistemler:** ⬜ devlet bütçesi/kapasitesi · ⬜ patronaj/oligark
**Faz 5 — Cila ve altyapı:** ⬜ gerçek ses/müzik · ✅ `main.gd` bölmesi · ⬜ artırımlı arayüz güncellemesi · ⬜ yerelleştirme

## 5. Sıradaki
1. ✅ Arayüz sadeleştirme turu (ilk ekran kalabalık) — `docs/ux/ana_ekran_sadelestirme.md`
2. ✅ Faz 1'in kalanı: değişim okları + hafta özeti, eylem önizlemesi
3. ✅ Faz 0: kayıt sürümü, olay doğrulayıcısı; 👤 depo (kullanıcıda)
