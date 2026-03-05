# Supabase: banco, storage e Edge Function

## Tabelas necessárias

- `sofia_knowledge_base` (compartilhada)
- `ai_knowledge_base` (pessoal por usuário)

Scripts prontos:

- `supabase_sofia_knowledge_base.sql`
- `supabase_ai_knowledge_base.sql`

## Storage

Crie o bucket:

- `sofia_knowledge`

Esse bucket armazena PDFs compartilhados pela equipe.

## Edge Function (OpenAI proxy)

Arquivo: `openai-proxy.ts`

Coloque em:

```
supabase/functions/openai-proxy/index.ts
```

Variáveis necessárias no Supabase:

- `OPENAI_API_KEY`

Endpoint:

```
POST https://<seu-projeto>.supabase.co/functions/v1/openai-proxy
Headers:
  Authorization: Bearer <anonKey>
  apikey: <anonKey>
  Content-Type: application/json
```

## RLS

Os scripts já ativam RLS e definem políticas:

- `sofia_knowledge_base`: leitura pública de itens ativos, escrita apenas autenticados.
- `ai_knowledge_base`: leitura/escrita somente do próprio usuário.
