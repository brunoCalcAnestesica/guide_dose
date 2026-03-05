#!/bin/bash

# Script para build e upload do Guide Dose para TestFlight.
# Faz o fluxo completo pela CLI (archive + export com uploadSymbols=false + upload),
# evitando o erro "Upload Symbols Failed" do Xcode (dSYM do objective_c.framework).
# Veja TESTFLIGHT_GUIDE.md para pré-requisitos e variáveis de ambiente.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Iniciando build para TestFlight..."

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
rm -rf build/
rm -rf ios/build/

# Obter dependências
echo "📦 Instalando dependências..."
flutter pub get

# Gerar código e pods
echo "🔧 Gerando código..."
cd ios
pod install --repo-update
cd ..

# Build do aplicativo para release
echo "🔨 Fazendo build para release..."
flutter build ios --release --no-codesign

# Archive (gera .xcarchive)
echo "📦 Criando archive..."
xcodebuild archive \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/Runner.xcarchive

# Export (gera IPA sem enviar símbolos; usa ExportOptions.plist com uploadSymbols=false)
echo "📤 Exportando IPA..."
rm -rf build/upload
mkdir -p build/upload
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/upload

# Localizar o IPA gerado (nome pode variar)
IPA_FILE=$(find build/upload -maxdepth 1 -name "*.ipa" -print -quit)
if [ -z "$IPA_FILE" ]; then
  echo "❌ Nenhum arquivo .ipa encontrado em build/upload"
  exit 1
fi

echo "✅ IPA gerado: $IPA_FILE"

# Upload opcional: se APPLE_ID e APPLE_APP_SPECIFIC_PASSWORD estiverem definidos
if [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" ]; then
  echo "📤 Enviando para App Store Connect..."
  xcrun altool --upload-app \
    -f "$IPA_FILE" \
    -t ios \
    -u "$APPLE_ID" \
    -p "$APPLE_APP_SPECIFIC_PASSWORD"
  echo "✅ Upload concluído. O build aparecerá no TestFlight após o processamento."
else
  echo ""
  echo "📋 Para enviar ao TestFlight:"
  echo "   Opção 1 – Variáveis de ambiente e rodar de novo apenas o upload:"
  echo "     export APPLE_ID=\"seu_email@appleid.com\""
  echo "     export APPLE_APP_SPECIFIC_PASSWORD=\"sua-senha-de-app\""
  echo "     xcrun altool --upload-app -f \"$IPA_FILE\" -t ios -u \"\$APPLE_ID\" -p \"\$APPLE_APP_SPECIFIC_PASSWORD\""
  echo ""
  echo "   Opção 2 – Abra o app Transporter (Mac App Store), arraste o IPA para a janela e envie:"
  echo "     $IPA_FILE"
  echo ""
fi
