-- ============================================
-- SINCRONIZACAO DE MEDICAMENTOS NO SUPABASE
-- ============================================
-- Tabela para sincronizacao bidirecional local-first das listas de
-- medicamentos. Segue o mesmo padrao de notes/patients/shifts.
--
-- COMO APLICAR: No Supabase Dashboard, SQL Editor, execute este script.
-- Seguro para rodar varias vezes (idempotente).
-- ============================================

-- ============================================
-- med_lists (cria se nao existir)
-- ============================================
CREATE TABLE IF NOT EXISTS med_lists (
  id TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  medicamento_ids JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  PRIMARY KEY (id, user_id)
);

COMMENT ON TABLE med_lists IS 'Listas de medicamentos customizadas do usuario';

ALTER TABLE med_lists ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_med_lists_user ON med_lists(user_id);
CREATE INDEX IF NOT EXISTS idx_med_lists_updated ON med_lists(user_id, updated_at);

ALTER TABLE med_lists ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own med_lists" ON med_lists;
CREATE POLICY "Users can view own med_lists"
  ON med_lists FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own med_lists" ON med_lists;
CREATE POLICY "Users can insert own med_lists"
  ON med_lists FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own med_lists" ON med_lists;
CREATE POLICY "Users can update own med_lists"
  ON med_lists FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own med_lists" ON med_lists;
CREATE POLICY "Users can delete own med_lists"
  ON med_lists FOR DELETE USING (auth.uid() = user_id);

-- Remover tabela med_favorites (funcionalidade removida)
DROP TABLE IF EXISTS med_favorites CASCADE;
