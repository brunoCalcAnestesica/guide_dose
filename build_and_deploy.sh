#!/bin/bash

echo "🚀 Iniciando build e deploy do GuideDose..."

# Limpar projeto
echo "🧹 Limpando projeto..."
flutter clean

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get

# Corrigir CocoaPods para iOS
echo "🍎 Corrigindo CocoaPods para iOS..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Verificar se há erros
echo "🔍 Verificando erros..."
flutter analyze

# Build para Android
echo "🤖 Fazendo build para Android..."
flutter build apk --release

# Build para iOS
echo "🍎 Fazendo build para iOS..."
flutter build ios --release

echo "✅ Build completo! Os arquivos estão em:"
echo "   Android: build/app/outputs/flutter-apk/app-release.apk"
echo "   iOS: build/ios/iphoneos/Runner.app"
echo ""
echo "📱 Para fazer upload:"
echo "   Android: Use o Google Play Console"
echo "   iOS: Use o Xcode ou Transporter"
