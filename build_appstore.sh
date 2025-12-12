#!/bin/bash

# Script para preparar e fazer build do aplicativo Guide Dose para App Store
# Autor: Assistente de Desenvolvimento
# Data: $(date)

set -e  # Para o script se algum comando falhar

echo "🚀 Iniciando preparação para App Store..."

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto Flutter"
    exit 1
fi

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não está instalado ou não está no PATH"
    exit 1
fi

# Verificar se o Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Erro: Xcode não está instalado"
    exit 1
fi

echo "✅ Verificações iniciais concluídas"

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
rm -rf build/
rm -rf ios/build/

# Obter dependências
echo "📦 Instalando dependências..."
flutter pub get

# Verificar se há problemas no código
echo "🔍 Verificando código..."
flutter analyze

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
echo "📋 Próximos passos para App Store:"
echo "1. Abra o Xcode: open ios/Runner.xcworkspace"
echo "2. Selecione 'Any iOS Device (arm64)' como destino"
echo "3. Vá em Product > Archive"
echo "4. Quando o Archive estiver pronto, clique em 'Distribute App'"
echo "5. Selecione 'App Store Connect'"
echo "6. Selecione 'Upload'"
echo "7. Siga as instruções para fazer upload para App Store Connect"
echo ""
echo "⚠️  Certifique-se de que:"
echo "   - Você está logado no Xcode com sua conta de desenvolvedor"
echo "   - O certificado de distribuição está configurado"
echo "   - O provisioning profile está atualizado"
echo "   - O app está registrado no App Store Connect"
echo "   - O Bundle ID 'com.companyname.medcalc' está registrado"
echo "   - A versão $(grep 'version:' pubspec.yaml | cut -d' ' -f2) está configurada"
echo ""
echo "📱 Informações do App:"
echo "   - Nome: Guide Dose"
echo "   - Bundle ID: com.companyname.medcalc"
echo "   - Versão: $(grep 'version:' pubspec.yaml | cut -d' ' -f2)"
echo "   - Team ID: Z9CACSUCBA"
