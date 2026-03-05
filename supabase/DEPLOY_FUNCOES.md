# Deploy de Edge Functions no Supabase

Guia rápido para publicar ou atualizar Edge Functions (ex.: `delete-user-account`) quando precisar de reparos ou novas funções.

## Pré-requisito: token local

O token de acesso fica no arquivo **`.env.supabase`** na **raiz do projeto** (fora do git). Se ainda não tiver:

1. Crie o arquivo `.env.supabase` na raiz.
2. Adicione (substitua pelos seus valores):
   ```bash
   SUPABASE_ACCESS_TOKEN=seu_token_do_dashboard
   SUPABASE_PROJECT_REF=seu_project_ref
   ```
3. O **Project ref** aparece na URL do projeto: `https://supabase.com/dashboard/project/SEU_REF`.

## Como fazer o deploy

No terminal, na raiz do projeto:

```bash
# 1. Carregar token e project ref
source .env.supabase

# 2. Deploy de uma função específica
npx supabase functions deploy NOME_DA_FUNCAO --project-ref $SUPABASE_PROJECT_REF
```

### Exemplos

Deploy da função de excluir conta:

```bash
source .env.supabase
npx supabase functions deploy delete-user-account --project-ref $SUPABASE_PROJECT_REF
```

Deploy de outra função (ex.: `send-push`):

```bash
source .env.supabase
npx supabase functions deploy send-push --project-ref $SUPABASE_PROJECT_REF
```

## Se der "Cannot find project ref"

Significa que o projeto não está linkado. Use sempre `--project-ref` com o valor de `SUPABASE_PROJECT_REF` do seu `.env.supabase`.

## Onde achar o token no Supabase

1. Acesse: https://supabase.com/dashboard/account/tokens  
2. Crie um token de acesso (ou use um existente).  
3. Coloque no `.env.supabase` como `SUPABASE_ACCESS_TOKEN=...`.

**Importante:** não commite o arquivo `.env.supabase`; ele já está no `.gitignore`.
