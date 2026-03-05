# Deploy automático no Netlify

## Deploy automático (recomendado)

Para o site atualizar **sozinho** sempre que você der push no Git:

1. Acesse [app.netlify.com](https://app.netlify.com) e abra o site do GuideDose.
2. Vá em **Site configuration** → **Build & deploy** → **Continuous deployment**.
3. Em **Link repository**, conecte seu repositório (GitHub, GitLab ou Bitbucket).
4. Escolha o repositório e o **branch** (ex.: `main`). O Netlify usa o `netlify.toml` da raiz do projeto.
5. A partir daí, **cada `git push`** no branch configurado dispara um build e publica o site.

Fluxo no dia a dia:

```bash
git add .
git commit -m "Sua alteração"
git push
```

O Netlify faz o build (`cd auth && npm install && npm run build`) e publica em **alguns minutos**. Você pode acompanhar em **Deploys** no painel do Netlify.

## Deploy manual (opcional)

Se quiser publicar sem dar push (por exemplo, para testar produção):

```bash
# Na raiz do projeto (uma vez)
npx netlify login

# Deploy para produção
npm run deploy
```

O script `deploy` na raiz chama `netlify deploy --prod` e usa o mesmo build definido no `netlify.toml`.

---

## Deploy automático após cada commit (hook)

Para o deploy rodar **sozinho depois de cada `git commit`** (sem precisar dar push):

1. Faça login no Netlify uma vez (se ainda não fez):
   ```bash
   npx netlify login
   ```

2. Instale o hook (uma vez por máquina):
   ```bash
   chmod +x scripts/install-deploy-hook.sh
   ./scripts/install-deploy-hook.sh
   ```

3. A partir daí, **cada vez que você der `git commit`**, o script vai rodar `npm run deploy` e publicar no Netlify.

Para desativar: `rm .git/hooks/post-commit`

---

## Tabela app_config (Supabase)

A funcionalidade **"Atualizar Versão do App"** no painel admin depende da tabela `app_config` no Supabase.

Se a página não carregar ou não salvar, execute o script `supabase_app_config.sql` no **Supabase SQL Editor** para criar a tabela e as policies de acesso:

1. Abra o painel do Supabase → **SQL Editor**.
2. Cole o conteúdo de `supabase_app_config.sql` (na raiz do projeto).
3. Execute.

Depois disso a página de versão no painel admin deve funcionar normalmente.
