# Documentacao do Projeto Web (auth)

Esta pasta concentra a documentacao necessaria para quem trabalha apenas no front-end web, abrindo somente a pasta `auth/` no editor.

O projeto web usa **React 19 + Vite 6 + Tailwind CSS** e e publicado via **Netlify**.

## Indice

| Documento | Conteudo |
|-----------|----------|
| [SUPABASE.md](SUPABASE.md) | Configuracao do Supabase: credenciais, autenticacao, scripts SQL |
| [DEPLOY.md](DEPLOY.md) | Deploy no Netlify, resumo de `netlify.toml` e `package.json` da raiz |
| [BACKEND.md](BACKEND.md) | Netlify Functions (backend): endpoints, variaveis de ambiente |

## Estrutura do repositorio

O repositorio raiz e um monorepo Flutter + Web. Ao abrir apenas `auth/` no Cursor, alguns arquivos importantes ficam **fora do workspace**:

```
/ (raiz do repo)
├── netlify.toml          # Config de build e publish do Netlify
├── package.json          # Scripts auxiliares (web:dev, deploy)
├── netlify/functions/    # Backend: Netlify Functions (auth, api, admin-api, users, push)
├── CONFIGURAR_SUPABASE.md
├── DEPLOY_NETLIFY.md
├── supabase_*.sql        # Scripts SQL do banco
└── auth/                 # <-- Workspace web (este diretorio)
    ├── package.json      # Dependencias e scripts do front-end
    ├── src/
    ├── dist/             # Build de producao (gerado pelo Vite)
    └── docs/             # <-- Voce esta aqui
```

Para editar arquivos da raiz (Netlify Functions, netlify.toml, scripts SQL), abra o repositorio completo no editor.
