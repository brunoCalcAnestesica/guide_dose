#!/bin/bash

# Script para Sincronizar Mudanças do FlutterFlow para o Projeto Local
# Este script puxa as mudanças do FlutterFlow e mescla com o código local

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📥 Sincronizando do FlutterFlow para Local...${NC}"
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

# Salvar estado atual
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Branch atual: ${CURRENT_BRANCH}${NC}"

# Verificar se há mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Há mudanças não commitadas${NC}"
    echo "   Opções:"
    echo "   1. Fazer commit das mudanças"
    echo "   2. Fazer stash (guardar temporariamente)"
    echo "   3. Descartar mudanças (CUIDADO!)"
    read -p "Escolha uma opção (1/2/3): " OPTION
    
    case $OPTION in
        1)
            echo -e "${BLUE}💾 Fazendo commit...${NC}"
            git add .
            read -p "Mensagem do commit: " COMMIT_MSG
            git commit -m "${COMMIT_MSG:-Sync before pull from FlutterFlow}"
            ;;
        2)
            echo -e "${BLUE}📦 Fazendo stash...${NC}"
            git stash push -m "Stash antes de sync do FlutterFlow - $(date +%Y-%m-%d_%H-%M-%S)"
            STASHED=true
            ;;
        3)
            echo -e "${RED}🗑️  Descartando mudanças...${NC}"
            read -p "Tem certeza? (digite 'sim' para confirmar): " CONFIRM
            if [ "$CONFIRM" = "sim" ]; then
                git reset --hard HEAD
            else
                echo "Operação cancelada"
                exit 1
            fi
            ;;
        *)
            echo "Opção inválida. Abortando."
            exit 1
            ;;
    esac
fi

# Fazer backup da branch atual
BACKUP_BRANCH="backup-${CURRENT_BRANCH}-$(date +%Y%m%d-%H%M%S)"
echo -e "${BLUE}💾 Criando backup: ${BACKUP_BRANCH}${NC}"
git branch "$BACKUP_BRANCH" 2>/dev/null || true

# Buscar mudanças do FlutterFlow
echo ""
echo -e "${BLUE}🔄 Buscando mudanças do FlutterFlow...${NC}"
git fetch flutterflow

# Verificar qual branch usar (main ou master)
FLUTTERFLOW_BRANCH="main"
if ! git show-ref --verify --quiet refs/remotes/flutterflow/main; then
    FLUTTERFLOW_BRANCH="master"
fi

# Mostrar diferenças
echo ""
echo -e "${BLUE}📊 Diferenças encontradas:${NC}"
git log --oneline "${CURRENT_BRANCH}..flutterflow/${FLUTTERFLOW_BRANCH}" 2>/dev/null || echo "   Nenhuma diferença ou branch não encontrada"

# Perguntar se deseja continuar
echo ""
read -p "Deseja continuar com a sincronização? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada"
    exit 0
fi

# Fazer merge
echo ""
echo -e "${BLUE}🔀 Fazendo merge...${NC}"
if git merge "flutterflow/${FLUTTERFLOW_BRANCH}" --no-edit; then
    echo -e "${GREEN}✅ Merge concluído com sucesso!${NC}"
else
    echo -e "${RED}❌ Conflitos detectados!${NC}"
    echo ""
    echo "Resolva os conflitos manualmente:"
    echo "   1. Edite os arquivos com conflitos"
    echo "   2. Execute: git add ."
    echo "   3. Execute: git commit"
    echo ""
    echo "Ou para abortar o merge:"
    echo "   git merge --abort"
    exit 1
fi

# Restaurar stash se foi feito
if [ "$STASHED" = true ]; then
    echo ""
    read -p "Deseja restaurar as mudanças que foram guardadas (stash)? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        git stash pop || {
            echo -e "${YELLOW}⚠️  Conflitos ao restaurar stash. Resolva manualmente.${NC}"
        }
    fi
fi

# Atualizar dependências
echo ""
echo -e "${BLUE}📦 Atualizando dependências Flutter...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}✅ Sincronização concluída!${NC}"
echo ""
echo "📋 Próximos passos:"
echo "   - Teste o código: flutter run"
echo "   - Verifique se tudo está funcionando"
echo "   - Se necessário, resolva conflitos restantes"
echo ""

