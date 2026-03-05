-- ============================================
-- BASE DE CONHECIMENTO COMPARTILHADA SOFIA
-- ============================================
-- Este script cria a tabela para armazenar conhecimento
-- compartilhado que será usado pela IA SofIA
-- Todos os usuários alimentam e consultam o mesmo banco
-- ============================================

-- Criar tabela compartilhada para base de conhecimento SofIA
CREATE TABLE IF NOT EXISTS sofia_knowledge_base (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Usuário que adicionou (opcional)
  title TEXT NOT NULL,
  author TEXT,
  source TEXT, -- Fonte: hospital, protocolo, etc
  file_url TEXT, -- URL do PDF no storage
  file_name TEXT,
  file_size INTEGER,
  content_text TEXT, -- Texto extraído do PDF
  content_chunks JSONB, -- Array de chunks de texto processados
  embeddings JSONB, -- Embeddings dos chunks
  metadata JSONB, -- Metadados adicionais
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE -- Para soft delete
);

-- Comentário
COMMENT ON TABLE sofia_knowledge_base IS 'Base de conhecimento compartilhada SofIA - todos os usuários compartilham o mesmo conhecimento';

-- Índices
CREATE INDEX IF NOT EXISTS idx_sofia_kb_title ON sofia_knowledge_base(title);
CREATE INDEX IF NOT EXISTS idx_sofia_kb_author ON sofia_knowledge_base(author);
CREATE INDEX IF NOT EXISTS idx_sofia_kb_uploaded_at ON sofia_knowledge_base(uploaded_at DESC);
CREATE INDEX IF NOT EXISTS idx_sofia_kb_active ON sofia_knowledge_base(is_active) WHERE is_active = TRUE;

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_sofia_kb_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_sofia_kb_updated_at_trigger ON sofia_knowledge_base;
CREATE TRIGGER update_sofia_kb_updated_at_trigger
  BEFORE UPDATE ON sofia_knowledge_base
  FOR EACH ROW
  EXECUTE FUNCTION update_sofia_kb_updated_at();

-- Habilitar RLS
ALTER TABLE sofia_knowledge_base ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ver conhecimento ativo (base compartilhada)
DROP POLICY IF EXISTS "Anyone can view active Sofia knowledge" ON sofia_knowledge_base;
CREATE POLICY "Anyone can view active Sofia knowledge"
  ON sofia_knowledge_base FOR SELECT
  USING (is_active = TRUE);

-- Política: Usuários autenticados podem adicionar conhecimento
DROP POLICY IF EXISTS "Authenticated users can add Sofia knowledge" ON sofia_knowledge_base;
CREATE POLICY "Authenticated users can add Sofia knowledge"
  ON sofia_knowledge_base FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Política: Usuários podem atualizar apenas o que adicionaram (opcional)
DROP POLICY IF EXISTS "Users can update own Sofia knowledge" ON sofia_knowledge_base;
CREATE POLICY "Users can update own Sofia knowledge"
  ON sofia_knowledge_base FOR UPDATE
  USING (auth.uid() = user_id OR user_id IS NULL)
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Política: Usuários podem fazer soft delete apenas do que adicionaram (opcional)
DROP POLICY IF EXISTS "Users can delete own Sofia knowledge" ON sofia_knowledge_base;
CREATE POLICY "Users can delete own Sofia knowledge"
  ON sofia_knowledge_base FOR DELETE
  USING (auth.uid() = user_id OR user_id IS NULL);

-- ============================================
-- PRÓXIMOS PASSOS:
-- ============================================
-- 1. Criar bucket de storage "sofia_knowledge" no Supabase Dashboard
-- 2. Configurar políticas de acesso do storage
-- 3. Testar upload de PDFs
-- ============================================
