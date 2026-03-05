-- ============================================
-- BASE DE CONHECIMENTO DA IA
-- ============================================
-- Este script cria a tabela para armazenar conhecimento
-- que será usado pela IA com prioridade nas respostas
-- ============================================

-- Criar tabela para armazenar chunks de texto com embeddings para busca semântica
-- Usando JSONB para embeddings (pgvector não está habilitado por padrão)
CREATE TABLE IF NOT EXISTS ai_knowledge_base (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  source_type TEXT NOT NULL, -- 'library_book', 'manual_entry', 'document'
  source_id UUID, -- ID do livro ou documento original (opcional)
  title TEXT NOT NULL, -- Título da fonte
  content TEXT NOT NULL, -- Texto do chunk
  embedding JSONB, -- Embedding do OpenAI armazenado como JSONB (array de números)
  metadata JSONB, -- Metadados adicionais (autor, página, etc)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comentário
COMMENT ON TABLE ai_knowledge_base IS 'Base de conhecimento da IA com embeddings para busca semântica';

-- Índices para busca por usuário
CREATE INDEX IF NOT EXISTS idx_ai_kb_user_id ON ai_knowledge_base(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_kb_source ON ai_knowledge_base(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_ai_kb_created_at ON ai_knowledge_base(created_at DESC);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_ai_kb_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_ai_kb_updated_at_trigger ON ai_knowledge_base;
CREATE TRIGGER update_ai_kb_updated_at_trigger
  BEFORE UPDATE ON ai_knowledge_base
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_kb_updated_at();

-- Habilitar RLS
ALTER TABLE ai_knowledge_base ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver apenas seus próprios dados
DROP POLICY IF EXISTS "Users can view own AI knowledge base" ON ai_knowledge_base;
CREATE POLICY "Users can view own AI knowledge base"
  ON ai_knowledge_base FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Usuários podem inserir seus próprios dados
DROP POLICY IF EXISTS "Users can insert own AI knowledge base" ON ai_knowledge_base;
CREATE POLICY "Users can insert own AI knowledge base"
  ON ai_knowledge_base FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem atualizar seus próprios dados
DROP POLICY IF EXISTS "Users can update own AI knowledge base" ON ai_knowledge_base;
CREATE POLICY "Users can update own AI knowledge base"
  ON ai_knowledge_base FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem deletar seus próprios dados
DROP POLICY IF EXISTS "Users can delete own AI knowledge base" ON ai_knowledge_base;
CREATE POLICY "Users can delete own AI knowledge base"
  ON ai_knowledge_base FOR DELETE
  USING (auth.uid() = user_id);
