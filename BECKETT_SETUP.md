# Beckett MCP Setup Tamamlandı ✅

## Kurulum Özeti

Beckett Godot MCP sunucusu kuruldu. Token koruması yerel ortamda etkinleştirilmelidir.

### 📁 Kurulu Bileşenler

- ✅ **Beckett Addon**: `addons/beckett/` klasöründe
- ✅ **Project Ayarları**: `project.godot` güncellendi
- ✅ **Claude Code Yapılandırması**: `.mcp.json` hazırlandı
- **Token Koruması**: Yerel ortamda yapılandırılmalı

---

## 🔐 Token Koruması Ayarları

Token'ı Beckett panelinden yerel olarak oluşturun. Erişim anahtarını Git'e eklemeyin.

### Yapılandırılmış Güvenlik Seçenekleri

**project.godot dosyasında:**
```ini
[beckett]
autostart=true                      # Otomatik başlat
auto_write_client_config=true       # Config otomatik yaz
readonly=false                      # Yazma izinleri etkin
confirm_destructive=true            # Yıkıcı komutlar onay gerektirir
effort=2                            # AI çabalandırma seviyesi (1-4)
```

### .mcp.json dosyasında:
- HTTP endpoint: `http://127.0.0.1:8770/mcp`
- Token koruması yerel ortamda yapılandırılmalı

---

## 🚀 Başlamak İçin

### 1. Godot'u Açın
```bash
godot --path .
```

### 2. Eklentiyi Etkinleştirin
- **Project → Project Settings → Plugins**
- Beckett arayın ve **Enable** yapın
- Otomatik olarak `.mcp.json` yazılacak ve Dock panel açılacak

### 3. Claude Code ile Bağlanın
Claude Code otomatik olarak `.mcp.json` okuyacak ve Beckett'e bağlanacak.

---

## 🛡️ Güvenlik Özellikleri

| Özellik | Durum |
|---------|-------|
| Bearer Token Koruması | Yerel ortamda etkinleştirilmeli |
| Localhost-only | ✅ Aktif (127.0.0.1) |
| Yıkıcı Komutlar Onayı | ✅ Aktif |
| SSL/TLS | Localhost için gerekli değil |
| CORS Koruması | ✅ Origin doğrulaması |

---

## 🔧 Ortam Değişkenleri (İsteğe Bağlı)

Eğer farklı ayarlar kullanmak istiyorsanız:

```bash
# Windows PowerShell
$env:BECKETT_TOKEN = "your_custom_token"
$env:BECKETT_PORT = "8770"
$env:BECKETT_READONLY = "0"
$env:BECKETT_CONFIRM_DESTRUCTIVE = "1"
```

```bash
# Windows CMD
set BECKETT_TOKEN=your_custom_token
set BECKETT_PORT=8770
```

---

## 📊 Beckett Özellikleri (Lite Edition)

### Reflection & Discovery
- `get_godot_version` - Godot versiyonunu al
- `find_classes` - Sınıfları ara
- `describe_class` - Sınıf açıklamasını oku
- `find_methods` - Metotları ara

### Scene Authoring (Geri alınabilir)
- `create_node` - Node oluştur
- `delete_node` - Node sil
- `rename_node` - Node'u yeniden adlandır
- `reparent_node` - Hiyerarşiyi değiştir
- `save_scene` - Sahneyi kaydet

### GDScript & C# Dev Loop
- `validate_script` - Komut dosyasını doğrula
- `write_script` - Komut dosyası yaz
- `script_patch` - Komut dosyasını yamala
- `build_csharp` - C# projesini derle

### Runtime Observation (Oyunu Gözlemle)
- `screenshot` - Ekran görüntüsü al
- `get_remote_tree` - Sahne ağacını oku
- `find_nodes` - Node'ları bul
- `runtime_get_property` - Özellikleri oku
- `game_logs` - Oyun loglarını oku

### Run Loop
- `play_scene` - Sahne çalıştır
- `stop_scene` - Sahneyi durdur
- `wait_until` - Koşul için bekle
- `logs_read` - Logları oku

---

## 🎯 Sonraki Adımlar

1. **Godot'u açın** ve Beckett eklentisini enable edin
2. **Claude Code**'da `/mcp` komutu çalıştırın
3. **Beckett panel**'i Dock'ta göreceksiniz
4. **Claude Code** otomatik olarak Beckett'e bağlanacak

---

## 📚 Kaynaklar

- GitHub: https://github.com/beckettlab/beckett-godot-mcp
- Kurulum Detayları: [INSTALL.md](INSTALL.md)
- Lisans: MIT (Lite Edition)

---

**Kurulum Tarihi**: 2026-10-04
**Beckett Versiyonu**: v1.15.2 (Lite Edition)
**Token**: Etkinleştirildi ✅
