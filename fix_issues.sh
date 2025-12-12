#!/bin/bash

echo "🔧 Corrigindo problemas específicos do GuideDose..."

# 1. Corrigir CocoaPods
echo "🍎 Corrigindo CocoaPods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 2. Verificar se o Android build.gradle está correto
echo "🤖 Verificando configuração Android..."
if grep -q "com.companyname.medcalc.maui" android/app/build.gradle.kts; then
    echo "❌ Package name incorreto encontrado! Corrigindo..."
    sed -i '' 's/com\.companyname\.medcalc\.maui/com.medcalk.medcalc.medcalc/g' android/app/build.gradle.kts
    echo "✅ Package name corrigido!"
else
    echo "✅ Package name Android está correto!"
fi

# 3. Limpar e reconstruir
echo "🧹 Limpando projeto..."
flutter clean
flutter pub get

# 4. Verificar se há erros de análise
echo "🔍 Verificando erros de código..."
flutter analyze

echo "✅ Correções aplicadas!"
echo ""
echo "📱 Para testar:"
echo "   flutter run --debug"
echo ""
echo "🚀 Para fazer build de produção:"
echo "   ./build_and_deploy.sh"
