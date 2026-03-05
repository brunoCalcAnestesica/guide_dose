-- ============================================================
-- DROP COMPLETO: remove todas as tabelas, funções e triggers
-- do módulo ESCALA do Supabase.
-- ============================================================
-- Execute no Supabase SQL Editor.
--
-- ATENÇÃO: isso é IRREVERSÍVEL. Faça backup/snapshot antes.
--
-- DROP TABLE ... CASCADE remove automaticamente:
--   - Todas as policies RLS
--   - Todos os triggers
--   - Todos os índices
--   - Todas as partições (no caso de shifts)
-- ============================================================

DROP TABLE IF EXISTS user_hospitals CASCADE;
DROP TABLE IF EXISTS shifts CASCADE;
DROP TABLE IF EXISTS shift_reports CASCADE;
DROP TABLE IF EXISTS procedures CASCADE;
DROP TABLE IF EXISTS procedure_types CASCADE;
DROP TABLE IF EXISTS hospitals CASCADE;
DROP TABLE IF EXISTS blocked_days CASCADE;
DROP TABLE IF EXISTS notes CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

DROP FUNCTION IF EXISTS create_manual_hospital CASCADE;

-- Tabelas legadas de backup (se existirem)
DROP TABLE IF EXISTS user_hospitals_old CASCADE;
DROP TABLE IF EXISTS shifts_old CASCADE;
DROP TABLE IF EXISTS hospitals_old CASCADE;
DROP TABLE IF EXISTS procedures_old CASCADE;
DROP TABLE IF EXISTS procedure_types_old CASCADE;
DROP TABLE IF EXISTS blocked_days_old CASCADE;
DROP TABLE IF EXISTS notes_old CASCADE;
DROP TABLE IF EXISTS patients_old CASCADE;
DROP TABLE IF EXISTS shift_reports_old CASCADE;

-- Função de trigger compartilhada
DROP FUNCTION IF EXISTS update_escala_updated_at() CASCADE;

-- ============================================================
-- PRONTO! Todas as tabelas da escala foram removidas.
-- As tabelas profiles, feedback, app_config e med_*
-- NÃO foram afetadas.
-- ============================================================
