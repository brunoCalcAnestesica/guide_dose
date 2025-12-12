#!/bin/bash

# Workflow Simplificado: Cursor → FlutterFlow
# Use este script para enviar suas mudanças do Cursor para o FlutterFlow

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Workflow: Cursor → FlutterFlow${NC}"
echo ""

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto Flutter${NC}"
    exit 1
fi

# Verificar se é um repositório Git
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Repositório Git não inicializado${NC}"
    echo ""
    echo "Vamos configurar agora:"
    echo ""
    
    # Inicializar Git
    git init
    echo -e "${GREEN}✅ Git inicializado${NC}"
    
    # Solicitar URL do repositório FlutterFlow
    echo ""
    echo -e "${CYAN}📝 Informe a URL do repositório Git do FlutterFlow:${NC}"
    echo "   (Exemplo: https://github.com/seu-usuario/seu-repo.git)"
    echo "   Ou: git@github.com:seu-usuario/seu-repo.git"
    read -p "URL: " REPO_URL
    
    if [ -z "$REPO_URL" ]; then
        echo -e "${RED}❌ URL não fornecida. Abortando.${NC}"
        exit 1
    fi
    
    # Adicionar remote
    git remote add origin "$REPO_URL"
    git remote add flutterflow "$REPO_URL"
    echo -e "${GREEN}✅ Remote configurado${NC}"
    
    # Fazer commit inicial
    echo ""
    echo -e "${BLUE}💾 Fazendo commit inicial...${NC}"
    git add .
    git commit -m "Initial commit - código do Cursor" || {
        echo -e "${YELLOW}⚠️  Nenhuma mudança para commitar${NC}"
    }
    
    # Configurar branch
    git branch -M main
    echo -e "${GREEN}✅ Branch 'main' configurada${NC}"
    
    echo ""
    echo -e "${GREEN}✅ Configuração concluída!${NC}"
    echo ""
fi

# Verificar se remote existe
if ! git remote get-url flutterflow &> /dev/null; then
    echo -e "${RED}❌ Remote 'flutterflow' não configurado${NC}"
    echo ""
    read -p "Deseja configurar agora? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        read -p "URL do repositório FlutterFlow: " REPO_URL
        if [ -n "$REPO_URL" ]; then
            git remote add flutterflow "$REPO_URL" 2>/dev/null || git remote set-url flutterflow "$REPO_URL"
            echo -e "${GREEN}✅ Remote configurado${NC}"
        else
            echo -e "${RED}❌ URL não fornecida${NC}"
            exit 1
        fi
    else
        exit 1
    fi
fi

# Verificar branch atual
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo -e "${BLUE}📍 Branch atual: ${CURRENT_BRANCH}${NC}"

# Verificar mudanças
echo ""
echo -e "${BLUE}📊 Verificando mudanças...${NC}"

# Verificar se há mudanças não commitadas
HAS_UNCOMMITTED=false
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    HAS_UNCOMMITTED=true
    echo -e "${YELLOW}📝 Mudanças não commitadas encontradas:${NC}"
    git status --short
    echo ""
fi

# Verificar se há commits locais não enviados
FLUTTERFLOW_BRANCH="main"
if ! git show-ref --verify --quiet refs/remotes/flutterflow/main 2>/dev/null; then
    FLUTTERFLOW_BRANCH="master"
fi

# Buscar estado remoto
echo -e "${BLUE}🔄 Buscando estado do FlutterFlow...${NC}"
git fetch flutterflow 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Não foi possível buscar do FlutterFlow. Continuando...${NC}"
}

# Processar mudanças não commitadas
if [ "$HAS_UNCOMMITTED" = true ]; then
    echo ""
    echo -e "${CYAN}O que deseja fazer com as mudanças não commitadas?${NC}"
    echo "   1. Fazer commit e enviar"
    echo "   2. Ver mudanças primeiro"
    echo "   3. Cancelar"
    read -p "Escolha (1/2/3): " OPTION
    
    case $OPTION in
        1)
            git add .
            echo ""
            read -p "Mensagem do commit: " COMMIT_MSG
            if [ -z "$COMMIT_MSG" ]; then
                COMMIT_MSG="Mudanças do Cursor - $(date +%Y-%m-%d_%H-%M-%S)"
            fi
            git commit -m "$COMMIT_MSG"
            echo -e "${GREEN}✅ Mudanças commitadas${NC}"
            ;;
        2)
            echo ""
            echo -e "${CYAN}📋 Mudanças detalhadas:${NC}"
            git diff
            echo ""
            read -p "Deseja fazer commit? (s/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Ss]$ ]]; then
                git add .
                read -p "Mensagem do commit: " COMMIT_MSG
                if [ -z "$COMMIT_MSG" ]; then
                    COMMIT_MSG="Mudanças do Cursor - $(date +%Y-%m-%d_%H-%M-%S)"
                fi
                git commit -m "$COMMIT_MSG"
                echo -e "${GREEN}✅ Mudanças commitadas${NC}"
            else
                echo "Operação cancelada"
                exit 0
            fi
            ;;
        3)
            echo "Operação cancelada"
            exit 0
            ;;
        *)
            echo "Opção inválida"
            exit 1
            ;;
    esac
fi

# Verificar se há commits para enviar
LOCAL_COMMITS=$(git log "flutterflow/${FLUTTERFLOW_BRANCH}..${CURRENT_BRANCH}" --oneline 2>/dev/null | wc -l | tr -d ' ')

if [ "$LOCAL_COMMITS" -eq 0 ] && [ "$HAS_UNCOMMITTED" != true ]; then
    echo ""
    echo -e "${YELLOW}ℹ️  Nenhuma mudança para enviar${NC}"
    exit 0
fi

# Mostrar o que será enviado
if [ "$LOCAL_COMMITS" -gt 0 ]; then
    echo ""
    echo -e "${CYAN}📤 Commits que serão enviados:${NC}"
    git log "flutterflow/${FLUTTERFLOW_BRANCH}..${CURRENT_BRANCH}" --oneline 2>/dev/null || true
fi

# Confirmar envio
echo ""
echo -e "${YELLOW}⚠️  ATENÇÃO:${NC}"
echo "   Isso irá enviar suas mudanças do Cursor para o FlutterFlow"
echo "   Certifique-se de que:"
echo "   - Testou o código localmente"
echo "   - As mudanças estão funcionando"
echo "   - Fez backup se necessário"
echo ""
read -p "Deseja continuar? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada"
    exit 0
fi

# Enviar para FlutterFlow
echo ""
echo -e "${BLUE}🚀 Enviando para FlutterFlow...${NC}"

# Tentar push
if git push flutterflow "${CURRENT_BRANCH}:${FLUTTERFLOW_BRANCH}" --force-with-lease 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Mudanças enviadas com sucesso para o FlutterFlow!${NC}"
    echo ""
    echo -e "${CYAN}📋 Próximos passos:${NC}"
    echo "   1. Acesse seu projeto no FlutterFlow"
    echo "   2. Verifique se as mudanças foram aplicadas"
    echo "   3. Teste no FlutterFlow se necessário"
    echo ""
    echo -e "${YELLOW}💡 Dica:${NC} Use este script sempre que fizer mudanças no Cursor"
else
    echo ""
    echo -e "${RED}❌ Erro ao enviar mudanças${NC}"
    echo ""
    echo "Possíveis causas:"
    echo "   - Conflitos no repositório remoto"
    echo "   - Sem permissão para fazer push"
    echo "   - Branch protegida"
    echo ""
    echo "Tente:"
    echo "   1. Puxar mudanças primeiro: git pull flutterflow ${FLUTTERFLOW_BRANCH}"
    echo "   2. Resolver conflitos se houver"
    echo "   3. Executar este script novamente"
    exit 1
fi

