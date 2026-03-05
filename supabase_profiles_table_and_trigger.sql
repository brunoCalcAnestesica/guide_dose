-- ============================================
-- TABELA profiles + TRIGGER para novo usuário
-- Execute no Supabase SQL Editor para corrigir
-- o erro "Database error saving new user".
-- ============================================

-- 1) Remover trigger e função antigos (se existirem e estiverem quebrados)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created_insert ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS auth.handle_new_user();

-- 2) Criar tabela profiles (se não existir)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  crm TEXT,
  crm_nao_formado BOOLEAN DEFAULT false,
  address TEXT,
  phone TEXT,
  specialty TEXT,
  rqe TEXT,
  access_count INTEGER DEFAULT 0,
  last_access_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'Perfil do usuário (criado automaticamente no signup)';

-- 3) RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Permite que o usuário insira seu próprio perfil (trigger roda no contexto do signup)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Se o trigger ainda falhar por RLS, descomente e execute no SQL Editor:
-- CREATE POLICY "Allow trigger insert" ON public.profiles FOR INSERT WITH CHECK (true);

-- 4) Função que insere o perfil ao criar usuário (roda com privilégios do dono, ignora RLS no INSERT)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'email', NEW.email),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = COALESCE(EXCLUDED.email, public.profiles.email),
    updated_at = NOW();
  RETURN NEW;
END;
$$;

-- 5) Trigger em auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
