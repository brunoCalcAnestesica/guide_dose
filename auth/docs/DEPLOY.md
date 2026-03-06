# Deploy no Netlify

Guia de deploy da aplicacao web. O build gera arquivos estaticos em `auth/dist` e o Netlify publica automaticamente.

> Documento completo na raiz do repo: `DEPLOY_NETLIFY.md`

---

## Resumo da configuracao (arquivos na raiz do repo)

### netlify.toml

```toml
[build]
  publish = "auth/dist"
  command = "cd auth && npm install && npm run build"

[dev]
  command = "bash scripts/start-vite.sh"
  targetPort = 5173
  port = 8888
  autoLaunch = false

[functions]
  directory = "netlify/functions"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

- **publish**: diretorio de saida do build (`auth/dist`).
- **command**: instala dependencias e roda o build do Vite dentro de `auth/`.
- **functions**: aponta para `netlify/functions/` (backend).
- **redirects**: redireciona todas as rotas para `index.html` (SPA).

### package.json (raiz)

```json
{
  "scripts": {
    "web:dev": "cd auth && npm run dev",
    "deploy": "npx netlify-cli deploy --prod"
  }
}
```

- `web:dev`: atalho para rodar o dev server do Vite a partir da raiz.
- `deploy`: deploy manual para producao via CLI.

### auth/package.json

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc -b"
  }
}
```

Stack: React 19, Vite 6, Tailwind CSS 3, TypeScript 5.7.

---

## Deploy automatico (recomendado)

1. Acesse [app.netlify.com](https://app.netlify.com) e abra o site do GuideDose.
2. Va em **Site configuration > Build & deploy > Continuous deployment**.
3. Conecte o repositorio (GitHub/GitLab/Bitbucket) e escolha o branch (ex: `main`).
4. A partir dai, cada `git push` no branch configurado dispara o build e publica o site.

Fluxo no dia a dia:

```bash
git add .
git commit -m "Sua alteracao"
git push
```

O Netlify executa `cd auth && npm install && npm run build` e publica `auth/dist`. Acompanhe em **Deploys** no painel.

---

## Deploy manual

Para publicar sem dar push (teste em producao):

```bash
# Na raiz do projeto (login unico)
npx netlify login

# Deploy para producao
npm run deploy
```

---

## Deploy automatico apos cada commit (hook local)

Para rodar deploy automaticamente apos cada `git commit` (sem push):

```bash
# Login (uma vez)
npx netlify login

# Instalar hook (uma vez por maquina)
chmod +x scripts/install-deploy-hook.sh
./scripts/install-deploy-hook.sh
```

Para desativar: `rm .git/hooks/post-commit`

---

## Variaveis de ambiente

No painel do Netlify (**Site configuration > Environment variables**), configure:

| Variavel | Descricao |
|----------|-----------|
| `SUPABASE_URL` | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Chave publica (anon) |
| `SUPABASE_SERVICE_ROLE_KEY` | Chave privada (service role) |
| `SUPABASE_ADMIN_EMAILS` | Emails dos admins, separados por virgula |

Essas variaveis sao consumidas pelas Netlify Functions (ver [BACKEND.md](BACKEND.md)).

---

## Desenvolvimento local

```bash
# Dentro da pasta auth/
npm install
npm run dev        # Vite dev server em http://localhost:5173
npm run build      # Build de producao em auth/dist
npm run preview    # Preview do build local
npm run typecheck  # Verificacao de tipos TypeScript
```

---

## Tabela app_config (Supabase)

A funcionalidade "Atualizar Versao do App" no painel admin depende da tabela `app_config`. Se a pagina nao carregar ou nao salvar, execute o script `supabase_app_config.sql` no **SQL Editor** do Supabase (arquivo na raiz do repo).
