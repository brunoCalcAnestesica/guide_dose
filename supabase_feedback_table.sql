-- Tabela de feedback dos usuários
-- Execute este SQL no painel do Supabase (SQL Editor) para criar a tabela

CREATE TABLE IF NOT EXISTS feedback (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_email TEXT NOT NULL DEFAULT '',
  tipo TEXT NOT NULL CHECK (tipo IN ('sugestao', 'bug', 'ideia')),
  mensagem TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'em_analise', 'resolvido')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own feedback"
  ON feedback FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read their own feedback"
  ON feedback FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can read all feedback"
  ON feedback FOR SELECT
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role can update feedback"
  ON feedback FOR UPDATE
  USING (auth.role() = 'service_role');
