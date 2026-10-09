# İngilizce ekran metni taraması

`tools/i18n_dump.gd`, gerçek pencereli Godot oturumunda otomatik kampanya oynatırken UI kontrollerine yerleştirilen metinleri toplar. Başsız çalıştırmayın: başsız testler arayüz metnini denetlemez. Araç dil tercihini ana sahneyi ve içerik tablolarını yüklemeden önce ayarlar; oyun sonu sekmelerini, Hükümdarlık Arşivi/başarımlar penceresini ve autoplay'in açtığı masa, gündem ve medya panellerini tarar. Aynı metnin tekrarları tek satıra iner.

Proje kökünden, pencereli Godot ile:

```powershell
$G = 'C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $G --path . --script res://tools/i18n_dump.gd -- --autoplay --i18n-dump --lang=en --seed=7 --out=dist/i18n_dump_en_loss.tsv
& $G --path . --script res://tools/i18n_dump.gd -- --autoplay --full --i18n-dump --lang=en --out=dist/i18n_dump_en_survival.tsv
```

`--seed=7` rastgele autoplay'in tekrar üretilebilir tohumunu seçer; bu tohum kayıpla biter. `--full`, mevcut dikkatli autoplay akışını çalıştırır; 101–106 aralığından tahtta kalış bulana dek dener. Her iki komutta da `--i18n-dump` autoplay'in kendi çıkışını engeller ki tarayıcı son ekranları dolaşıp dökümü yazabilsin. `--lang=en` yerine argümanı kaldırmak varsayılan Türkçe'yi tarar. `--mobile` Godot penceresini 1067×600 mobil düzene alır.

TSV sütunları görünürlük, kontrol yolu ve metindir. `I18N_TURKISH?` satırları Türkçe karakter veya sık Türkçe sözcük sezgiseliyle bulunan görünür metinlerdir; heuristik olduğundan her satırı inceleyin. Karakter ve sözcük eşleşmesi yokluğu görsel doğrulamanın yerine geçmez. Ekran görüntülerini ayrıca `tests/ui_shots.gd` ile alın.
