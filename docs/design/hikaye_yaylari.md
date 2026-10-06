# Karakter hikâye yayları — Faz 3 tasarımı

Tarih: 2026-10-06. Kaynak: Tasarım Özeti §10–11, §20–22; `docs/design/ikinci_yil.md`.

## Amaç ve oyuncu kararı
Dokuz güç merkezi, rastgele kartların konuşan isimleri olmaktan çıkıp oyuncunun önceki tavrını hatırlayan kişiler olur. Her yay üç sahne sürer: yükseliş, sınav, dönüm noktası. Sınavdaki tercih iki ayrı dönüm noktası kartından birini açar. İlk sahne 20–60. haftalara dağıtılır; ikinci ve üçüncü sahne birkaç hafta sonra gelir. Oyuncu her sahnede kimin alan açtığını, kimin bedel ödediğini seçer. Son sahne önceki karara açıkça değinir.

## Dokuz yay

| Kişi, başlangıç | Yükseliş | Sınav | Dönüm noktası: güven / kopuş |
|---|---|---|---|
| Arden, 20 | Subay atama listesi; profesyonel sertlik | Sınırdaki emrin siyasi kullanımı | Emir zincirini savunur / subaylar kraldan önce generali dinler |
| Voss, 25 | Bilgi masası büyür; soğuk hesap | Bir dosyanın kime açılacağı | Kayıtları usule teslim eder / özel arşiv kurar |
| Kessler, 30 | Bütçe cetveli titizlikle hazırlanır | Saklı açığın açıklanması | Defteri imzalar / korkuyla boş satır bırakır |
| Halden, 35 | Kanallar sarayın sesini taşır; cömert teklif | Yayın bağımsızlığı ve ihale | Açık sözleşme / ekranı siyasi baskıya çevirme |
| Lena, 40 | Kaynaklardan ilk büyük dosya gelir | Kaynak kimliği için baskı | Kaynağı korur / basın saraya sırt döner |
| Dorn, 45 | Saray kapısında randevu ağı | Kimin içeri alınacağı | Kayıtları açar / koridorları kendi pazarı yapar |
| Prens, 50 | Hanedan töreninde yer ister; kırgın | Veraset ve aile sofrası | Kardeşini kamu önünde destekler / ayrı saray çevresi kurar |
| Brandt, 55 | Muhalefet mahallelerde örgütlenir | Meydanın şiddete dönmesi | Sandığı savunur / sokak başka yol arar |
| Falk, 60 | Mahkeme bağımsızlık bildirisi | Saray dosyasının usulü | Kurumu savunur / yargı saraydan uzaklaşır |

## Veri ve dallanma
Her kişi için `yay_<id>_yukselis`, `_sinav`, `_sadakat`, `_kopus` kayıtları kullanılır (36 kayıt, oynanışta üç sahne). İlk kararların tümü ortak bir bayrak koyar; sınav `flag_age` ile gecikir. Sınavın ilk tercihi `_sadakat`, diğer tercihleri ve ertelemesi `_kopus` kartını açar. Son kartlar `needs_flag`/`any_flag` ile ayrışır ve birbirini `blocks_flag` ile kapatır. `actor_min` ya da `min_stat` uygun yerde aynı yaydaki önceki davranışı ve mevcut tutumu destekler; oyuncunun göremediği eşiği tek geçiş kapısı yapmayız. Bir aktör ayrılırsa zincir bitmesi doğaldır; ilk sahneler `alive` ister.

Her kart mevcut `art/events` görseline bağlanır. Yeni çizim beklemek zinciri geciktirmemeli; özel portre ya da sahne gerektiren anlar sonradan `ART_PROMPTS.md` içine alınabilir.

## Denge ve bilgi sınırı
Kararlar çoğunlukla mevcut bedel alanlarını (servet, ekonomi, muhalefet, huzursuzluk, bağlılık) az miktarda etkiler. Arden ve Prens'in güç/hırsına doğrudan artış verilmez: önceki aktör hamleleri sondajında küçük artış bile Normal kazanmayı düşürmüştü. Yaylar olay havuzundaki iki kart/hafta sınırına tabidir; 5 haftalık başlangıç aralığı yığılmayı azaltır. İsimli metinler oyuncuya yeni gizli rakam açmaz; görülen davranış ve kendi tercihini hatırlatır. Sır ve ihanet anlatısı etkisinin tersi yönde iddia kurmamalı.

## Kabul
`event_check` 0 uyarıyla geçer; `sim_test` ulaşılabilirliği denetler. İlk yaylar 20–60. haftada başlar, tüm yollar uygun bir kararla oynanabilir, seçenek ve erteleme çıkmaz oluşturmaz. Her mantıksal eklemeden sonra iki ayrı 80 kampanyalık sondajda ölçüt bot Kolay %70–85, Normal %35–55, Zor %15–30 bandında kalır. Sorun varsa bir seferde tek etki grubunu ayarla.
