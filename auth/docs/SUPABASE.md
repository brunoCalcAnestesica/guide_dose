# Configuracao do Supabase (Web)

Referencia rapida para a configuracao do Supabase usada pelo front-end web e pelas Netlify Functions.

> Documento completo na raiz do repo: `CONFIGURAR_SUPABASE.md`

---

## Credenciais

1. Acesse o projeto no Supabase: https://app.supabase.com
2. Va em **Settings > API**.
3. Copie:
   - **Project URL** (ex: `https://xxxxx.supabase.co`)
   - **anon public key** (chave publica)
   - **service_role key** (chave privada, usada apenas no backend)

Essas credenciais sao usadas:
- No front-end web: `SUPABASE_URL` e `SUPABASE_ANON_KEY` (variaveis no painel do Netlify ou `.env` local).
- Nas Netlify Functions: todas as quatro variaveis listadas em [BACKEND.md](BACKEND.md).

---

## Autenticacao (Dashboard do Supabase)

1. **Authentication > Providers**: mantenha **Email** ativo.
2. **Authentication > URL Configuration**:
   - **Site URL**: dominio da web (ex: `https://guidedose.netlify.app`).
   - **Redirect URLs**: adicione a URL do site se necessario.
3. **Authentication > Settings**:
   - Ative **Confirm email** (recomendado).

---

## Scripts SQL

Os scripts abaixo ficam na **raiz do repositorio**. Para executa-los, abra o **SQL Editor** no painel do Supabase, cole o conteudo do arquivo e execute.

| Arquivo (raiz do repo) | Descricao |
|-------------------------|-----------|
| `supabase_profiles_table_and_trigger.sql` | Cria tabela `profiles` e trigger de registro de usuario |
| `supabase_app_config.sql` | Cria tabela `app_config` (versao do app no painel admin) |
| `supabase_feedback_table.sql` | Cria tabela de feedback |
| `supabase_drop_escala.sql` | Drop auxiliar da escala |
| `lib/escala/database/supabase_migrations.sql` | Migracoes da escala |
| `lib/escala/database/supabase_notes_patients_migration.sql` | Migracoes de notas/pacientes |

### Erro "Database error saving new user"

Se ao criar conta aparecer esse erro, execute `supabase_profiles_table_and_trigger.sql` no SQL Editor do Supabase. Esse script cria a tabela `profiles` e o trigger que preenche o perfil automaticamente.

### Tabela app_config

A funcionalidade "Atualizar Versao do App" no painel admin depende da tabela `app_config`. Se nao carregar, execute `supabase_app_config.sql` no SQL Editor.

---

## Seguranca

- **Nunca commite chaves** no repositorio.
- Use **variaveis de ambiente** (painel Netlify em producao, `.env` local em dev).
- Configure **Row Level Security (RLS)** nas tabelas do Supabase.

---

## Recursos

- [Documentacao Supabase JS](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Dashboard](https://app.supabase.com)
