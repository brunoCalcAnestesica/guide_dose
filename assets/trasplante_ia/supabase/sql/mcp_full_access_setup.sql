-- =============================================================
-- SQL para conceder acesso total ao Cursor AI via MCP Supabase
-- Execute este script no SQL Editor do Supabase Dashboard
-- =============================================================

-- 1) Criar a função RPC get_tables_info (exigida pelo pacote supabase-mcp)
CREATE OR REPLACE FUNCTION public.get_tables_info()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_agg(
    jsonb_build_object(
      'name', t.table_name,
      'schema', t.table_schema,
      'columns', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'name', c.column_name,
            'type', c.data_type,
            'is_nullable', (c.is_nullable = 'YES'),
            'is_identity', (c.is_identity = 'YES'),
            'is_primary_key', EXISTS (
              SELECT 1
              FROM information_schema.key_column_usage kcu
              JOIN information_schema.table_constraints tc
                ON tc.constraint_name = kcu.constraint_name
                AND tc.table_schema = kcu.table_schema
              WHERE tc.constraint_type = 'PRIMARY KEY'
                AND kcu.table_schema = c.table_schema
                AND kcu.table_name = c.table_name
                AND kcu.column_name = c.column_name
            )
          )
          ORDER BY c.ordinal_position
        )
        FROM information_schema.columns c
        WHERE c.table_schema = t.table_schema
          AND c.table_name = t.table_name
      )
    )
  )
  INTO result
  FROM information_schema.tables t
  WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE';

  RETURN COALESCE(result, '[]'::jsonb);
END;
$$;

-- 2) Conceder permissão de execução da função
GRANT EXECUTE ON FUNCTION public.get_tables_info() TO anon;
GRANT EXECUTE ON FUNCTION public.get_tables_info() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_tables_info() TO service_role;

-- 3) Garantir que service_role tem acesso total ao schema public
GRANT ALL ON SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- 4) Garantir acesso futuro automatico para novas tabelas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON FUNCTIONS TO service_role;

-- 5) Conceder acesso de leitura para anon (usado como fallback)
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO anon;

-- =============================================================
-- PRONTO! Após executar, o Cursor AI terá acesso total via MCP.
-- O service_role key já ignora RLS automaticamente.
-- =============================================================
