#!/bin/bash

# =========================================
# Guide Dose - Build Android Release
# =========================================

set -e  # Sair em caso de erro

echo "🚀 Guide Dose - Build Android Release"
echo "======================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script do diretório raiz do projeto!${NC}"
    exit 1
fi

# Verificar se o keystore existe
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}⚠️  AVISO: Arquivo key.properties não encontrado!${NC}"
    echo ""
    echo "Para criar o keystore e configurar a assinatura:"
    echo "1. Execute o comando:"
    echo -e "${BLUE}   cd android${NC}"
    echo -e "${BLUE}   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload${NC}"
    echo ""
    echo "2. Crie o arquivo android/key.properties com:"
    echo -e "${BLUE}   storePassword=SUA_SENHA${NC}"
    echo -e "${BLUE}   keyPassword=SUA_SENHA${NC}"
    echo -e "${BLUE}   keyAlias=upload${NC}"
    echo -e "${BLUE}   storeFile=upload-keystore.jks${NC}"
    echo ""
    echo "Consulte GUIA_PUBLICACAO_COMPLETO.md para instruções detalhadas."
    echo ""
    read -p "Deseja continuar mesmo assim? (s/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}❌ Build cancelado${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}📦 Passo 1/5: Limpando builds anteriores...${NC}"
flutter clean

echo -e "${BLUE}📥 Passo 2/5: Obtendo dependências...${NC}"
flutter pub get

echo -e "${BLUE}🔍 Passo 3/5: Analisando código...${NC}"
flutter analyze --no-fatal-infos

echo -e "${BLUE}🏗️  Passo 4/5: Compilando AAB (App Bundle)...${NC}"
flutter build appbundle --release --verbose

echo -e "${BLUE}🏗️  Passo 5/5: Compilando APK...${NC}"
flutter build apk --release --verbose

echo ""
echo -e "${GREEN}✅ BUILD CONCLUÍDO COM SUCESSO!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 ARQUIVOS GERADOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# AAB
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
    echo -e "${GREEN}✅ AAB (Google Play):${NC}"
    echo "   📁 build/app/outputs/bundle/release/app-release.aab"
    echo "   📊 Tamanho: $AAB_SIZE"
    echo ""
else
    echo -e "${RED}❌ AAB não encontrado${NC}"
fi

# APK
if [ -f "build/app/outputs/apk/release/app-release.apk" ]; then
    APK_SIZE=$(du -h "build/app/outputs/apk/release/app-release.apk" | cut -f1)
    echo -e "${GREEN}✅ APK (Distribuição manual):${NC}"
    echo "   📁 build/app/outputs/apk/release/app-release.apk"
    echo "   📊 Tamanho: $APK_SIZE"
    echo ""
else
    echo -e "${RED}❌ APK não encontrado${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}📝 PRÓXIMOS PASSOS:${NC}"
echo ""
echo "1. Testar o APK em dispositivo real:"
echo -e "   ${BLUE}adb install build/app/outputs/apk/release/app-release.apk${NC}"
echo ""
echo "2. Fazer upload do AAB no Google Play Console:"
echo "   - Acesse: https://play.google.com/console"
echo "   - Vá em: Versões de produção > Criar nova versão"
echo "   - Upload: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "3. Consulte o guia completo:"
echo -e "   ${BLUE}cat GUIA_PUBLICACAO_COMPLETO.md${NC}"
echo ""
echo -e "${GREEN}🎉 Boa sorte com a publicação!${NC}"

