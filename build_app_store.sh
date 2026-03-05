#!/bin/bash

# =============================================================================
# Script de Build para Apple App Store - Guide Dose
# =============================================================================
# Este script prepara e compila o aplicativo Guide Dose para submissão
# na Apple App Store.
#
# Autor: Bruno Daroz
# Última atualização: Janeiro 2026
# =============================================================================

set -e  # Para o script se algum comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Banner
echo ""
echo "======================================================"
echo "       Guide Dose - Build para App Store"
echo "======================================================"
echo ""

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    print_error "Erro: pubspec.yaml não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Mostrar versão atual
VERSION=$(grep "version:" pubspec.yaml | head -1 | sed 's/version: //')
print_step "Versão atual: $VERSION"
echo ""

# Passo 1: Limpar builds anteriores
print_step "Passo 1/6: Limpando builds anteriores..."
flutter clean > /dev/null 2>&1
rm -rf build/ > /dev/null 2>&1
rm -rf ios/build/ > /dev/null 2>&1
rm -rf ios/.symlinks/ > /dev/null 2>&1
rm -rf ios/Pods/ > /dev/null 2>&1
print_success "Builds anteriores limpos"

# Passo 2: Obter dependências
print_step "Passo 2/6: Instalando dependências Flutter..."
flutter pub get > /dev/null 2>&1
print_success "Dependências Flutter instaladas"

# Passo 3: Instalar pods
print_step "Passo 3/6: Instalando CocoaPods..."
cd ios
pod install --repo-update > /dev/null 2>&1
cd ..
print_success "CocoaPods instalados"

# Passo 4: Build do aplicativo
print_step "Passo 4/6: Compilando para iOS Release..."
flutter build ios --release --no-codesign
print_success "Build iOS concluído"

# Passo 5: Verificar arquivos importantes
print_step "Passo 5/6: Verificando arquivos de configuração..."

# Verificar Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    print_success "Info.plist encontrado"
else
    print_error "Info.plist não encontrado!"
    exit 1
fi

# Verificar PrivacyInfo.xcprivacy
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    print_success "PrivacyInfo.xcprivacy encontrado"
else
    print_warning "PrivacyInfo.xcprivacy não encontrado - pode ser necessário para App Store"
fi

# Verificar ExportOptions.plist
if [ -f "ios/ExportOptions.plist" ]; then
    print_success "ExportOptions.plist encontrado"
else
    print_warning "ExportOptions.plist não encontrado"
fi

# Verificar ícones
ICON_COUNT=$(ls -1 ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$ICON_COUNT" -ge "15" ]; then
    print_success "Ícones do app encontrados ($ICON_COUNT imagens)"
else
    print_warning "Número de ícones pode estar incompleto ($ICON_COUNT encontrados)"
fi

# Passo 6: Instruções finais
print_step "Passo 6/6: Preparação concluída!"

echo ""
echo "======================================================"
echo "              BUILD CONCLUÍDO COM SUCESSO"
echo "======================================================"
echo ""
echo "Próximos passos para submeter na App Store:"
echo ""
echo "1. Abra o Xcode:"
echo "   ${BLUE}open ios/Runner.xcworkspace${NC}"
echo ""
echo "2. No Xcode:"
echo "   - Selecione 'Any iOS Device (arm64)' como destino"
echo "   - Verifique o Team e Signing"
echo "   - Vá em Product > Archive"
echo ""
echo "3. No Organizer (abre automaticamente após Archive):"
echo "   - Clique em 'Distribute App'"
echo "   - Selecione 'App Store Connect'"
echo "   - Escolha 'Upload' para enviar diretamente"
echo "   - Siga as instruções na tela"
echo ""
echo "4. No App Store Connect (https://appstoreconnect.apple.com):"
echo "   - Vá para 'Meus Apps' > 'Guide Dose'"
echo "   - Crie uma nova versão (se necessário)"
echo "   - Preencha as informações de lançamento"
echo "   - Selecione o build enviado"
echo "   - Envie para revisão"
echo ""
echo "======================================================"
echo "           CHECKLIST PRÉ-SUBMISSÃO"
echo "======================================================"
echo ""
echo "[ ] Screenshots para iPhone (6.7\", 6.5\", 5.5\")"
echo "[ ] Screenshots para iPad (12.9\", 11\")"
echo "[ ] Descrição do app (até 4000 caracteres)"
echo "[ ] Palavras-chave (até 100 caracteres)"
echo "[ ] URL da política de privacidade"
echo "[ ] URL de suporte"
echo "[ ] Informações de contato"
echo "[ ] Categoria do app (Medical)"
echo "[ ] Classificação etária"
echo "[ ] Notas para revisão (se necessário)"
echo ""
echo "======================================================"

# Abrir Xcode automaticamente?
read -p "Deseja abrir o Xcode agora? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    open ios/Runner.xcworkspace
fi
