# Altın Defterim

iOS ve Android için Flutter ile geliştirilen altın portföyü takip ve satış simülasyonu uygulaması.

## Özellikler

- Gram, çeyrek, yarım, tam, Cumhuriyet, 22/18/14 ayar türleriyle alış kaydı
- Genel Para açık fiyat servisinden canlı alış/satış fiyatları; her dakika otomatik yenileme ve aşağı çekerek yenileme
- Satış fiyatına göre portföy değeri, toplam maliyet ve gerçekleşmemiş kâr/zarar
- Tür bazında miktar ve ağırlıklı ortalama maliyet
- Satış miktarı ve fiyatıyla gelir, ayrılan maliyet, kâr/zarar ve kalan miktar simülasyonu
- Alışların `shared_preferences` ile yalnızca cihazda saklanması
- Bağlantı yokken açıkça etiketlenen örnek fiyatlar

> Uygulama gerçek alım/satım yapmaz. Satış simülasyonu kayıtları değiştirmez. Fiyatlar bilgilendirme amaçlıdır; işlem fiyatları kuruma göre değişebilir.

## Çalıştırma

Flutter 3.24 veya daha yeni bir sürüm gerekir.

```sh
flutter pub get
flutter run
```

iOS için macOS ve Xcode gerekir. Android için Android Studio/SDK kullanılabilir. Android 7.0 (API 24) ve üzeri desteklenir.

Android kurulum dosyası üretmek için:

```sh
flutter build apk --release
```

APK, `build/app/outputs/flutter-apk/app-release.apk` konumunda oluşur.

## Test ve analiz

```sh
flutter analyze
flutter test
```

Testler; Türkçe fiyat biçimi çözümleme, portföy/kâr-zarar matematiği, satış sınırları, kalıcı kayıt işlemleri ve alıştan satış simülasyonuna uzanan widget akışını kapsar.

## Fiyat kaynağı

Birincil kaynaklar `https://haremapi.tr/api/prices` ve aynı anahtar/yanıt biçimini kullanan `https://altinapi.com/api/prices` servisleridir. Uygulama erişilebilir olanı otomatik seçer. API anahtarı derleme sırasında `--dart-define=ALTINAPI_KEY=...` ile verilir ve `x-api-key` başlığıyla gönderilir. Anahtar Git deposunda tutulmaz.

Altın API'ye erişilemezse `https://api.genelpara.com/json/?list=altin` yedek kaynak olarak denenir. Her iki servis de yanıt vermezse uygulama bunu gizlemez; “Örnek fiyat” etiketi gösterilir. Fiyat ekranında aktif kaynak görüntülenir.

> Test APK'sına derleme sırasında eklenen anahtarlar deneyimli kullanıcılar tarafından çıkarılabilir. Herkese açık üretim sürümünde anahtar bir backend proxy arkasında tutulmalıdır. Sağlayıcının kullanım koşulları ve erişilebilirliği ayrıca değerlendirilmelidir.
