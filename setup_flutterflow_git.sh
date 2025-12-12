#!/bin/bash

# Script de Configuração Inicial para Sincronização com FlutterFlow
# Execute este script para configurar o Git e conectar ao FlutterFlow

set -e

echo "🚀 Configurando sincronização com FlutterFlow..."
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto Flutter${NC}"
    exit 1
fi

# Verificar se Git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git não está instalado. Por favor, instale o Git primeiro.${NC}"
    exit 1
fi

# Verificar se já é um repositório Git
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Repositório Git já inicializado${NC}"
    read -p "Deseja continuar mesmo assim? (s/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}📦 Inicializando repositório Git...${NC}"
    git init
fi

# Solicitar URL do repositório FlutterFlow
echo ""
echo -e "${YELLOW}📝 Informe a URL do repositório Git do FlutterFlow:${NC}"
echo "   (Exemplo: https://github.com/seu-usuario/seu-repo.git)"
read -p "URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}❌ URL não fornecida. Abortando.${NC}"
    exit 1
fi

# Verificar se remote já existe
if git remote get-url flutterflow &> /dev/null; then
    echo -e "${YELLOW}⚠️  Remote 'flutterflow' já existe${NC}"
    CURRENT_URL=$(git remote get-url flutterflow)
    echo "   URL atual: $CURRENT_URL"
    read -p "Deseja atualizar? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        git remote set-url flutterflow "$REPO_URL"
        echo -e "${GREEN}✅ Remote atualizado${NC}"
    fi
else
    git remote add flutterflow "$REPO_URL"
    echo -e "${GREEN}✅ Remote 'flutterflow' adicionado${NC}"
fi

# Configurar origin também (caso não exista)
if ! git remote get-url origin &> /dev/null; then
    git remote add origin "$REPO_URL"
    echo -e "${GREEN}✅ Remote 'origin' adicionado${NC}"
fi

# Verificar se há commits
if ! git rev-parse --verify HEAD &> /dev/null; then
    echo ""
    echo -e "${YELLOW}📝 Fazendo commit inicial...${NC}"
    git add .
    git commit -m "Initial commit - antes da sincronização com FlutterFlow" || {
        echo -e "${YELLOW}⚠️  Nenhuma mudança para commitar${NC}"
    }
fi

# Criar branch de sincronização
echo ""
echo -e "${GREEN}🌿 Configurando branches...${NC}"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    git checkout -b main 2>/dev/null || git checkout main 2>/dev/null || true
fi

# Criar branch para desenvolvimento local
if ! git show-ref --verify --quiet refs/heads/local-dev; then
    git checkout -b local-dev
    echo -e "${GREEN}✅ Branch 'local-dev' criada para suas mudanças locais${NC}"
    git checkout main
fi

# Atualizar .gitignore se necessário
if ! grep -q "# FlutterFlow" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# FlutterFlow" >> .gitignore
    echo "lib/flutter_flow/" >> .gitignore
    echo ".flutterflow/" >> .gitignore
    echo -e "${GREEN}✅ .gitignore atualizado${NC}"
fi

echo ""
echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo ""
echo "📋 Próximos passos:"
echo "   1. No FlutterFlow, configure o Git em Settings > Git"
echo "   2. Use './sync_from_flutterflow.sh' para puxar mudanças do FlutterFlow"
echo "   3. Use './sync_to_flutterflow.sh' para enviar mudanças (use com cuidado)"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Faça backup antes de sincronizar"
echo "   - O FlutterFlow pode sobrescrever mudanças locais"
echo "   - Trabalhe principalmente no FlutterFlow e use local para testes"
echo ""

