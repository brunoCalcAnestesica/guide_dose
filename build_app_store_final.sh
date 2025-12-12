#!/bin/bash

# Script para preparar o app Guide Dose para App Store
# Criado em: Janeiro 2025

echo "🚀 Guide Dose - Preparação para App Store"
echo "=========================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script na raiz do projeto Flutter${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Passo 1: Limpando projeto...${NC}"
flutter clean
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro na limpeza${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Projeto limpo${NC}"
echo ""

echo -e "${YELLOW}📦 Passo 2: Instalando dependências...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao instalar dependências${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dependências instaladas${NC}"
echo ""

echo -e "${YELLOW}🔍 Passo 3: Verificando código...${NC}"
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️ Avisos de análise encontrados (não crítico)${NC}"
fi
echo ""

echo -e "${YELLOW}🏗️ Passo 4: Compilando para iOS (Release)...${NC}"
flutter build ios --release --no-codesign
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro na compilação iOS${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Build iOS concluído${NC}"
echo ""

echo -e "${GREEN}=========================================="
echo "✅ APP PRONTO PARA APP STORE!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}📱 Informações do Build:${NC}"
echo "   • Bundle ID: com.companyname.medcalc"
echo "   • Versão: 2.0.0 (Build 1)"
echo "   • Nome: Guide Dose"
echo ""
echo -e "${YELLOW}📝 Próximos Passos:${NC}"
echo "   1. Abrir no Xcode:"
echo -e "      ${GREEN}open ios/Runner.xcworkspace${NC}"
echo ""
echo "   2. No Xcode:"
echo "      • Selecione 'Any iOS Device (arm64)'"
echo "      • Product > Archive"
echo "      • Distribute App > App Store Connect"
echo ""
echo "   3. Consulte o guia completo:"
echo -e "      ${GREEN}cat GUIA_UPLOAD_APP_STORE.md${NC}"
echo ""
echo -e "${GREEN}🎉 Boa sorte com a publicação!${NC}"

