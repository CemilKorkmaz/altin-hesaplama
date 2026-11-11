#!/usr/bin/env python3
"""Anahtarsız fiyat kaynağını fiyatları yazdırmadan doğrular."""

import datetime
import json
import urllib.request

ENDPOINT = "https://finans.truncgil.com/v4/today.json"
REQUIRED = {
    "GRA",
    "CEYREKALTIN",
    "YARIMALTIN",
    "TAMALTIN",
    "CUMHURIYETALTINI",
    "YIA",
    "18AYARALTIN",
    "14AYARALTIN",
}

request = urllib.request.Request(
    ENDPOINT,
    headers={"Accept": "application/json"},
)
try:
    with urllib.request.urlopen(request, timeout=15) as response:
        payload = json.load(response)

    symbols = {
        symbol
        for symbol, item in payload.items()
        if isinstance(item, dict)
        and isinstance(item.get("Buying"), (int, float))
        and isinstance(item.get("Selling"), (int, float))
        and item["Buying"] > 0
        and item["Selling"] > 0
    }
    missing = sorted(REQUIRED - symbols)
    if missing:
        raise ValueError(f"Gerekli altın sembolleri eksik: {', '.join(missing)}")

    updated_at = datetime.datetime.strptime(
        payload["Update_Date"], "%Y-%m-%d %H:%M:%S"
    )
    print(
        f"Truncgil Finans doğrulandı: {len(REQUIRED)} altın türü, "
        f"kaynak zamanı {updated_at.isoformat()}+03:00."
    )
except Exception as error:
    print(f"::error::Anahtarsız fiyat kaynağı doğrulanamadı: {error}")
    raise SystemExit(1) from error
