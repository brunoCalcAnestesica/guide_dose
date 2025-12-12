#!/bin/bash

# Script para Enviar Mudanças Locais para o FlutterFlow
# ⚠️ ATENÇÃO: Use com cuidado! O FlutterFlow pode sobrescrever mudanças.

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  ATENÇÃO: Enviar mudanças para o FlutterFlow${NC}"
echo -e "${YELLOW}   O FlutterFlow pode sobrescrever mudanças locais quando você fizer push.${NC}"
echo -e "${YELLOW}   Recomenda-se trabalhar principalmente no FlutterFlow.${NC}"
echo ""
read -p "Tem certeza que deseja continuar? (digite 'sim' para confirmar): " CONFIRM

if [ "$CONFIRM" != "sim" ]; then
    echo "Operação cancelada"
    exit 0
fi

echo ""
echo -e "${BLUE}📤 Sincronizando do Local para FlutterFlow...${NC}"
echo ""

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto Flutter${NC}"
    exit 1
fi

# Verificar se é um repositório Git
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Este diretório não é um repositório Git${NC}"
    echo "   Execute './setup_flutterflow_git.sh' primeiro"
    exit 1
fi

# Verificar se remote flutterflow existe
if ! git remote get-url flutterflow &> /dev/null; then
    echo -e "${RED}❌ Remote 'flutterflow' não configurado${NC}"
    echo "   Execute './setup_flutterflow_git.sh' primeiro"
    exit 1
fi

# Verificar se há mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Há mudanças não commitadas${NC}"
    git status --short
    echo ""
    read -p "Deseja fazer commit dessas mudanças? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        git add .
        read -p "Mensagem do commit: " COMMIT_MSG
        git commit -m "${COMMIT_MSG:-Local changes to sync with FlutterFlow}"
    else
        echo "Por favor, faça commit das mudanças antes de sincronizar"
        exit 1
    fi
fi

# Verificar branch atual
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Branch atual: ${CURRENT_BRANCH}${NC}"

# Verificar qual branch usar (main ou master)
FLUTTERFLOW_BRANCH="main"
if ! git show-ref --verify --quiet refs/remotes/flutterflow/main; then
    FLUTTERFLOW_BRANCH="master"
fi

# Mostrar o que será enviado
echo ""
echo -e "${BLUE}📊 Mudanças que serão enviadas:${NC}"
git log --oneline "flutterflow/${FLUTTERFLOW_BRANCH}..${CURRENT_BRANCH}" 2>/dev/null || {
    echo -e "${YELLOW}   Nenhuma mudança para enviar${NC}"
    exit 0
}

# Confirmar novamente
echo ""
echo -e "${RED}⚠️  ÚLTIMA CONFIRMAÇÃO${NC}"
echo "   Isso irá enviar suas mudanças locais para o FlutterFlow"
echo "   O FlutterFlow pode sobrescrever essas mudanças na próxima sincronização"
read -p "Continuar? (digite 'sim' para confirmar): " FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "sim" ]; then
    echo "Operação cancelada"
    exit 0
fi

# Fazer push
echo ""
echo -e "${BLUE}🚀 Enviando mudanças...${NC}"
if git push flutterflow "${CURRENT_BRANCH}:${FLUTTERFLOW_BRANCH}"; then
    echo -e "${GREEN}✅ Mudanças enviadas com sucesso!${NC}"
    echo ""
    echo "📋 Próximos passos:"
    echo "   - Verifique no FlutterFlow se as mudanças foram aplicadas"
    echo "   - Lembre-se que o FlutterFlow pode sobrescrever essas mudanças"
    echo "   - Considere trabalhar diretamente no FlutterFlow para mudanças futuras"
else
    echo -e "${RED}❌ Erro ao enviar mudanças${NC}"
    echo ""
    echo "Possíveis causas:"
    echo "   - Sem permissão para fazer push"
    echo "   - Conflitos no repositório remoto"
    echo "   - Branch protegida"
    exit 1
fi

echo ""

