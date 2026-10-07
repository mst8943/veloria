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
- **4a.8** `80c221c`, `33d04bf`: Zor oyunda ordu kapasitesinin darbe savunma bonusu tek katsayı grubunda kalibre edildi; Sadık, Liyakatli, Sıkı ve Cömert bütçe botları eklendi. Kadro, bütçe ve eşik birim testleri `sim_test.gd` içinde. Bütün testler geçti; `--full` 104 hafta TAHTTA, 109 olay.
- **4a.9** `660b557`: Oyuncu/developer rehberi, tasarım sonucu, borç ve durum belgeleri güncellendi. 4a kapısı aşağıda sayılarla kapatıldı.
- **4b.1** `31c7686`: `holding`, düşman yayın/talep/Lena süreleri ve kadro günlüğü eklendi; `SAVE_VERSION=6`, v5→v6 göçü Halden'in kayıtlı gücünden holding üretir. Bütün testler geçti; `--full` 104 hafta TAHTTA, 109 olay; ölçüt botu %83/%45/%16 ile değişmedi.
- **4b.2** `d0eafd7`: Halden'e üç haftada bir İhale Ver eylemi; holding/servet/kasa/ekonomi/maliye ve Halden etkileri, komisyon sırrı. DEVLET sekmesi, kapalı durumlar, ipucu vermeyen önizleme ve autoplay eklendi. `sim_test`, `event_check`, `save_test`, `content_check`, `ui_input_test`, üç autoplay türü ve tempo testi geçti; `--full` tohum 101 hafta 104 TAHTTA, Oligark Rejimi, 109 olay. Masaüstü `dist/phase4b2_shots/1_devlet.png` açılıp gözle kontrol edildi. Ölçüt %83/%45/%16.
- **4b.3** `06d9aa0`: Halden holdingi organik büyür; medya havası sıcak/mesafeli/düşmanca, haftalık etki holding ülke çapında erişime ulaştığında başlar (`HALDEN_MEDIA_REACH=71`). İlk doğrudan katsayılar %81/%53/%31, erişim kalibrasyonu sonrası %80/%43/%18 verdi. Düşman yayını gazete ve TV manşeti ile sütunlarını değiştirir; kişi kartı ve Holding paneli sözel Nüfuz/Medya gösterir; hava değişikliği haftalık özete girer. Bütün işlev testleri geçti; `--full` 104 hafta TAHTTA, Oligark Rejimi, 109 olay. Masaüstü/mobil `dist/phase4b3_shots{,_mobile}/1_halden.png`, `1_holding.png`, `1_dusman_gazete.png`, `1_dusman_tv.png` açılıp gözle kontrol edildi.
- **4b.4** `99788fb`: Halden talep kartı, dört seçenek, 8 hafta asgari aralık, eşik/bağımlılık koşulu, 10 haftalık sıcak yayın, rakip yayın ve olasılıklı savcılık başvurusu eklendi. İçerik `content_labels.json` ve şema denetiminde. İşlev testleri yeşil; `--full` tohum 101 hafta 104 TAHTTA, Oligark Rejimi, 111 olay. Masaüstü/mobil `dist/phase4b4_shots{,_mobile}/1_halden_talep.png` ve mobil `1_halden_talep_secimler.png` gözle kontrol edildi. **Denge henüz kapıda değil:** %72/%41/%25, taban ±3 dışında; eski `halden_ihale` ve `halden_fatura` kartları hâlâ canlı olduğu için 4b.5 birleştirmesinden sonra yeniden ölçülecek. Tempo 97–104 diliminde 0,50 ama yalnız iki yaşayan oyun haftası; daha çok geç oyun örneği gerekli.
- **4b.5** `b981183`: Eski iki Halden kartının seçenekleri tek talep kartında birleşti; `halden_ihale_*` ve `halden_fatura_*` bayrakları ile `liman_komisyonu` sırrı korunuyor. `min_holding/max_holding` koşulları ve iki geç Halden olayı için holding eşikleri eklendi. `event_check`: 172 olay, 0 uyarı; diğer işlev testleri geçti. Ölçüt %71/%50/%22 ile henüz taban ±3 dışında. `--full` tohum 101 87. haftada düştü, 102 104. haftada TAHTTA; 4b kapısı öncesinde düzeltilmeli. Tempo 81–88: 1,34 (38 yaşayan oyun haftası); 89+ örnek çıkmadı.
- **4b.6** `9d7010f`: Dört patronaj olayı (`halden_yayin_kesti`, `ihale_sorusturmasi_sizinti`, `saray_payi_sizdi`, `holding_devrildi`) eklendi; düşman yayın, karşı safa geçen aktör, kesintisiz saray payı koşulları ve holding etkisi doğrulanıyor. `event_check`: 176 olay, 0 uyarı. Bütün işlev testleri geçti; ilk tohum 87. haftada düştüğü ve ölçüt %73/%45/%28 olduğu için **4b kapısı açık**.
- **4b.7** `0d3eb77`: `advice_patron` botu üç haftada bir Halden'e ihale verip taleplere Ver diyor. Sondaj düşman yayın olayı/haftası ve son serveti de yazıyor. Bütün işlev testleri geçti. Ölçüt %73/%45/%28; patron %28/%7/%7. Patronun kayıpları çoğunlukla biriken komisyon sırlarından gelen yetki kaybı (57/72/70 oyun); denge kalibrasyonu gerekli.
- **Geç tempo denetimi** `d4367ec`: `pacing_test.gd` örnek sayısı ve zorluk parametresi alıyor; bitmiş oyunun 105. haftasını saymıyor. Dört bin Kolay tohumda 81–88: 1,40 (8.881 yaşayan oyun haftası), 89–96: 1,09 (1.742), 97–104: **0,60 (97)** bulundu. Önceki 40 tohumluk koşu bu geç dönem açığını saklamıştı.
- **Geç gündem** `301be17`: 97., 100. ve 103. hafta için üç küçük karar eklendi. Aynı dört bin Kolay tohumda 81–88: 1,40 (8.881), 89–96: 1,09 (1.742), 97–104: **1,08 (99)**. `event_check`: 179 olay, 0 uyarı; bütün işlev testleri geçti. Ölçüt %75/%47/%27, patron %26/%8/%6; tohum 101 hâlâ 87. haftada düştü.
- **4b kalibrasyonu** `cece037`, `5621a35`: aynı ihaleden doğan kanıtlar mahkemede tek dosya sayılıyor; yargı baskısı ve medya erişimi zorluk düzeyine göre ayarlandı. Patron botu biriken serveti Dorn'a gizli ödemeyle harcıyor. `sim_test` aynı ihale dosyası ve zorluk etkisini denetliyor. `--full` tohum 101 hafta 104 **TAHTTA**, Oligark Rejimi, 112 olay. Sıkı bütçe botunun Zor'da son çeyrek tercihi `53e375a` ile dengelendi.
- **4b tempo sayacı** `1026073`: Halden talep kartları tempo ölçümüne katılıyor. 1.000 Kolay oyunda 4a tabanı 1,333; 4b 1,357 olay/hafta, fark **+0,024**. 97–104 dilimi **1,04** (258 yaşayan oyun haftası). Bütün dilimler ≥0,80.

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
| **4a kapısı** | **%83** | **%45** | **%16** |
| 4b.1 | %83 | %45 | %16 |
| 4b.2 | %83 | %45 | %16 |
| 4b.3 | %80 | %43 | %18 |
| 4b.4 | %72 | %41 | %25 |
| 4b.5 | %71 | %50 | %22 |
| 4b.6 | %73 | %45 | %28 |
| 4b.7 | %73 | %45 | %28 |
| Geç gündem | %75 | %47 | %27 |
| **4b kapısı** | **%85** | **%47** | **%18** |

### 4b kapısı — `dist/phase4b_gate_full_probe.log`

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| advice_weighted | %85 | %47 | %18 |
| advice_loyal | %87 | %52 | %25 |
| advice_merit | %77 | %42 | %22 |
| advice_austere | %73 | %52 | %23¹ |
| advice_lavish | %81 | %47 | %26 |
| advice_patron | %66 | %33 | %23 |
| advice_dirty | %88 | %42 | %12 |

¹ Son çeyrek tercihi düzeltildikten sonraki `dist/phase4b_austere_trial.log`; önceki değer %27 idi. Ölçüt 4a tabanına göre +2/+2/+2 puan, üç hedef bantta. Strateji botları ölçütü en çok 8 puan aşar, en çok 19 puan geride kalır. Taban son servet 3,9/3,8/4,5; dört kat sınırı 15,6/15,2/18. Ölçüt son serveti 4,5/4,1/4,4; patron 5,8/10,9/9,5. Ölçütte düşman yayın olayı 0,74/0,70/0,34 oyun başına, üç zorluğun birleşik ortalaması **0,59**. Patron botunda Halden'in her talebine Ver dendiği için düşman yayın olayı görülmedi. Patronun yetkisiz kayıp payı 27/27, 49/53, 58/61; 4a tabanındaki ölçütün 3/13, 0/44, 1/67 payından yüksek. Testler `TEST: OK`, `EVENTS: OK (179, 0 uyarı)`, `SAVE: OK`, `CONTENT: OK`, `UI INPUT: OK`, masaüstü/mobil `AUTOPLAY DONE`, `FULLRUN ... 101 ... 104 ... TAHTTA`; tempo ≥0,80. Görseller: `dist/phase4b_gate_patron/1_halden.png`, `1_dusman_gazete.png`, `1_dusman_tv.png` ve `dist/phase4b_gate_demand_mobile/1_halden_talep_secimler.png` açılıp gözle denetlendi.

### 4a kapısı — `dist/phase4a8_gate.log`

| Bot | Kolay | Normal | Zor | Ortalama son kapasite |
|---|---:|---:|---:|---:|
| advice_weighted | %83 | %45 | %16 | 52,3 |
| advice_loyal | %76 | %47 | %20 | 24,9 |
| advice_merit | %65 | %47 | %21 | 75,1 |
| advice_austere | %81 | %38 | %20 | 39,2 |
| advice_lavish | %80 | %40 | %17 | 60,0 |

Ölçüt tabanla aynı ve üç hedef bantta; strateji botları ölçütü en çok 5 puan aşar, en çok 18 puan geride kalır. Arden **darbe girişimi** liyakatli/ölçüt: Kolay 56/35, Normal 67/63, Zor 80/77 (her biri 80 oyun). Toplam 203/240 vs 175/240: +11,7 yüzde puanı. Başarıyla sonuçlanan darbe ayrı sayıldı; hazırlık ve girişim karıştırılmadı. Tempo 73–80: 0,93 (95 yaşayan oyun-haftası), 81–88: 1,25 (4 oyun-haftası), diğer tüm görünen dilimler ≥0,81. Bütün testler yeşil. Masaüstü ve mobil kanıtlar 4a.5/4a.6 satırlarında.

## Açık sorunlar

4b kapısı sayıyla kapandı. 4c rejim, final, başarımlar ve 1.3.0 paketleri henüz yapılmadı. Ayrı taban çalışma ağacı `dist/baseline_worktree` ölçüm için oluşturuldu; temizlenebilir. `export_presets.cfg` kullanıcı değişikliği olarak çalışma ağacında duruyor.

## SIRADAKİ ADIM

4c.1: rejim hesabına holding ve Sadık Ata geçmişini bağla; 80 kampanyalık ölçümde hiçbir rejim %50'yi geçmesin. Ardından oyun sonu, başarımlar, görüntü/test kapısı ve 1.3.0 paketleri. `dist/baseline_worktree` iş bitince `git worktree remove --force` ile temizlenebilir.
