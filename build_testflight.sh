#!/bin/bash

# Script para preparar e fazer build do aplicativo Guide Dose para TestFlight
# Autor: Assistente de Desenvolvimento
# Data: $(date)

set -e  # Para o script se algum comando falhar

echo "🚀 Iniciando preparação para TestFlight..."

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
rm -rf build/
rm -rf ios/build/

# Obter dependências
echo "📦 Instalando dependências..."
flutter pub get

# Gerar código se necessário
echo "🔧 Gerando código..."
cd ios
pod install --repo-update
cd ..

# Build do aplicativo para release
echo "🔨 Fazendo build para release..."
flutter build ios --release --no-codesign

echo "✅ Build concluído!"
echo ""
echo "📋 Próximos passos para TestFlight:"
echo "1. Abra o Xcode: open ios/Runner.xcworkspace"
echo "2. Selecione 'Any iOS Device (arm64)' como destino"
echo "3. Vá em Product > Archive"
echo "4. Quando o Archive estiver pronto, clique em 'Distribute App'"
echo "5. Selecione 'App Store Connect'"
echo "6. Selecione 'Upload'"
echo "7. Siga as instruções para fazer upload para TestFlight"
echo ""
echo "⚠️  Certifique-se de que:"
echo "   - Você está logado no Xcode com sua conta de desenvolvedor"
echo "   - O certificado de distribuição está configurado"
echo "   - O provisioning profile está atualizado"
echo "   - O app está registrado no App Store Connect"
