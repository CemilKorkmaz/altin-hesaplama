#!/usr/bin/env python3
"""Fiyat API erişimini anahtarı veya fiyatları yazdırmadan doğrular."""

import json
import os
import sys
import urllib.error
import urllib.request

ENDPOINTS = (
    "https://haremapi.tr/api/prices",
    "https://altinapi.com/api/prices",
)
REQUIRED = {"ALTIN", "CEYREK_YENI", "YARIM_YENI", "TAM_YENI", "AYAR22", "AYAR14"}


def check_endpoint(endpoint, api_key):
    request = urllib.request.Request(
        endpoint,
        headers={
            "Accept": "application/json",
            "User-Agent": (
                "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36"
            ),
            "x-api-key": api_key,
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        body = error.read(500).decode("utf-8", errors="replace")
        body = body.replace(api_key, "[gizlendi]").replace("\n", " ")
        raise ValueError(f"HTTP {error.code}: {body}") from error

    if payload.get("stale") is True:
        raise ValueError("Veri şu anda güncel değil (stale).")
    data = payload.get("data")
    if not isinstance(data, list):
        raise ValueError("Beklenen data listesi dönmedi.")

    symbols = {
        item.get("symbol")
        for item in data
        if isinstance(item, dict)
        and item.get("bid") is not None
        and item.get("ask") is not None
    }
    missing = sorted(REQUIRED - symbols)
    if missing:
        available = ", ".join(sorted(str(symbol) for symbol in symbols))
        raise ValueError(
            f"Gerekli semboller eksik: {', '.join(missing)}. Gelenler: {available}"
        )
    return len(symbols)


def main():
    api_key = os.environ.get("ALTINAPI_KEY", "")
    if not api_key:
        print("ALTINAPI_KEY verilmedi; canlı API kontrolü atlandı.")
        return

    errors = []
    for endpoint in ENDPOINTS:
        try:
            count = check_endpoint(endpoint, api_key)
            print(f"Fiyat API doğrulandı ({endpoint}): {count} sembol erişilebilir.")
            return
        except Exception as error:
            errors.append(f"{endpoint} → {error}")

    print("::error::Fiyat API doğrulaması başarısız: " + " | ".join(errors))
    sys.exit(1)


if __name__ == "__main__":
    main()
