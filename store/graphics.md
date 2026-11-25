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
| Telefon ekran görüntüsü | ✅ (min 2, en çok 8) | 16:9 veya 9:16, 320–3840 px, 8 MB altı | `store/screenshots/` — 10 dosya hazır |
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

---

## Telefon ekran görüntüleri

`store/screenshots/` — her dil için 5 görsel, 1080×1920 (tam 9:16), PNG, ~0,35 MB.

| # | Türkçe dosya | İngilizce dosya | İçerik |
|---|---|---|---|
| 1 | `tr-01-portfoy.png` | `en-01-portfolio.png` | Portföy özeti: toplam değer, kâr/zarar, varlık kartları |
| 2 | `tr-02-piyasalar.png` | `en-02-markets.png` | Piyasalar: 8 altın türü alış/satış tablosu |
| 3 | `tr-03-satis-formu.png` | `en-03-sale-form.png` | Satış simülasyonu formu |
| 4 | `tr-04-satis-sonucu.png` | `en-04-sale-result.png` | Simülasyon sonucu: kâr hesabı |
| 5 | `tr-05-gece-modu.png` | `en-05-dark-mode.png` | Koyu tema |

### Nasıl üretiliyor

Görseller **gerçek uygulama widget'larından** render edilir — ekran görüntüsü kırpma veya
sahte tasarım yok:

```bash
GENERATE_STORE_SCREENSHOTS=1 flutter test --update-goldens test/store_screenshots_test.dart
```

Test dosyası:

- 1080×1920 fiziksel tuval ve 432×768 mantıksal telefon düzeni kurar
- Demo portföy (4 alış) ve sabit fiyat listesi enjekte eder — böylece her çalıştırmada
  aynı görüntüler elde edilir
- Roboto ve Cupertino ikon fontlarını SDK/pub cache içinden yükler (aksi hâlde test
  ortamı her glifi kutu olarak çizer)
- Türkçe ve İngilizce geçişleri, koyu tema ve simülasyon sonucunu gerçek etkileşimlerle açar

CI'daki `store-screenshots` işi her push'ta görselleri yeniden üretir, boyut/oran
doğrulaması yapar ve değişiklik varsa dala işler.

### Play Console'a yükleme

**Ana mağaza girişi → Telefon ekran görüntüleri** alanına sırayla
`tr-01` … `tr-05` yükle. **Dil çevirileri → English** altına `en-01` … `en-05` yükle.
Play ilk görseli arama sonuçlarında küçük resim olarak kullanır; 1. görsel portföy özeti
olduğu için doğru seçim.
