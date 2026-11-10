#!/usr/bin/env python3
"""Altın API erişimini anahtarı veya fiyatları yazdırmadan doğrular."""

import json
import os
import sys
import urllib.error
import urllib.request


def check_api():
    api_key = os.environ.get("ALTINAPI_KEY", "")
    if not api_key:
        print("ALTINAPI_KEY verilmedi; canlı API kontrolü atlandı.")
        return

    request = urllib.request.Request(
        "https://altinapi.com/api/prices",
        headers={"Accept": "application/json", "x-api-key": api_key},
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        payload = json.load(response)

    if payload.get("stale") is True:
        raise ValueError("Altın API verisi şu anda güncel değil (stale).")

    data = payload.get("data")
    if not isinstance(data, list):
        raise ValueError("Altın API beklenen data listesini döndürmedi.")

    symbols = {
        item.get("symbol")
        for item in data
        if isinstance(item, dict)
        and item.get("bid") is not None
        and item.get("ask") is not None
    }
    required = {"ALTIN", "CEYREK_YENI", "YARIM_YENI", "TAM_YENI", "AYAR22", "AYAR14"}
    missing = sorted(required - symbols)
    if missing:
        available = ", ".join(sorted(str(symbol) for symbol in symbols))
        raise ValueError(
            f"Gerekli semboller eksik: {', '.join(missing)}. "
            f"Gelen semboller: {available}"
        )

    print(f"Altın API doğrulandı: {len(symbols)} fiyat sembolü erişilebilir.")


try:
    check_api()
except urllib.error.HTTPError as error:
    print(f"::error::Altın API HTTP {error.code} döndürdü. Anahtarı ve paket yetkisini kontrol edin.")
    sys.exit(1)
except Exception as error:
    print(f"::error::Altın API doğrulaması başarısız: {error}")
    sys.exit(1)
