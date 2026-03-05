-- ============================================
-- REMOVER TABELA app_config
-- ============================================
-- Tabela removida por não possuir relação com usuário (sem user_id).
-- A funcionalidade de "aviso de nova versão" deixará de funcionar
-- até que seja reimplementada em uma tabela vinculada a usuário.
--
-- COMO APLICAR: No Supabase Dashboard, SQL Editor, execute este script.
-- ============================================

DROP TABLE IF EXISTS app_config CASCADE;
