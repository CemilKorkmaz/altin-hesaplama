#!/usr/bin/env python3
"""Seçilen ana görselden Android, iOS ve Play Store ikonlarını üretir."""

import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/branding/app_icon_source.png"
source = Image.open(SOURCE).convert("RGB")


def resize(size):
    return source.resize((size, size), Image.Resampling.LANCZOS)


android_sizes = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
for density, size in android_sizes.items():
    directory = ROOT / f"android/app/src/main/res/mipmap-{density}"
    directory.mkdir(parents=True, exist_ok=True)
    resize(size).save(directory / "ic_launcher.png", optimize=True)
    resize(size).save(directory / "ic_launcher_foreground.png", optimize=True)

adaptive = ROOT / "android/app/src/main/res/mipmap-anydpi-v26"
adaptive.mkdir(parents=True, exist_ok=True)
for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
    (adaptive / name).write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""
    )
values = ROOT / "android/app/src/main/res/values"
(values / "colors.xml").write_text(
    """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#252422</color>
</resources>
"""
)

contents_path = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
contents = json.loads(contents_path.read_text())
for item in contents["images"]:
    points = float(item["size"].split("x")[0])
    scale = int(item["scale"][0])
    resize(round(points * scale)).save(contents_path.parent / item["filename"], optimize=True)

store = ROOT / "store"
store.mkdir(exist_ok=True)
resize(512).save(store / "icon-512.png", optimize=True)

FEATURE_BG = "#252422"
GOLD = "#F4C86A"
CREAM = "#F7F2E7"
MUTED = "#C9BFAB"
BOLD_FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
REGULAR_FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def rounded_icon(size: int, radius_ratio: float = 0.22) -> Image.Image:
    """Kaynak görseli yuvarlatılmış köşeli, alfa kanallı kare simgeye dönüştürür."""
    icon = source.resize((size, size), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=int(size * radius_ratio), fill=255
    )
    icon.putalpha(mask)
    return icon


def build_feature(locale: str) -> None:
    """1024x500 Play özellik grafiği. Metinler dil bazlıdır, simge aynıdır."""
    copy = {
        "tr": {
            "title": "ALTIN DEFTERİM",
            "subtitle": "Altın portföyünüz, her an yanınızda",
            "bullets": ["Portföy takibi", "Kâr/zarar hesabı", "Satış simülasyonu"],
            "filename": "play-feature-graphic.png",
        },
        "en": {
            "title": "ALTIN DEFTERİM",
            "subtitle": "Your gold portfolio, always with you",
            "bullets": ["Portfolio tracking", "Profit/loss", "Sale simulation"],
            "filename": "play-feature-graphic-en.png",
        },
    }[locale]

    canvas = Image.new("RGB", (1024, 500), FEATURE_BG)
    draw = ImageDraw.Draw(canvas)

    # Soldan hafif altın parıltısı (kenarı yumuşatılmış)
    glow = Image.new("L", (1024, 500), 0)
    ImageDraw.Draw(glow).ellipse((-300, -190, 500, 660), fill=52)
    glow = glow.filter(ImageFilter.GaussianBlur(70))
    canvas.paste(Image.new("RGB", (1024, 500), "#8a6b23"), (0, 0), glow)

    # Sağdaki yuvarlatılmış simge + ince altın çerçeve
    icon = rounded_icon(330)
    frame = Image.new("RGBA", (330, 330), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle(
        (1, 1, 328, 328), radius=int(330 * 0.22), outline=(244, 200, 106, 70), width=2
    )
    icon = Image.alpha_composite(icon, frame)
    canvas.paste(icon, (628, 85), icon)

    title_font = ImageFont.truetype(BOLD_FONT, 46)
    subtitle_font = ImageFont.truetype(REGULAR_FONT, 23)
    bullet_font = ImageFont.truetype(REGULAR_FONT, 21)

    draw.text((56, 118), copy["title"], font=title_font, fill=GOLD)
    draw.text((58, 186), copy["subtitle"], font=subtitle_font, fill=CREAM)

    # İnce altın ayırıcı ve üç madde
    draw.line((58, 240, 300, 240), fill="#6b5a33", width=2)
    y = 268
    for item in copy["bullets"]:
        draw.ellipse((60, y + 8, 70, y + 18), fill=GOLD)
        draw.text((84, y), item, font=bullet_font, fill=MUTED)
        y += 44

    canvas.save(store / copy["filename"], optimize=True)


store = ROOT / "store"
store.mkdir(exist_ok=True)
resize(512).save(store / "icon-512.png", optimize=True)
build_feature("tr")
build_feature("en")
print("Android, iOS ve Play Store görselleri üretildi (TR + EN feature graphic).")
