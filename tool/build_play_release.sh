#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f android/key.properties ]]; then
  echo "Hata: android/key.properties bulunamadı."
  echo "android/key.properties.example dosyasını kopyalayıp yükleme anahtarınızı tanımlayın."
  exit 1
fi

flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
mkdir -p store
cp build/app/outputs/bundle/release/app-release.aab store/altin-defterim-release.aab

echo "Google Play yükleme paketi hazır: store/altin-defterim-release.aab"
