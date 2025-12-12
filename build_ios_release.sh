#!/bin/bash

# =========================================
# Guide Dose - Build iOS Release
# =========================================

set -e  # Sair em caso de erro

echo "🍎 Guide Dose - Build iOS Release"
echo "=================================="
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

# Verificar se estamos no macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Erro: Build iOS só pode ser feito no macOS!${NC}"
    exit 1
fi

# Verificar se o Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Erro: Xcode não encontrado!${NC}"
    echo "Instale o Xcode pela App Store."
    exit 1
fi

echo -e "${BLUE}📦 Passo 1/5: Limpando builds anteriores...${NC}"
flutter clean

echo -e "${BLUE}📥 Passo 2/5: Obtendo dependências...${NC}"
flutter pub get

echo -e "${BLUE}🍎 Passo 3/5: Instalando pods do iOS...${NC}"
cd ios
pod install --repo-update
cd ..

echo -e "${BLUE}🔍 Passo 4/5: Analisando código...${NC}"
flutter analyze --no-fatal-infos

echo -e "${BLUE}🏗️  Passo 5/5: Compilando iOS Release...${NC}"
flutter build ios --release --verbose --no-codesign

echo ""
echo -e "${GREEN}✅ BUILD CONCLUÍDO COM SUCESSO!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 PRÓXIMOS PASSOS - ARCHIVE NO XCODE:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Abrir workspace no Xcode:"
echo -e "   ${BLUE}open ios/Runner.xcworkspace${NC}"
echo ""
echo "2. No Xcode:"
echo "   ✅ Selecione: 'Any iOS Device (arm64)' no topo"
echo "   ✅ Vá em: Product → Archive"
echo "   ✅ Aguarde a compilação (5-10 minutos)"
echo ""
echo "3. No Organizer (abre automaticamente):"
echo "   ✅ Clique em: Distribute App"
echo "   ✅ Escolha: App Store Connect"
echo "   ✅ Escolha: Upload"
echo "   ✅ Aceite as opções padrão"
echo "   ✅ Clique em: Upload"
echo "   ✅ Aguarde (5-15 minutos)"
echo ""
echo "4. No App Store Connect:"
echo "   - Acesse: https://appstoreconnect.apple.com"
echo "   - Aguarde processamento do build (10-30 min)"
echo "   - Configure informações do app"
echo "   - Envie para revisão"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}📝 INFORMAÇÕES DO BUILD:${NC}"
echo ""
echo "   Bundle ID: com.companyname.medcalc"
echo "   Nome: Guide Dose"
echo "   Versão: 2.0.0 (1)"
echo "   Team ID: Z9CACSUCBA"
echo ""
echo "Consulte o guia completo:"
echo -e "${BLUE}cat GUIA_PUBLICACAO_COMPLETO.md${NC}"
echo ""
echo -e "${GREEN}🎉 Pronto para fazer Archive!${NC}"
echo ""
echo "Executando Xcode..."
open ios/Runner.xcworkspace

