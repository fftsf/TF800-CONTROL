#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERREUR: la compilation d'une application macOS exige macOS + Xcode."
  exit 2
fi
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERREUR: Xcode et ses outils en ligne de commande sont requis."
  exit 2
fi
OUT="$ROOT/build"
rm -rf "$OUT"
mkdir -p "$OUT/dmg-root"
xcodebuild -project "TF800Control.xcodeproj" -scheme "TF800 CONTROL" -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "$OUT/DerivedData" \
  ARCHS='x86_64 arm64' ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO build
APP="$OUT/DerivedData/Build/Products/Release/TF800 CONTROL.app"
[[ -d "$APP" ]] || { echo "Application compilée introuvable"; exit 3; }
cp -R "$APP" "$OUT/dmg-root/"
ln -s /Applications "$OUT/dmg-root/Applications"
hdiutil create -volname "TF800 CONTROL" -srcfolder "$OUT/dmg-root" -ov -format UDZO "$ROOT/TF800_CONTROL_Installer.dmg"
echo "Créé: $ROOT/TF800_CONTROL_Installer.dmg"
echo "App: $APP"
