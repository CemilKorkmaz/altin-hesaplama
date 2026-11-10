#!/usr/bin/env python3
"""Altın API erişimini anahtarı veya fiyatları yazdırmadan doğrular."""

import json
import os
import sys
import urllib.request

api_key = os.environ.get("ALTINAPI_KEY", "")
if not api_key:
    print("ALTINAPI_KEY verilmedi; canlı API kontrolü atlandı.")
    sys.exit(0)

request = urllib.request.Request(
    "https://altinapi.com/api/prices",
    headers={"Accept": "application/json", "x-api-key": api_key},
)
with urllib.request.urlopen(request, timeout=15) as response:
    payload = json.load(response)

if payload.get("stale") is True:
    raise SystemExit("Altın API verisi şu anda güncel değil (stale).")

data = payload.get("data")
if not isinstance(data, list):
    raise SystemExit("Altın API beklenen data listesini döndürmedi.")

symbols = {
    item.get("symbol")
    for item in data
    if isinstance(item, dict) and item.get("bid") is not None and item.get("ask") is not None
}
required = {"ALTIN", "CEYREK_YENI", "YARIM_YENI", "TAM_YENI", "AYAR22", "AYAR14"}
missing = sorted(required - symbols)
if missing:
    raise SystemExit(f"Altın API gerekli sembolleri döndürmedi: {', '.join(missing)}")

print(f"Altın API doğrulandı: {len(symbols)} fiyat sembolü erişilebilir.")
