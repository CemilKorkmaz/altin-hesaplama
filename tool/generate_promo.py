#!/usr/bin/env python3
"""Ekran görüntülerinden perspektifli, etiketli tanıtım görselleri üretir.

Girdi : store/screenshots/*.png  (1080x1920)
Çıktı : store/promo/*.png

Kullanım:
    python3 -m venv .icon-venv
    .icon-venv/bin/pip install Pillow numpy
    .icon-venv/bin/python tool/generate_promo.py
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SHOTS = ROOT / "store" / "screenshots"
OUT = ROOT / "store" / "promo"
FONT_DIR = Path("/home/user/fontwork/fonts")

# --- marka paleti ---------------------------------------------------------
INK = (37, 36, 34)
INK_DEEP = (23, 22, 20)
GOLD = (244, 200, 106)
GOLD_DEEP = (201, 150, 44)
CREAM = (247, 242, 231)
MUTED = (176, 165, 145)

FONTS = {
    "light": "Roboto-Light.ttf",
    "regular": "Roboto-Regular.ttf",
    "medium": "Roboto-Medium.ttf",
    "bold": "Roboto-Bold.ttf",
    "black": "Roboto-Black.ttf",
}


def font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_DIR / FONTS[weight]), size)


# --- perspektif -----------------------------------------------------------


def perspective_coefficients(source, target):
    """Kaynak dörtgenden hedef dörtgene eşleme katsayıları (PIL standardı)."""
    matrix = []
    for (sx, sy), (dx, dy) in zip(source, target):
        matrix.append([dx, dy, 1, 0, 0, 0, -sx * dx, -sx * dy])
        matrix.append([0, 0, 0, dx, dy, 1, -sy * dx, -sy * dy])
    a = np.array(matrix, dtype=float)
    b = np.array([c for point in source for c in point], dtype=float)
    return np.linalg.solve(a, b)


def warp(image: Image.Image, source, target, size) -> Image.Image:
    coefficients = perspective_coefficients(source, target)
    return image.transform(
        size,
        Image.Transform.PERSPECTIVE,
        coefficients,
        resample=Image.Resampling.BICUBIC,
    )


def rounded_mask(size, radius) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    return mask


def drop_shadow(alpha: Image.Image, blur: int, opacity: int, offset=(0, 0)) -> Image.Image:
    shadow = Image.new("RGBA", alpha.size, (0, 0, 0, 0))
    shadow.paste((0, 0, 0, opacity), (0, 0), alpha)
    if offset != (0, 0):
        shifted = Image.new("RGBA", alpha.size, (0, 0, 0, 0))
        shifted.paste(shadow, offset)
        shadow = shifted
    return shadow.filter(ImageFilter.GaussianBlur(blur))


def phone_mockup(
    screenshot: Image.Image,
    width: int,
    tilt: float = 0.0,
    lean: float = 0.0,
    bezel: int = 14,
    radius_ratio: float = 0.13,
) -> Image.Image:
    """Ekran görüntüsünü çerçeveli bir telefon gövdesine yerleştirir.

    tilt: üst-alt farkı (y ekseninde döndürme, negatif = sağa yatık)
    lean: sol-sağ farkı (x ekseninde döndürme)
    Dönen gövde, tuvalden taşmayacak şekilde otomatik ölçeklenir.
    """
    shot_h = int(width * screenshot.height / screenshot.width)
    body_w, body_h = width, shot_h + bezel * 2
    radius = int(body_w * radius_ratio)

    # Gövde: koyu çerçeve + ince metal kenar
    body = Image.new("RGBA", (body_w, body_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(body)
    draw.rounded_rectangle(
        (0, 0, body_w - 1, body_h - 1), radius=radius, fill=(24, 23, 21, 255)
    )
    draw.rounded_rectangle(
        (1, 1, body_w - 2, body_h - 2),
        radius=radius - 1,
        outline=(72, 67, 58, 255),
        width=2,
    )

    # Ekranı yuvarlatılmış maskeyle yerleştir
    screen_size = (body_w - bezel * 2, body_h - bezel * 2)
    screen = screenshot.convert("RGBA").resize(screen_size, Image.Resampling.LANCZOS)
    screen.putalpha(rounded_mask(screen_size, max(4, radius - bezel)))
    body.paste(screen, (bezel, bezel), screen)

    # Kamera adası
    island_w, island_h = int(body_w * 0.30), max(6, int(body_w * 0.055))
    island_x = (body_w - island_w) // 2
    draw.rounded_rectangle(
        (island_x, bezel // 2 + 6, island_x + island_w, bezel // 2 + 6 + island_h),
        radius=island_h // 2,
        fill=(8, 8, 8, 255),
    )

    # Yan tuşlar
    button_w = max(3, body_w // 90)
    draw.rounded_rectangle(
        (body_w - 3, int(body_h * 0.22), body_w + button_w - 3, int(body_h * 0.34)),
        radius=button_w,
        fill=(52, 49, 43, 255),
    )

    if tilt == 0 and lean == 0:
        return body

    # Perspektif için dört köşeyi kaydır
    dx_tilt = body_w * tilt
    dy_lean = body_h * lean
    corners = [
        (dx_tilt * 0.55, 0),                        # sol üst
        (body_w + dx_tilt * 0.45, dy_lean * 0.5),   # sağ üst
        (0, body_h - dy_lean * 0.5),                # sol alt
        (body_w, body_h),                           # sağ alt
    ]
    pad = int(max(abs(dx_tilt), abs(dy_lean)) + 40)
    canvas = Image.new("RGBA", (body_w + pad * 2, body_h + pad * 2), (0, 0, 0, 0))
    warped = warp(
        body,
        [(0, 0), (body_w, 0), (0, body_h), (body_w, body_h)],
        [(x + pad, y + pad) for x, y in corners],
        canvas.size,
    )
    canvas.alpha_composite(warped)
    return canvas.crop(canvas.getbbox() or (0, 0, canvas.width, canvas.height))


# --- arka plan ------------------------------------------------------------


def radial_background(
    size,
    center,
    inner=(58, 46, 26),
    outer=(16, 15, 14),
    power=2.4,
) -> Image.Image:
    w, h = size
    yy, xx = np.mgrid[0:h, 0:w]
    dist = np.sqrt((xx - center[0]) ** 2 + (yy - center[1]) ** 2)
    dist /= dist.max()
    t = np.clip(dist, 0, 1) ** power
    inner_arr = np.array(inner, dtype=float)
    outer_arr = np.array(outer, dtype=float)
    rgb = inner_arr + (outer_arr - inner_arr) * t[..., None]
    return Image.fromarray(rgb.astype(np.uint8), "RGB").convert("RGBA")


def add_grain(image: Image.Image, strength: int = 6) -> Image.Image:
    array = np.array(image.convert("RGB"), dtype=np.int16)
    noise = np.random.default_rng(7).normal(0, strength, array.shape[:2])[..., None]
    array = np.clip(array + noise, 0, 255).astype(np.uint8)
    return Image.fromarray(array, "RGB").convert("RGBA")


# --- metin yardımcıları ---------------------------------------------------


def text_width(draw: ImageDraw.ImageDraw, text: str, f: ImageFont.FreeTypeFont) -> int:
    box = draw.textbbox((0, 0), text, font=f)
    return box[2] - box[0]


def wrap(draw, text: str, f, max_width: int) -> list[str]:
    words, lines, current = text.split(), [], ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if text_width(draw, candidate, f) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def pill_size(draw, text, f, pad_x=22, pad_y=11):
    return text_width(draw, text, f) + pad_x * 2, f.size + pad_y * 2


def pill(draw, xy, text, f, fill, text_fill, pad_x=22, pad_y=11, radius=None):
    x, y = xy
    w = text_width(draw, text, f) + pad_x * 2
    h = f.size + pad_y * 2
    r = radius if radius is not None else h // 2
    draw.rounded_rectangle((x, y, x + w, y + h), radius=r, fill=fill)
    draw.text((x + pad_x, y + pad_y - f.size * 0.06), text, font=f, fill=text_fill)
    return w, h


def bullet(draw, xy, text, f, color, dot=GOLD, gap=18, dot_d=11):
    x, y = xy
    cy = y + f.size * 0.55
    draw.ellipse((x, cy - dot_d / 2, x + dot_d, cy + dot_d / 2), fill=dot)
    draw.text((x + dot_d + gap, y), text, font=f, fill=color)


# --- senaryolar -----------------------------------------------------------

SCENES = {
    "tr": [
        {
            "shot": "tr-01-portfoy.png",
            "file": "tr-01-tanitim.png",
            "badge": "YENİ",
            "title": "Altın birikiminiz,\ntek ekranda",
            "subtitle": "Portföyünüzün değerini, maliyetini ve\nkâr/zararını anında görün.",
            "chips": ["Canlı fiyatlar", "Kâr/zarar", "Koyu tema"],
            "tilt": -0.055,
            "lean": 0.02,
        },
        {
            "shot": "tr-04-satis-sonucu.png",
            "file": "tr-02-satis.png",
            "badge": "SİMÜLASYON",
            "title": "Satmadan önce\nhesaplayın",
            "subtitle": "Satış fiyatını ve miktarı girin;\nkazancınızı görün. Kayıtlarınız değişmez.",
            "chips": ["Gerçek işlem yok", "Anında sonuç"],
            "tilt": 0.06,
            "lean": -0.02,
        },
        {
            "shot": "tr-05-gece-modu.png",
            "file": "tr-03-gece-modu.png",
            "badge": "GECE MODU",
            "title": "Göz yormayan\nkoyu tema",
            "subtitle": "Tek dokunuşla açılır, tercihiniz\ncihazınızda saklanır.",
            "chips": ["Tek dokunuş", "Kalıcı tercih"],
            "tilt": -0.05,
            "lean": 0.015,
        },
        {
            "shot": "tr-02-piyasalar.png",
            "file": "tr-04-piyasalar.png",
            "badge": "CANLI PİYASA",
            "title": "8 altın türü,\ntek bakışta",
            "subtitle": "Gram, çeyrek, yarım, tam, Cumhuriyet\nve 14/18/22 ayar bilezik fiyatları.",
            "chips": ["Otomatik yenileme", "Anahtarsız kaynak"],
            "tilt": 0.055,
            "lean": -0.015,
        },
    ],
    "en": [
        {
            "shot": "en-01-portfolio.png",
            "file": "en-01-promo.png",
            "badge": "NEW",
            "title": "Your gold savings,\non one screen",
            "subtitle": "See your portfolio value, cost and\nprofit or loss at a glance.",
            "chips": ["Live prices", "Profit/loss", "Dark mode"],
            "tilt": -0.055,
            "lean": 0.02,
        },
        {
            "shot": "en-04-sale-result.png",
            "file": "en-02-sale.png",
            "badge": "SIMULATION",
            "title": "Plan before\nyou sell",
            "subtitle": "Enter a sale price and amount to see\nyour gain. Your records stay unchanged.",
            "chips": ["No real trades", "Instant result"],
            "tilt": 0.06,
            "lean": -0.02,
        },
        {
            "shot": "en-05-dark-mode.png",
            "file": "en-03-dark-mode.png",
            "badge": "DARK MODE",
            "title": "Easy on\nthe eyes",
            "subtitle": "One tap to switch, and your choice\nis remembered on your device.",
            "chips": ["One tap", "Saved preference"],
            "tilt": -0.05,
            "lean": 0.015,
        },
        {
            "shot": "en-02-markets.png",
            "file": "en-04-markets.png",
            "badge": "LIVE MARKET",
            "title": "Eight gold types,\none glance",
            "subtitle": "Gram, quarter, half, full, Republic\nand 14/18/22K gold prices.",
            "chips": ["Auto refresh", "Keyless source"],
            "tilt": 0.055,
            "lean": -0.015,
        },
    ],
}


def build_story(scene: dict, size=(1080, 1920)) -> Image.Image:
    """9:16 sosyal medya / reklam görseli (story, reels cover)."""
    w, h = size
    canvas = radial_background(size, (int(w * 0.18), int(h * 0.08)))
    canvas = add_grain(canvas)

    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # --- üst: rozet ---
    badge_font = font("bold", 28)
    bw, bh = pill_size(draw, scene["badge"], badge_font)
    draw.rounded_rectangle((84, 104, 84 + bw, 104 + bh), radius=bh // 2, fill=GOLD)
    draw.text((84 + 22, 104 + 11), scene["badge"], font=badge_font, fill=INK)

    # --- başlık ---
    title_font = font("black", 88)
    y = 178
    for line in scene["title"].split("\n"):
        draw.text((84, y), line, font=title_font, fill=CREAM)
        y += int(88 * 1.14)

    # --- alt metin ---
    sub_font = font("regular", 34)
    y += 10
    for line in scene["subtitle"].split("\n"):
        draw.text((86, y), line, font=sub_font, fill=MUTED)
        y += int(34 * 1.5)

    # --- alt bölge ölçüleri (etiketler + marka) ---
    chip_font = font("medium", 26)
    chip_h = 50
    brand_font = font("bold", 30)
    note_font = font("regular", 23)

    tagline_y = h - 66
    brand_y = tagline_y - 50
    chip_y = brand_y - chip_h - 30

    # --- telefon: metin ile etiketler arasına sığdır ---
    screenshot = Image.open(SHOTS / scene["shot"])
    available = chip_y - 26 - (y + 6)
    phone = phone_mockup(
        screenshot,
        width=int(w * 0.62),
        tilt=scene["tilt"],
        lean=scene["lean"],
    )
    if phone.height > available:
        scale = available / phone.height
        phone = phone.resize(
            (int(phone.width * scale), int(phone.height * scale)),
            Image.Resampling.LANCZOS,
        )

    phone_top = max(y + 6, chip_y - 26 - phone.height)
    phone_x = (w - phone.width) // 2 + int(w * 0.03)
    shadow = drop_shadow(phone.split()[3], blur=50, opacity=140, offset=(0, 26))
    canvas.alpha_composite(shadow, (phone_x, phone_top))
    canvas.alpha_composite(phone, (phone_x, phone_top))

    # --- etiketler ---
    chips = scene["chips"]
    widths = [text_width(draw, c, chip_font) + 38 for c in chips]
    gap = 12
    total = sum(widths) + gap * (len(chips) - 1)
    x = (w - total) // 2
    for chip, cw in zip(chips, widths):
        draw.rounded_rectangle(
            (x, chip_y, x + cw, chip_y + chip_h),
            radius=chip_h // 2,
            fill=(255, 255, 255, 18),
            outline=(255, 255, 255, 46),
        )
        draw.text((x + 19, chip_y + 10), chip, font=chip_font, fill=CREAM)
        x += cw + gap

    # --- marka ---
    label = "ALTIN DEFTERİM"
    lw = text_width(draw, label, brand_font)
    draw.text(((w - lw) // 2, brand_y), label, font=brand_font, fill=GOLD)

    tagline = (
        "Altın portföyünüz, her an yanınızda"
        if scene["file"].startswith("tr")
        else "Your gold portfolio, always with you"
    )
    nw = text_width(draw, tagline, note_font)
    draw.text(((w - nw) // 2, tagline_y), tagline, font=note_font, fill=MUTED)

    canvas.alpha_composite(layer)
    return canvas.convert("RGB")


def build_banner(scene: dict, size=(1200, 628)) -> Image.Image:
    """Yatay banner: link önizlemesi, web başlığı ve e-posta imzası için."""
    w, h = size
    canvas = radial_background(size, (int(w * 0.12), int(h * 0.14)), power=2.0)
    canvas = add_grain(canvas)

    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # --- telefon: sağda, üstten ve alttan taşacak şekilde ---
    screenshot = Image.open(SHOTS / scene["shot"])
    target_h = int(h * 0.92)
    phone = phone_mockup(screenshot, width=int(target_h * 0.46), tilt=-0.045, lean=0.012)
    if phone.height > target_h:
        scale = target_h / phone.height
        phone = phone.resize(
            (int(phone.width * scale), int(phone.height * scale)),
            Image.Resampling.LANCZOS,
        )
    phone_x = w - phone.width - 52
    phone_y = (h - phone.height) // 2
    shadow = drop_shadow(phone.split()[3], blur=44, opacity=150, offset=(0, 22))
    canvas.alpha_composite(shadow, (phone_x, phone_y))
    canvas.alpha_composite(phone, (phone_x, phone_y))

    # --- metin bloğu: solda ---
    badge_font = font("bold", 23)
    bw = text_width(draw, scene["badge"], badge_font) + 40
    draw.rounded_rectangle((64, 120, 64 + bw, 120 + 46), radius=23, fill=GOLD)
    draw.text((84, 128), scene["badge"], font=badge_font, fill=INK)

    title_font = font("black", 58)
    y = 190
    for line in scene["title"].split("\n"):
        draw.text((64, y), line, font=title_font, fill=CREAM)
        y += int(58 * 1.14)

    sub_font = font("regular", 26)
    y += 14
    for line in scene["subtitle"].split("\n"):
        draw.text((66, y), line, font=sub_font, fill=MUTED)
        y += 38

    # --- ince marka satırı ---
    brand_font = font("bold", 22)
    draw.line((66, h - 96, w - 66, h - 96), fill=(255, 255, 255, 28), width=1)
    draw.text((64, h - 74), "ALTIN DEFTERİM", font=brand_font, fill=GOLD)

    canvas.alpha_composite(layer)
    return canvas.convert("RGB")


def build_square(scene: dict, size=(1080, 1080)) -> Image.Image:
    """1:1 Instagram / Facebook gönderisi."""
    w, h = size
    canvas = radial_background(size, (int(w * 0.5), int(h * 0.06)), power=2.2)
    canvas = add_grain(canvas)

    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    badge_font = font("bold", 25)
    bw = text_width(draw, scene["badge"], badge_font) + 42
    draw.rounded_rectangle(((w - bw) // 2, 62, (w + bw) // 2, 62 + 50), radius=25, fill=GOLD)
    draw.text(((w - text_width(draw, scene["badge"], badge_font)) // 2, 71),
              scene["badge"], font=badge_font, fill=INK)

    title_font = font("black", 68)
    y = 148
    for line in scene["title"].split("\n"):
        lw = text_width(draw, line, title_font)
        draw.text(((w - lw) // 2, y), line, font=title_font, fill=CREAM)
        y += int(68 * 1.14)

    # --- telefon: metin ile alt marka satırı arasına sığdır ---
    brand_font = font("bold", 27)
    brand_y = h - 74
    top_limit = y + 18
    bottom_limit = brand_y - 30
    available = bottom_limit - top_limit

    screenshot = Image.open(SHOTS / scene["shot"])
    phone = phone_mockup(screenshot, width=int(w * 0.46), tilt=-0.04, lean=0.012)
    if phone.height > available:
        scale = available / phone.height
        phone = phone.resize(
            (int(phone.width * scale), int(phone.height * scale)),
            Image.Resampling.LANCZOS,
        )
    phone_x = (w - phone.width) // 2
    phone_y = bottom_limit - phone.height
    shadow = drop_shadow(phone.split()[3], blur=36, opacity=120, offset=(0, 16))
    canvas.alpha_composite(shadow, (phone_x, phone_y))
    canvas.alpha_composite(phone, (phone_x, phone_y))

    label = "ALTIN DEFTERİM"
    lw = text_width(draw, label, brand_font)
    draw.text(((w - lw) // 2, brand_y), label, font=brand_font, fill=GOLD)

    canvas.alpha_composite(layer)
    return canvas.convert("RGB")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for locale, scenes in SCENES.items():
        for scene in scenes:
            story = build_story(scene)
            story.save(OUT / scene["file"].replace(".png", "-story.png"), optimize=True)

            banner = build_banner(scene)
            banner.save(OUT / scene["file"].replace(".png", "-banner.png"), optimize=True)

            square = build_square(scene)
            square.save(OUT / scene["file"].replace(".png", "-square.png"), optimize=True)
            print(f"üretildi: {locale} {scene['file']}")


if __name__ == "__main__":
    main()
