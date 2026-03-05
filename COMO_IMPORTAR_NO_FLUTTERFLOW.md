# 📥 Como Importar Código Existente no FlutterFlow

## ⚠️ Importante: Como o FlutterFlow Funciona

O FlutterFlow **NÃO importa código existente automaticamente**. Ele funciona assim:

1. **FlutterFlow gera código** → Faz push para o Git
2. **Você desenvolve no Cursor** → Faz push para o Git
3. **Ambos trabalham no mesmo repositório**, mas podem estar em branches diferentes

## 🎯 Estratégias de Integração

### Estratégia 1: FlutterFlow Sobrescreve (Início Novo)

Se você quer começar do zero no FlutterFlow:

1. **No FlutterFlow:**
   - Associe o repositório: `https://github.com/brunoCalcAnestesica/guide_dose.git`
   - Faça o primeiro push do FlutterFlow
   - O FlutterFlow vai criar/sobrescrever arquivos na branch `main`

2. **No Cursor:**
   - Seu código atual está em `main`
   - Você pode criar uma branch de backup:
     ```bash
     git checkout -b backup-codigo-original
     git push origin backup-codigo-original
     git checkout main
     ```

3. **Depois:**
   - O FlutterFlow vai gerar código novo
   - Você pode fazer merge seletivo do seu código antigo quando necessário

### Estratégia 2: Trabalhar em Paralelo (Recomendado)

Manter seu código e o FlutterFlow separados:

1. **Criar branch para FlutterFlow:**
   ```bash
   git checkout -b flutterflow-main
   git push origin flutterflow-main
   ```

2. **No FlutterFlow:**
   - Associe o repositório
   - Configure para usar a branch `flutterflow-main` (se possível)
   - Ou deixe usar `main` e você trabalha em outra branch

3. **No Cursor:**
   - Continue trabalhando na branch `main`
   - Faça merge do FlutterFlow quando necessário:
     ```bash
     git checkout main
     git merge flutterflow-main
     ```

### Estratégia 3: FlutterFlow como Base, Seu Código como Extensão

1. **No FlutterFlow:**
   - Associe o repositório
   - Deixe o FlutterFlow fazer o primeiro push
   - Isso cria a estrutura base do FlutterFlow

2. **No Cursor:**
   - Puxe o código do FlutterFlow:
     ```bash
     git pull flutterflow main
     ```
   - Adicione seus arquivos customizados
   - Faça commit e push

## 📋 Passo a Passo: Importar Código Existente

### Opção A: Fazer FlutterFlow Usar Seu Código como Base

1. **No FlutterFlow:**
   - Settings > GitHub
   - Associe: `https://github.com/brunoCalcAnestesica/guide_dose.git`
   - **NÃO faça push ainda**

2. **No Cursor, prepare uma branch limpa:**
   ```bash
   # Criar branch específica para FlutterFlow
   git checkout -b flutterflow-import
   
   # Garantir que está atualizado
   git push origin flutterflow-import
   ```

3. **No FlutterFlow:**
   - Configure para usar a branch `flutterflow-import` (se a opção existir)
   - Ou deixe usar `main` e depois faça merge

4. **Quando FlutterFlow fizer push:**
   - Ele vai adicionar seus arquivos gerados
   - Seus arquivos existentes vão continuar lá
   - Você pode fazer merge seletivo

### Opção B: Fazer Backup e Deixar FlutterFlow Sobrescrever

1. **Fazer backup completo:**
   ```bash
   # Criar branch de backup
   git checkout -b backup-antes-flutterflow
   git push origin backup-antes-flutterflow
   
   # Voltar para main
   git checkout main
   ```

2. **No FlutterFlow:**
   - Associe o repositório
   - Faça o primeiro push
   - O FlutterFlow vai gerar código novo

3. **Depois, se precisar do código antigo:**
   ```bash
   git checkout backup-antes-flutterflow
   # Ver seus arquivos antigos
   git checkout main
   # Voltar para o código do FlutterFlow
   ```

## 🔄 Workflow Recomendado

### Para Desenvolvimento Contínuo:

1. **Desenvolva no Cursor:**
   ```bash
   # Fazer mudanças
   ./workflow_local_to_flutterflow.sh
   ```

2. **FlutterFlow gera código:**
   - FlutterFlow faz push automaticamente quando você publica

3. **Sincronizar:**
   ```bash
   # Puxar mudanças do FlutterFlow
   ./pull_from_flutterflow.sh
   
   # Ou fazer merge manual
   git pull flutterflow main
   ```

## ⚠️ Pontos Importantes

1. **FlutterFlow gera arquivos específicos:**
   - `lib/flutter_flow/` - Código gerado
   - `lib/theme/` - Temas
   - Pode sobrescrever `lib/main.dart`

2. **Seus arquivos customizados:**
   - Mantenha em pastas separadas se possível
   - Ou faça merge cuidadoso

3. **Conflitos:**
   - O FlutterFlow pode sobrescrever arquivos
   - Sempre faça backup antes
   - Use branches para testar

## 🛠️ Comandos Úteis

```bash
# Ver diferenças entre seu código e FlutterFlow
git diff main flutterflow/main

# Fazer merge do FlutterFlow
git checkout main
git merge flutterflow/main

# Criar branch de trabalho
git checkout -b desenvolvimento
git push origin desenvolvimento

# Ver histórico
git log --oneline --graph --all
```

## 📚 Próximos Passos

1. Decida qual estratégia usar (recomendo Estratégia 2)
2. Configure o FlutterFlow para associar o repositório
3. Faça backup do código atual
4. Comece a trabalhar!

