#!/usr/bin/env python3
"""Seçilen ana görselden Android, iOS ve Play Store ikonlarını üretir."""

import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

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

feature = Image.new("RGB", (1024, 500), "#252422")
icon = resize(390)
feature.paste(icon, (590, 55))
draw = ImageDraw.Draw(feature)
font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
small_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
title = ImageFont.truetype(font_path, 47)
subtitle = ImageFont.truetype(small_path, 24)
draw.text((58, 165), "ALTIN DEFTERİM", font=title, fill="#F4C86A")
draw.text((60, 238), "Altın portföyünüz, her an yanınızda", font=subtitle, fill="#F7F2E7")
feature.save(store / "play-feature-graphic.png", optimize=True)
print("Android, iOS ve Play Store görselleri üretildi.")
