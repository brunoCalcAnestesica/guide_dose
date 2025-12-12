#!/bin/bash

# Script para Puxar Mudanças do FlutterFlow (quando necessário)
# Use quando quiser ver o que mudou no FlutterFlow ou resolver conflitos

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}📥 Puxando mudanças do FlutterFlow...${NC}"
echo ""

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto Flutter${NC}"
    exit 1
fi

# Verificar se é um repositório Git
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Este diretório não é um repositório Git${NC}"
    exit 1
fi

# Verificar se remote existe
if ! git remote get-url flutterflow &> /dev/null; then
    echo -e "${RED}❌ Remote 'flutterflow' não configurado${NC}"
    exit 1
fi

# Verificar mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Há mudanças não commitadas${NC}"
    echo ""
    echo "Opções:"
    echo "   1. Fazer commit das mudanças"
    echo "   2. Fazer stash (guardar temporariamente)"
    echo "   3. Descartar mudanças (CUIDADO!)"
    read -p "Escolha (1/2/3): " OPTION
    
    case $OPTION in
        1)
            git add .
            read -p "Mensagem do commit: " COMMIT_MSG
            git commit -m "${COMMIT_MSG:-Stash before pull}"
            ;;
        2)
            git stash push -m "Stash antes de pull - $(date +%Y-%m-%d_%H-%M-%S)"
            STASHED=true
            ;;
        3)
            read -p "Tem certeza? (digite 'sim'): " CONFIRM
            if [ "$CONFIRM" = "sim" ]; then
                git reset --hard HEAD
            else
                exit 1
            fi
            ;;
        *)
            exit 1
            ;;
    esac
fi

# Buscar mudanças
echo ""
echo -e "${BLUE}🔄 Buscando mudanças do FlutterFlow...${NC}"
git fetch flutterflow

# Verificar branch
FLUTTERFLOW_BRANCH="main"
if ! git show-ref --verify --quiet refs/remotes/flutterflow/main; then
    FLUTTERFLOW_BRANCH="master"
fi

# Mostrar diferenças
echo ""
echo -e "${CYAN}📊 Mudanças no FlutterFlow:${NC}"
git log --oneline "HEAD..flutterflow/${FLUTTERFLOW_BRANCH}" 2>/dev/null || echo "   Nenhuma mudança nova"

# Perguntar se deseja fazer merge
read -p "Deseja puxar essas mudanças? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada"
    exit 0
fi

# Fazer merge
echo ""
echo -e "${BLUE}🔀 Fazendo merge...${NC}"
if git merge "flutterflow/${FLUTTERFLOW_BRANCH}" --no-edit; then
    echo -e "${GREEN}✅ Merge concluído!${NC}"
else
    echo -e "${RED}❌ Conflitos detectados!${NC}"
    echo ""
    echo "Resolva os conflitos e depois:"
    echo "   git add ."
    echo "   git commit"
    exit 1
fi

# Restaurar stash se necessário
if [ "$STASHED" = true ]; then
    echo ""
    read -p "Restaurar mudanças guardadas? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        git stash pop || echo -e "${YELLOW}⚠️  Conflitos ao restaurar stash${NC}"
    fi
fi

# Atualizar dependências
echo ""
echo -e "${BLUE}📦 Atualizando dependências...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}✅ Concluído!${NC}"

