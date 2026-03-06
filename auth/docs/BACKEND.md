# Backend: Netlify Functions

O backend da aplicacao web sao **Netlify Functions** (serverless). Os arquivos ficam em `netlify/functions/` na **raiz do repositorio**.

> **Ao abrir apenas a pasta `auth/` no Cursor, esses arquivos ficam fora do workspace.**
> Para edita-los, abra a raiz do projeto no editor.

---

## Functions disponiveis

| Arquivo | Caminho completo (raiz) | Descricao |
|---------|------------------------|-----------|
| `auth.js` | `netlify/functions/auth.js` | Autenticacao: login, registro, recuperacao de senha |
| `api.js` | `netlify/functions/api.js` | API geral: operacoes de leitura com chave publica |
| `admin-api.js` | `netlify/functions/admin-api.js` | API administrativa: operacoes restritas a admins (usa service role) |
| `users.js` | `netlify/functions/users.js` | Gerenciamento de usuarios: listagem e operacoes admin (usa service role) |
| `push.js` | `netlify/functions/push.js` | Notificacoes push: envio para usuarios (usa service role) |

As functions `admin-api.js`, `users.js` e `push.js` usam a **service role key** e verificam se o email do usuario esta na lista de admins (`SUPABASE_ADMIN_EMAILS`). As functions `auth.js` e `api.js` usam apenas a chave publica (anon).

---

## Variaveis de ambiente

| Variavel | Usada por | Descricao |
|----------|-----------|-----------|
| `SUPABASE_URL` | Todas | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Todas | Chave publica (anon key) |
| `SUPABASE_SERVICE_ROLE_KEY` | admin-api, users, push | Chave privada com acesso total ao banco |
| `SUPABASE_ADMIN_EMAILS` | admin-api, users, push | Lista de emails admin, separados por virgula |

### Em desenvolvimento

As functions `admin-api.js`, `users.js` e `push.js` carregam variaveis de um arquivo `.env` em `netlify/functions/.env` (na raiz do repo). Formato:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_ADMIN_EMAILS=admin@exemplo.com,outro@exemplo.com
```

As functions `auth.js` e `api.js` leem diretamente de `process.env` (configure via `netlify dev` ou exporte no shell).

### Em producao

Configure as variaveis no painel do Netlify: **Site configuration > Environment variables**.

---

## Chamando as functions a partir do front-end

As Netlify Functions ficam acessiveis em `/.netlify/functions/<nome>`. Exemplos:

```
POST /.netlify/functions/auth
GET  /.netlify/functions/api
POST /.netlify/functions/admin-api
GET  /.netlify/functions/users
POST /.netlify/functions/push
```

Em desenvolvimento local com `netlify dev`, o proxy roda em `http://localhost:8888`.

---

## Desenvolvimento local com Netlify Dev

Para testar as functions junto com o front-end:

```bash
# Na raiz do repositorio
npx netlify dev
```

Isso sobe o Vite (front-end) e o servidor de functions juntos, com proxy automatico em `http://localhost:8888`.
