#!/usr/bin/env python3
"""Anahtarsız fiyat kaynağını fiyatları yazdırmadan doğrular."""

import datetime
import json
import time
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


def fetch_with_retries():
    last_error = None
    for attempt in range(4):
        try:
            request = urllib.request.Request(
                ENDPOINT,
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
            if attempt < 3:
                time.sleep(2 * (attempt + 1))
    raise last_error


try:
    payload = fetch_with_retries()
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
