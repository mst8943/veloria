# Faz 4 ilerleme

Tarih: 2026-10-07. Dal: `veloria`. Tasarım ve değişmez kararlar: `docs/design/devlet_ve_patronaj.md` §13.

## Taban

`dist/phase4_baseline_probe.log`: 80 kampanya, `advice_weighted` Kolay 67/80 (%83), Normal 36/80 (%45), Zor 13/80 (%16). `advice_dirty`: %63/%41/%12; `visible_wise`: %100/%90/%71.

`dist/phase4_baseline_full.log`: tohum 101, hafta 104, TAHTTA, Oligark Rejimi, 115 olay.

## Tamamlanan adımlar

- **4a.1** `3eb95af`: dört kapasite alanı ayrı tohum üreteciyle başlatılır; kasa, bütçe duruşu, saray payı ve kapasite çizelgesi kaydedilir. `SAVE_VERSION=5`, v4 göçü ve kayıt testi eklendi. Bütün testler geçti; `--full` çıktısı tabanla aynı.
- **4a.1 test düzeltmesi** `2bed482`: `var_to_str` kayan nokta yuvarlaması için toleranslı kapasite karşılaştırması.
- **4a.2** `501d68b`: haftalık yıpranma/kasa/ekonomi/huzursuzluk, emir uygulama, kriz şansı, yargı baskısı ve rapor gürültüsü; Kessler'in raporu ekonomi ve kasayı birlikte okur. Kalibrasyon `ATTRITION=0,04`, ekonomi katsayıları `0,003/0,001`, Zor kasa gideri çarpanı `1,8`, Zor ordu toparlama paydası `100`. Bütün testler geçti; `--full` 104 hafta TAHTTA, 120 olay.
- **4a.3** `6f0ac53`: kapasite/kasa olay koşulları, kurum adı doğrulaması, sentetik uygunluk testi ve olay şeması belgesi. Bütün testler geçti; `--full` ve denge 4a.2 ile aynı.
- **4a.4** `b0c0b49`: yedi çeyrek haftasında bütçe kartı; dört karar, ertelenirse Dengeli, en çok üç bekleyen sınırı, Kessler'in mevcut raporundan metin, saray payında sır. Meclis değer terimleri kasa/kapasite/holding'i anlar. Bütün testler geçti; `--full` 104 hafta TAHTTA, 108 olay.
- **4a.5** `4f0932b`: dört başkan için Sadık/Liyakatli Ata, sekiz hafta bekleme; Terfi, Görevden Al ve emirlerin kurum etkileri. Yedinci eylem sekmesi DEVLET masaüstü ve mobilde sığıyor. Bütün testler geçti; `--full` 104 hafta TAHTTA, 108 olay. Görüntüler: `dist/phase4a5_state_shots/1_devlet.png`, `dist/phase4a5_state_shots_mobile/1_saray_devlet.png` (açılıp gözle bakıldı).
- **4a.6** `205f0d4`: Başkentte Maliye Bakanlığı ve dört kurumun üç bantlı, başkan iyimserliğine açık işleyiş göstergesi; Doğrula ile altı hafta gürültüsüz bant; bir defalık kurum/kasa eşik haberleri ve özet/şerit önceliği. TV yalnız `OLAY:` satırlarını aldığı için kurum uyarılarını yayınlamıyor. Bütün testler geçti; `--full` 104 hafta TAHTTA, 108 olay. Masaüstü/mobil görüntüler: `dist/phase4a6_state_shots{,_mobile}/1_maliye_aksiyor.png`, `1_adliye_saglam.png`, `1_butce.png` (açılıp gözle bakıldı).
- **4a.7** `58e4bf8`: Kasa, kurum çöküşü, zayıf sınır, kadro ve geç dönem için 15 olay (159→174); dört kurum × üç bant × üç rapor cümlesi, şema denetimi ve yeni olayların ulaşılabilirlik testi. Bütün testler geçti; `--full` 104 hafta TAHTTA, 109 olay. Tempo 73–80'de 0,93; 81–88'de 1,25 olay/hafta, ancak ikinci dilimde yalnız dört yaşayan oyun haftası var.

## Son ölçüm

| Aşama | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Taban | %83 | %45 | %16 |
| 4a.1 | %83 | %45 | %16 |
| 4a.2 | %80 | %42 | %18 |
| 4a.3 | %80 | %42 | %18 |
| 4a.4 | %83 | %42 | %16 |
| 4a.5 | %83 | %42 | %17 |
| 4a.6 | %83 | %42 | %17 |
| 4a.7 | %83 | %45 | %16 |

## Açık sorunlar

Tempo testinde bütün görünen dilimler ≥0,8; fakat 81–88 diliminde yalnız dört, 89 sonrası hiç yaşayan oyun haftası yok. `--full` olay sayısı bütçe kararlarının başka olayların yerini alması nedeniyle tabandaki 115'ten 109'a indi. `export_presets.cfg` kullanıcı değişikliği olarak çalışma ağacında duruyor.

## SIRADAKİ ADIM

4a.8: Dört strateji sondaj botu (`advice_loyal`, `advice_merit`, `advice_austere`, `advice_lavish`) ve kadro/bütçe/eşik birim testleri. Botların kapasite sonunu, Arden darbe payını, kazanma farklarını ve tempoyu ölç. KAPI 4a sağlanmadan 4b'ye geçme.
