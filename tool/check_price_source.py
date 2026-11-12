#!/usr/bin/env python3
"""Anahtarsız Truncgil kaynaklarını fiyatları yazdırmadan doğrular."""

import datetime
import json
import time
import urllib.request

ENDPOINTS = (
    "https://finans.truncgil.com/today.json",
    "https://finans.truncgil.com/v4/today.json",
)
REQUIRED = {
    "gram": ("gram-altin", "GRA"),
    "quarter": ("ceyrek-altin", "CEYREKALTIN"),
    "half": ("yarim-altin", "YARIMALTIN"),
    "full": ("tam-altin", "TAMALTIN"),
    "republic": ("cumhuriyet-altini", "CUMHURIYETALTINI"),
    "22": ("22-ayar-bilezik", "YIA"),
    "18": ("18-ayar-altin", "18AYARALTIN"),
    "14": ("14-ayar-altin", "14AYARALTIN"),
}


def number(value):
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        return float(value.replace(".", "").replace(",", "."))
    return 0


def fetch_with_retries(endpoint):
    last_error = None
    for attempt in range(3):
        try:
            request = urllib.request.Request(
                endpoint,
                headers={
                    "Accept": "application/json",
                    "User-Agent": (
                        "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 "
                        "(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36"
                    ),
                },
            )
            with urllib.request.urlopen(request, timeout=20) as response:
                return json.load(response)
        except Exception as error:
            last_error = error
            if attempt < 2:
                time.sleep(2 * (attempt + 1))
    raise last_error


def validate(payload):
    for name, aliases in REQUIRED.items():
        found = False
        for alias in aliases:
            item = payload.get(alias)
            if not isinstance(item, dict):
                continue
            buying = number(item.get("Buying", item.get("Alış")))
            selling = number(item.get("Selling", item.get("Satış")))
            found = found or (buying > 0 and selling > 0)
        if not found:
            raise ValueError(f"Geçerli fiyat bulunamadı: {name}")
    return datetime.datetime.strptime(
        payload["Update_Date"], "%Y-%m-%d %H:%M:%S"
    )


errors = []
for endpoint in ENDPOINTS:
    try:
        updated_at = validate(fetch_with_retries(endpoint))
        print(
            f"Truncgil Finans doğrulandı ({endpoint}): 8 altın türü, "
            f"kaynak zamanı {updated_at.isoformat()}+03:00."
        )
        break
    except Exception as error:
        errors.append(f"{endpoint} → {error}")
else:
    print("::error::Anahtarsız fiyat kaynakları doğrulanamadı: " + " | ".join(errors))
    raise SystemExit(1)
