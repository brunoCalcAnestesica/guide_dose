# 🚀 Início Rápido: Cursor → FlutterFlow

## Passo 1: Configure o Git no FlutterFlow

1. Acesse seu projeto no FlutterFlow
2. Vá em **Settings** > **Git**
3. Conecte seu repositório Git (GitHub, GitLab, etc.)
4. **Copie a URL do repositório** (você vai precisar dela)

## Passo 2: Execute o Script

No terminal, execute:

```bash
./workflow_local_to_flutterflow.sh
```

Na primeira vez, o script vai:
- ✅ Inicializar o Git
- ✅ Pedir a URL do repositório
- ✅ Configurar tudo automaticamente

## Passo 3: Desenvolva e Envie

Agora, sempre que você fizer mudanças no Cursor:

1. **Edite seus arquivos normalmente no Cursor**
2. **Execute o script novamente:**
   ```bash
   ./workflow_local_to_flutterflow.sh
   ```
3. **O script vai:**
   - Detectar suas mudanças
   - Perguntar se quer fazer commit
   - Enviar para o FlutterFlow automaticamente

## 📝 Exemplo de Uso

```bash
# 1. Você edita arquivos no Cursor
# 2. Salva tudo
# 3. Executa:
./workflow_local_to_flutterflow.sh

# 4. O script pergunta:
#    - "Mensagem do commit: " → Você digita: "Adicionei nova feature"
#    - "Deseja continuar? (s/n)" → Você digita: s
# 5. Pronto! Suas mudanças foram para o FlutterFlow
```

## 🔄 Puxar Mudanças do FlutterFlow

Se você ou outra pessoa fez mudanças no FlutterFlow e você quer ver no Cursor:

```bash
./pull_from_flutterflow.sh
```

⚠️ **Atenção**: Isso pode criar conflitos se você tiver mudanças locais não commitadas.

## ❓ Problemas?

Consulte o guia completo: `GUIA_SINCRONIZACAO_FLUTTERFLOW.md`

## 💡 Dicas

- ✅ Sempre teste seu código antes de enviar
- ✅ Use mensagens de commit descritivas
- ✅ Faça commits frequentes (não acumule muitas mudanças)
- ⚠️ O FlutterFlow pode sobrescrever mudanças se você editar lá também

