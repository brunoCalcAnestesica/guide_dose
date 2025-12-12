#!/bin/bash

# Script de Build para Android - Guide Dose
# Este script gera o App Bundle (.aab) para upload na Google Play Store

set -e  # Parar em caso de erro

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Build Android - Guide Dose"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar se o keystore existe
if [ ! -f "android/upload-keystore.jks" ]; then
    echo "❌ ERRO: Keystore não encontrado!"
    echo ""
    echo "Você precisa criar o keystore primeiro."
    echo "Siga as instruções em GUIA_KEYSTORE_ANDROID.md"
    echo ""
    echo "Comando rápido:"
    echo "  keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    echo ""
    exit 1
fi

# Verificar se key.properties existe
if [ ! -f "android/key.properties" ]; then
    echo "❌ ERRO: Arquivo key.properties não encontrado!"
    echo ""
    echo "Você precisa criar o arquivo android/key.properties"
    echo "Use android/key.properties.example como modelo"
    echo ""
    exit 1
fi

echo "✅ Keystore encontrado"
echo "✅ key.properties encontrado"
echo ""

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
echo ""

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get
echo ""

# Verificar se há problemas
echo "🔍 Analisando código..."
flutter analyze --no-fatal-infos
echo ""

# Build do App Bundle para release
echo "🏗️  Iniciando build do App Bundle..."
echo ""
flutter build appbundle --release

# Verificar se o build foi bem sucedido
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✅ BUILD CONCLUÍDO COM SUCESSO!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📦 App Bundle gerado em:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
    
    # Mostrar informações do arquivo
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        SIZE=$(ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $5}')
        echo "📏 Tamanho do arquivo: $SIZE"
        echo ""
    fi
    
    echo "🚀 Próximos passos:"
    echo "   1. Acesse: https://play.google.com/console"
    echo "   2. Crie um novo aplicativo ou acesse o existente"
    echo "   3. Vá em 'Produção' > 'Criar nova versão'"
    echo "   4. Faça upload do arquivo app-release.aab"
    echo "   5. Preencha as informações e publique"
    echo ""
    echo "📖 Consulte GOOGLE_PLAY_STORE_READY.md para mais detalhes"
    echo ""
    
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ❌ ERRO NO BUILD"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Verifique os erros acima e tente novamente."
    echo ""
    exit 1
fi

