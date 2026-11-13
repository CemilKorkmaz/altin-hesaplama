# Tanıtım görselleri

Ekran görüntülerinden üretilen, perspektifli telefon mockup'lı reklam/sosyal medya görselleri.

| Format | Boyut | Kullanım |
|---|---|---|
| `*-story.png` | 1080×1920 (9:16) | Instagram / TikTok story, Reels kapağı, Play "tanıtım" |
| `*-square.png` | 1080×1080 (1:1) | Instagram gönderisi, Facebook, WhatsApp durum |
| `*-banner.png` | 1200×628 | Web başlığı, e-posta imzası, link önizlemesi |

Önizleme: `00-onizleme.png`

## Senaryolar

| # | Türkçe | İngilizce | Mesaj |
|---|---|---|---|
| 1 | `tr-01-tanitim` | `en-01-promo` | Altın birikiminiz tek ekranda — canlı fiyat, kâr/zarar, koyu tema |
| 2 | `tr-02-satis` | `en-02-sale` | Satmadan önce hesaplayın — simülasyon, kayıtlar değişmez |
| 3 | `tr-03-gece-modu` | `en-03-dark-mode` | Göz yormayan koyu tema — tek dokunuş, kalıcı tercih |
| 4 | `tr-04-piyasalar` | `en-04-markets` | 8 altın türü tek bakışta — otomatik yenileme |

## Tasarım

- Zemin: koyu antrasit üzerine altın radyal parıltı + ince grain dokusu
- Telefon: koyu gövde, yuvarlatılmış ekran, kamera adası, yan tuş, yumuşak gölge
- Perspektif: her senaryoda değişen ±3–6° yatay eğim (statik düz mockup değil)
- Tipografi: Roboto Black / Bold / Medium / Regular
- Palet: `#252422` zemin · `#F4C86A` altın · `#F7F2E7` krem · `#B0A591` soluk metin
- Her görselde köşe etiketi (YENİ / SİMÜLASYON / GECE MODU / CANLI PİYASA) ve madde işaretli
  kısa açıklamalar

## Yeniden üretme

```bash
python3 -m venv .icon-venv
.icon-venv/bin/pip install Pillow numpy
.icon-venv/bin/python tool/generate_promo.py
```

Betik `store/screenshots/*.png` dosyalarını girdi olarak kullanır. Ekran görüntüleri
değiştiğinde tanıtım görselleri de tek komutla yenilenir.

> **Önemli:** Görsellerdeki tüm fiyat ve tutarlar demo verisidir. Hiçbir görsel
> "kazanç garantisi" veya yatırım tavsiyesi içermez; uygulama mağaza metniyle
> tutarlı olarak gerçek işlem yapmadığını belirtir.
