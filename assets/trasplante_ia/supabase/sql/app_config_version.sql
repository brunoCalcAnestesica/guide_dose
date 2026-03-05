-- ============================================
-- [REMOVIDA] CONFIGURAÇÃO DE VERSÃO DO APP (UPDATE CHECK)
-- ============================================
-- NOTA: Esta tabela foi removida por não possuir relação com usuário
-- (sem user_id). Veja drop_app_config.sql para o script de remoção.
--
-- O conteúdo abaixo é mantido apenas como referência histórica.
-- NÃO execute este script; a tabela não deve mais existir.
-- ============================================

CREATE TABLE IF NOT EXISTS app_config (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE app_config IS 'Configurações gerais do app (ex: versão mais recente nas lojas)';

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Leitura pública (anon) para qualquer um poder ver a versão mais recente
DROP POLICY IF EXISTS "Anyone can read app_config" ON app_config;
CREATE POLICY "Anyone can read app_config"
  ON app_config FOR SELECT
  USING (true);

-- Apenas serviço/backend deve atualizar (ajuste a policy conforme seu auth)
DROP POLICY IF EXISTS "Service can update app_config" ON app_config;
CREATE POLICY "Service can update app_config"
  ON app_config FOR ALL
  USING (true)
  WITH CHECK (true);

-- Valores iniciais: versão atual do app (atualize ao publicar nova versão)
INSERT INTO app_config (key, value) VALUES
  ('latest_ios_version', '3.6.3'),
  ('latest_android_version', '3.6.3')
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  updated_at = NOW();

-- Para atualizar manualmente após publicar nova versão, execute por exemplo:
-- UPDATE app_config SET value = '3.6.4', updated_at = NOW() WHERE key = 'latest_ios_version';
-- UPDATE app_config SET value = '3.6.4', updated_at = NOW() WHERE key = 'latest_android_version';

-- Atualização para versão 3.6.3 (executar no Supabase após publicar nas lojas):
-- UPDATE app_config SET value = '3.6.3', updated_at = NOW() WHERE key IN ('latest_ios_version', 'latest_android_version');
