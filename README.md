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

iOS için macOS ve Xcode gerekir. Android için Android Studio/SDK kullanılabilir.

## Test ve analiz

```sh
flutter analyze
flutter test
```

Testler; Türkçe fiyat biçimi çözümleme, portföy/kâr-zarar matematiği, satış sınırları, kalıcı kayıt işlemleri ve alıştan satış simülasyonuna uzanan widget akışını kapsar.

## Fiyat kaynağı

`https://api.genelpara.com/json/?list=altin` kullanılır. Servis yanıt vermezse uygulama bunu gizlemez; “Örnek fiyat” etiketi gösterilir. Üretim kullanımında fiyat sağlayıcısının kullanım koşulları ve erişilebilirliği ayrıca değerlendirilmelidir.
