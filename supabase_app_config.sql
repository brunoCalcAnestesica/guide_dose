-- ============================================
-- TABELA app_config — configurações gerais do app
-- Execute no Supabase SQL Editor para ativar a
-- funcionalidade "Atualizar Versão do App" no painel admin.
-- ============================================

CREATE TABLE IF NOT EXISTS app_config (
  key   TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE app_config IS 'Configurações gerais do app (versão, changelog, etc.)';

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Leitura pública (anon + authenticated) para o app e o painel carregarem
DROP POLICY IF EXISTS "Anyone can read app_config" ON app_config;
CREATE POLICY "Anyone can read app_config"
  ON app_config FOR SELECT
  USING (true);

-- Escrita apenas para usuários autenticados (painel admin)
DROP POLICY IF EXISTS "Authenticated can write app_config" ON app_config;
CREATE POLICY "Authenticated can write app_config"
  ON app_config FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Valores iniciais (não sobrescreve se já existirem)
INSERT INTO app_config (key, value) VALUES
  ('current_version',      '3.7.0'),
  ('min_required_version', '3.7.0'),
  ('changelog',            ''),
  ('latest_ios_version',     '3.7.0'),
  ('latest_android_version', '3.7.0')
ON CONFLICT (key) DO NOTHING;
