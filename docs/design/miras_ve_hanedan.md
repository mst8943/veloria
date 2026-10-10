# Miras ve hanedan (meta ilerleme)

Tarih: 2026-10-11. Faz 6-B2. Amaç: "bir saltanat daha" isteği; her oyun bir öncekinin sonucunu taşısın, ama kazanma kolaylaşmasın.

## Oyuncuya ne veriyor
Tahtını koruyup veliahtı ilan eden (miras kararı verilmiş) oyuncu, yeni oyunu **Hanedan Devam** olarak başlatabilir: yeni kral, önceki saltanatın mirasıyla (Julian Valerius, ya da ilan edilen veliaht) başlar. Kaybeden oyuncu normal başlar; "Hanedan" sayacı sıfırlanır.

## Devredilenler (en çok 3, 1-2 olumlu + en az 1 olumsuz)
Saltanatın sonundaki rejim ve kayıtlardan türetilir:
- **Kasa mirası:** önceki Maliye kapasitesi yüksekse "Dolu hazine" (başlangıç kasa +), düşükse "Borç" (başlangıç kasa −, Seravia baskısı +).
- **Ordu mirası:** önceki Arden sadakati yüksek / darbe girişimi olduysa "Sadık Ordu" ya da "Küskün Ordu".
- **Açık dosya:** önceki saltanatta ortaya çıkıp kapanmamış bir sır (Hakikat Dosyası) yeni oyunda başlangıç komplo kıvılcımı olarak gelir.
- **Rejim gölgesi:** önceki rejim tipi ("Medya Rejimi" vb.) yeni oyunun ilk dönem olaylarında hafif ağırlık kazanır.
Bunlar tek tek veri satırı (data/legacy.json), kodda yeni mekanik gerektirmez; mevcut başlangıç durumu parametreleri (`new_game` içindeki aktör başlangıçları, kasa, flags, facts) ayarlanır.

## Hanedan sayacı ve defter
Her nesil `user://dynasty.cfg` (kayıtlı Meclis Sicili/Chronicle'a ek): nesil no, ünvan, süre, hanedan puanı (hayatta kalınan hafta + ünvan ağırlığı). Menüde "Hanedan Defteri" (nesil listesi; ünvan, rejim, kaç hafta). 5. nesilde başarım.

## Denge/istismar
- Miras en çok +%10 başlangıç avantajı; her nesilde kalıcı "kral yaşı/meşruiyet" gibi hafif aşınma (üst üste hanedan kolay olmasın).
- Olumlu miras yalnızca önceki saltanatın gerçek durumundan (oyuncu kasayı doldurmadıysa dolu hazine yok).
- Kayıp sonrası devam yok (hanedan yalnızca tahtı koruyunca).
- Ölçüt botu "hanedan devam" yoluyla en çok ölçütten +8 puan geçmeli; üst üste 3 nesil bot koşusu ile birikim sınırı doğrulanmalı.

## Uygulama notları (Codex)
- `Sim.new_game(seed, diff, legacy := {})`; legacy yoksa mevcut tohumlar BİREBİR aynı kalmalı (`--full` tohum 101: 104/TAHTTA/Medya Rejimi/112).
- Menü: Yeni Saltanat ekranında "Hanedan Devam" düğmesi (uygunsa), Hanedan Defteri sayfası. TR/EN metin, mobil 44 px.
- Testler: legacy türetme birim testi, kayıt/yükleme, 3 nesil bot koşusu, save_test.
