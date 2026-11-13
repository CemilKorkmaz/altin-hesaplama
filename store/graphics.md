# Mağaza görselleri (Play Console)

| Dosya | Boyut | Nerede kullanılır | Dil |
|---|---|---|---|
| `store/icon-512.png` | 512×512 PNG (alfa yok) | Uygulama simgesi (App icon) | Her iki dilde aynı |
| `store/play-feature-graphic.png` | 1024×500 PNG | Özellik grafiği (Feature graphic) | 🇹🇷 Türkçe |
| `store/play-feature-graphic-en.png` | 1024×500 PNG | Özellik grafiği (Feature graphic) | 🇬🇧 English |

> Play, özellik grafiği ve ekran görüntülerini **dil bazında** ister. Simge tüm dillerde
> aynıdır; iki kez yüklemek gerekmez (yüklerseniz de aynı dosyayı kullanın).

---

## Play Console'a yükleme sırası

1. **Mağazayı büyüt → Mağaza varlığı → Ana mağaza girişi**
2. Önce **varsayılan dil** (Türkçe) girişini doldur:
   - **Uygulama simgesi**: `store/icon-512.png`
   - **Özellik grafiği**: `store/play-feature-graphic.png`
3. **Dil çevirileri → Çeviri ekle → English (en-US)**
   - **Özellik grafiği**: `store/play-feature-graphic-en.png`
   - Simge alanını boş bırakabilirsin (varsayılan dilden devralınır)

## Play teknik kuralları

| Görsel | Zorunlu | Biçim | Not |
|---|---|---|---|
| Uygulama simgesi | ✅ | 512×512 PNG, 32-bit, **saydamlık yok** | Alpha kanalı varsa reddedilir |
| Özellik grafiği | ✅ | 1024×500 PNG/JPEG, alpha **yasak** | Metin küçük kalmamalı; çok önemli alanlar kenarlardan uzak dursun |
| Telefon ekran görüntüsü | ✅ (min 2) | 16:9 veya 9:16, 320–3840 px | Henüz üretilmedi |
| 7 inç / 10 inç tablet | ❌ opsiyonel | — | Yalnızca tablet desteği açılırsa |
| Tanıtım videosu | ❌ opsiyonel | YouTube bağlantısı | Gerekmiyor |

**Bizim dosyalarımız:** simge RGB (alfa yok) ✅ · özellik grafiği RGB (alfa yok) ✅

## Tasarım kararları

- **Simge:** koyu antrasit zemin + altın sikke + açık defter + yükselen grafik çizgisi.
  Defter = kayıt, sikke = altın, grafik = değer/kâr-zarar.
- **Özellik grafiği:** solda altın renkli başlık ve üç madde, sağda yuvarlatılmış köşeli simge.
  Zemin `#252422`, başlık `#F4C86A`, metin `#F7F2E7`.
- **Dil:** aynı kompozisyon iki dilde; yalnızca metinler değişiyor.

## Yeniden üretme

```bash
python3 -m venv .icon-venv
.icon-venv/bin/pip install Pillow
.icon-venv/bin/python tool/generate_icons.py
```

Betik tek çalıştırmada üretir:

- Android mipmap'leri (`mdpi`–`xxxhdpi`) + adaptive icon XML'i + `colors.xml`
- iOS `AppIcon.appiconset` içindeki bütün boyutlar
- `store/icon-512.png`, `store/play-feature-graphic.png`, `store/play-feature-graphic-en.png`

Kaynak görsel: `assets/branding/app_icon_source.png` (2048×2048). Değiştirmek isterseniz
yalnızca bu dosyayı güncelleyip betiği tekrar çalıştırmak yeterli.
