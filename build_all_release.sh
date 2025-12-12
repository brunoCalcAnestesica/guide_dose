#!/bin/bash

# =========================================
# Guide Dose - Build Completo (Android + iOS)
# =========================================

set -e  # Sair em caso de erro

echo "🚀 Guide Dose - Build Completo para Produção"
echo "============================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script do diretório raiz do projeto!${NC}"
    exit 1
fi

echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}    GUIDE DOSE - PREPARAÇÃO COMPLETA${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Este script irá:"
echo "  ✅ Limpar builds anteriores"
echo "  ✅ Verificar código"
echo "  ✅ Compilar Android (AAB + APK)"
echo "  ✅ Compilar iOS (se estiver no macOS)"
echo ""
read -p "Deseja continuar? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}❌ Build cancelado${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📦 Fase 1: Limpeza e Preparação${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

flutter clean
flutter pub get

echo ""
echo -e "${BLUE}🔍 Fase 2: Análise de Código${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

flutter analyze --no-fatal-infos

echo ""
echo -e "${BLUE}🤖 Fase 3: Build Android${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

./build_android_release.sh

# Verificar se estamos no macOS para build iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo -e "${BLUE}🍎 Fase 4: Build iOS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    ./build_ios_release.sh
else
    echo ""
    echo -e "${YELLOW}⚠️  Build iOS pulado (não está no macOS)${NC}"
fi

echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ BUILD COMPLETO FINALIZADO!${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📊 RESUMO:${NC}"
echo ""

# Android
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
    echo -e "${GREEN}✅ Android AAB:${NC} $AAB_SIZE"
else
    echo -e "${RED}❌ Android AAB não encontrado${NC}"
fi

if [ -f "build/app/outputs/apk/release/app-release.apk" ]; then
    APK_SIZE=$(du -h "build/app/outputs/apk/release/app-release.apk" | cut -f1)
    echo -e "${GREEN}✅ Android APK:${NC} $APK_SIZE"
else
    echo -e "${RED}❌ Android APK não encontrado${NC}"
fi

# iOS (se estiver no macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "build/ios/iphoneos/Runner.app" ]; then
        echo -e "${GREEN}✅ iOS App:${NC} Pronto para Archive"
    else
        echo -e "${YELLOW}⚠️  iOS App: Compile via Xcode${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}📝 PRÓXIMOS PASSOS:${NC}"
echo ""
echo "1. Android (Google Play):"
echo "   - Upload: build/app/outputs/bundle/release/app-release.aab"
echo "   - Console: https://play.google.com/console"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "2. iOS (App Store):"
    echo "   - Xcode já foi aberto"
    echo "   - Faça: Product → Archive"
    echo "   - Console: https://appstoreconnect.apple.com"
    echo ""
fi

echo "3. Consulte o guia completo:"
echo -e "   ${BLUE}cat GUIA_PUBLICACAO_COMPLETO.md${NC}"
echo ""
echo -e "${GREEN}🎉 Boa sorte com a publicação!${NC}"

