# Guia de Sincronização com FlutterFlow

Este guia explica como sincronizar seu projeto Flutter local (no Cursor) com o FlutterFlow.

## 📋 Pré-requisitos

1. Conta no FlutterFlow ativa
2. Projeto criado no FlutterFlow
3. Git instalado no seu sistema
4. Acesso ao repositório Git do FlutterFlow (GitHub, GitLab, etc.)

## 🎯 Workflow Principal: Cursor → FlutterFlow

**Se você quer desenvolver no Cursor e enviar para o FlutterFlow**, use este workflow simplificado:

### Configuração Inicial (Uma vez apenas)

1. **Configure o Git no FlutterFlow:**
   - Acesse seu projeto no FlutterFlow
   - Vá em **Settings** > **Git**
   - Conecte seu repositório Git (GitHub, GitLab, Bitbucket)
   - Anote a URL do repositório

2. **Execute o script de workflow:**
   ```bash
   ./workflow_local_to_flutterflow.sh
   ```
   
   O script vai:
   - Inicializar o Git (se necessário)
   - Solicitar a URL do repositório
   - Configurar tudo automaticamente

### Desenvolvimento Diário

**Sempre que fizer mudanças no Cursor e quiser enviar para o FlutterFlow:**

```bash
./workflow_local_to_flutterflow.sh
```

O script vai:
- ✅ Verificar suas mudanças
- ✅ Fazer commit automaticamente (se você quiser)
- ✅ Enviar para o FlutterFlow
- ✅ Confirmar o envio

### Puxar Mudanças do FlutterFlow (quando necessário)

Se você ou outra pessoa fez mudanças no FlutterFlow e você quer ver no Cursor:

```bash
./pull_from_flutterflow.sh
```

⚠️ **Atenção**: Isso pode criar conflitos se você tiver mudanças locais não commitadas.

## 🔄 Opções de Sincronização

### Opção 1: Sincronização via Git (Recomendado)

O FlutterFlow permite conectar seu projeto a um repositório Git. Esta é a melhor opção para sincronização bidirecional.

#### Passo 1: Configurar Git no FlutterFlow

1. Acesse seu projeto no FlutterFlow
2. Vá em **Settings** > **Git**
3. Conecte seu repositório Git (GitHub, GitLab, Bitbucket)
4. Configure as credenciais de acesso

#### Passo 2: Configurar Git Localmente

Execute os scripts fornecidos ou siga os passos manuais abaixo.

#### Passo 3: Sincronizar

Use os scripts de sincronização fornecidos para puxar/push mudanças.

### Opção 2: Download Manual

1. No FlutterFlow, vá em **Settings** > **Download Code**
2. Baixe o código
3. Copie os arquivos para seu projeto local
4. Resolva conflitos manualmente

## 🚀 Configuração Inicial

### 1. Inicializar Repositório Git (se ainda não foi feito)

```bash
# No diretório do projeto
cd /Users/brunodaroz/StudioProjects/guide_dose
git init
git add .
git commit -m "Initial commit"
```

### 2. Conectar ao Repositório do FlutterFlow

```bash
# Adicione o remote do FlutterFlow
git remote add flutterflow <URL_DO_SEU_REPOSITORIO>
git remote add origin <URL_DO_SEU_REPOSITORIO>
```

### 3. Configurar Branch de Sincronização

```bash
# Crie uma branch para sincronização
git checkout -b flutterflow-sync
git branch -M main  # ou master, dependendo do FlutterFlow
```

## 📥 Sincronizando do FlutterFlow para Local

Quando você faz mudanças no FlutterFlow e quer trazer para o Cursor:

```bash
# 1. Puxe as mudanças do FlutterFlow
git fetch flutterflow
git pull flutterflow main

# 2. Resolva conflitos se houver
# 3. Teste o código localmente
flutter pub get
flutter run
```

## 📤 Sincronizando do Local para FlutterFlow

Quando você faz mudanças no Cursor e quer enviar para o FlutterFlow:

⚠️ **ATENÇÃO**: O FlutterFlow sobrescreve mudanças locais quando você faz push. 
Recomenda-se trabalhar principalmente no FlutterFlow e usar o código local apenas para:
- Testes
- Customizações específicas
- Análise de código

```bash
# 1. Commit suas mudanças locais
git add .
git commit -m "Mudanças locais"

# 2. Push para o FlutterFlow (CUIDADO!)
git push flutterflow main
```

## 🔀 Estratégia de Branches Recomendada

Para evitar conflitos, use esta estratégia:

```
main (FlutterFlow)          → Branch principal do FlutterFlow
├── local-dev               → Suas mudanças locais
└── flutterflow-sync        → Sincronização com FlutterFlow
```

### Workflow Recomendado

1. **Trabalhe no FlutterFlow** para mudanças principais
2. **Puxe mudanças** do FlutterFlow regularmente
3. **Use branch local** para customizações que não serão enviadas ao FlutterFlow
4. **Merge seletivo** quando necessário

## 🛠️ Scripts de Sincronização

### Scripts Principais (Recomendados)

- **`workflow_local_to_flutterflow.sh`** ⭐ - **Use este para enviar mudanças do Cursor para o FlutterFlow**
  - Configura automaticamente na primeira execução
  - Detecta mudanças não commitadas
  - Faz commit e push de forma segura
  
- **`pull_from_flutterflow.sh`** - Puxa mudanças do FlutterFlow para o Cursor
  - Útil quando há mudanças no FlutterFlow que você quer ver localmente

### Scripts Avançados (Opcional)

- `sync_from_flutterflow.sh` - Versão mais detalhada para puxar mudanças
- `sync_to_flutterflow.sh` - Versão mais detalhada para enviar mudanças
- `setup_flutterflow_git.sh` - Configuração manual do Git

## ⚠️ Importante

1. **Backup**: Sempre faça backup antes de sincronizar
2. **Conflitos**: O FlutterFlow pode sobrescrever mudanças locais
3. **Arquivos Ignorados**: Alguns arquivos são gerados automaticamente e não devem ser commitados
4. **Assets**: Verifique se os assets estão sincronizados corretamente

## 📝 Arquivos que o FlutterFlow Gera

O FlutterFlow gera automaticamente:
- `lib/flutter_flow/` - Código gerado pelo FlutterFlow
- `lib/theme/` - Temas
- `lib/main.dart` - Pode ser sobrescrito
- Alguns arquivos de configuração

## 🔍 Verificando Sincronização

```bash
# Ver status do Git
git status

# Ver diferenças
git diff flutterflow/main

# Ver histórico
git log --oneline --graph --all
```

## 🆘 Solução de Problemas

### Conflitos de Merge

```bash
# Abortar merge em caso de problemas
git merge --abort

# Ver conflitos
git status

# Resolver manualmente e depois
git add .
git commit -m "Resolve conflicts"
```

### Resetar para Estado do FlutterFlow

```bash
# CUIDADO: Isso apaga mudanças locais não commitadas
git fetch flutterflow
git reset --hard flutterflow/main
```

### Recuperar Arquivos Perdidos

```bash
# Ver histórico
git reflog

# Recuperar commit específico
git checkout <commit-hash> -- <arquivo>
```

## 📚 Recursos Adicionais

- [Documentação FlutterFlow - Git](https://docs.flutterflow.io/git-integration)
- [FlutterFlow - Download Code](https://docs.flutterflow.io/download-code)
- [Git Documentation](https://git-scm.com/doc)

