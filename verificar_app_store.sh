#!/bin/bash

# Script de Verificação Final para App Store
# Guide Dose - Janeiro 2025

echo "🔍 VERIFICAÇÃO FINAL - GUIDE DOSE"
echo "=================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contador de verificações
TOTAL=0
PASSED=0

# Função para verificar
check() {
    ((TOTAL++))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

echo -e "${BLUE}📋 Verificando Configurações...${NC}"
echo ""

# 1. Verificar pubspec.yaml
if grep -q "version: 2.0.0+1" pubspec.yaml; then
    check 0 "Versão configurada (2.0.0+1)"
else
    check 1 "Versão configurada"
fi

# 2. Verificar Bundle ID iOS
if grep -q "com.companyname.medcalc" ios/Runner.xcodeproj/project.pbxproj; then
    check 0 "Bundle ID iOS correto"
else
    check 1 "Bundle ID iOS"
fi

# 3. Verificar Bundle ID Android
if grep -q 'applicationId = "com.companyname.medcalc"' android/app/build.gradle.kts; then
    check 0 "Bundle ID Android correto"
else
    check 1 "Bundle ID Android"
fi

# 4. Verificar ícones iOS
if [ -f "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
    check 0 "Ícone 1024x1024 presente"
else
    check 1 "Ícone 1024x1024"
fi

# 5. Verificar Info.plist
if grep -q "Guide Dose" ios/Runner/Info.plist; then
    check 0 "Nome do app no Info.plist"
else
    check 1 "Nome do app"
fi

# 6. Verificar PrivacyInfo
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    check 0 "PrivacyInfo.xcprivacy presente"
else
    check 1 "PrivacyInfo.xcprivacy"
fi

# 7. Verificar permissões
if grep -q "NSMicrophoneUsageDescription" ios/Runner/Info.plist; then
    check 0 "Permissão de microfone declarada"
else
    check 1 "Permissão de microfone"
fi

# 8. Verificar assets PCR
if [ -f "assets/pcr/sounds/click.mp3" ]; then
    check 0 "Assets PCR presentes"
else
    check 1 "Assets PCR"
fi

# 9. Verificar código sem erros
echo ""
echo -e "${BLUE}🔍 Analisando código...${NC}"
flutter analyze lib/pcr.dart lib/home.dart lib/main.dart > /tmp/flutter_analyze.log 2>&1
if [ $? -eq 0 ]; then
    check 0 "Código sem erros críticos"
else
    check 1 "Código sem erros críticos"
fi

echo ""
echo -e "${BLUE}🏗️ Testando Build iOS...${NC}"
flutter build ios --release --no-codesign > /tmp/flutter_build.log 2>&1
if [ $? -eq 0 ]; then
    check 0 "Build iOS compilado com sucesso"
    
    # Verificar tamanho do build
    BUILD_SIZE=$(du -sh build/ios/iphoneos/Runner.app 2>/dev/null | cut -f1)
    if [ -n "$BUILD_SIZE" ]; then
        echo -e "${GREEN}   └─ Tamanho: $BUILD_SIZE${NC}"
    fi
else
    check 1 "Build iOS"
fi

echo ""
echo "=================================="
echo -e "${BLUE}📊 RESULTADO FINAL${NC}"
echo "=================================="
echo -e "Verificações passadas: ${GREEN}$PASSED${NC}/${TOTAL}"
echo ""

if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}✅ APP PRONTO PARA APP STORE!${NC}"
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
    echo "   3. Consulte:"
    echo -e "      ${GREEN}cat GUIA_UPLOAD_APP_STORE.md${NC}"
    echo ""
    echo -e "${GREEN}🎉 Tudo pronto para publicação!${NC}"
else
    echo -e "${RED}⚠️ Algumas verificações falharam${NC}"
    echo "   Revise os itens marcados acima"
    echo ""
    echo "   Logs detalhados:"
    echo "   • Análise: /tmp/flutter_analyze.log"
    echo "   • Build: /tmp/flutter_build.log"
fi

echo ""

