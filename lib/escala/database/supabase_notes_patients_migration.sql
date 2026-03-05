-- Migration: Create notes & patients tables for Supabase
-- Run this in the Supabase SQL editor

-- ═══════════════════════════════════════════════════════════
-- 1. Notes (active)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.notes (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'Sem título',
  content TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own notes"
  ON public.notes FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_notes_user ON public.notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_user_updated ON public.notes(user_id, updated_at);

-- ═══════════════════════════════════════════════════════════
-- 2. Notes Archive (archived — no local copy)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.notes_archive (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'Sem título',
  content TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notes_archive ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own archived notes"
  ON public.notes_archive FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_notes_archive_user ON public.notes_archive(user_id);

-- ═══════════════════════════════════════════════════════════
-- 3. Patients (active)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.patients (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  initials TEXT NOT NULL DEFAULT '',
  age DOUBLE PRECISION,
  age_unit TEXT NOT NULL DEFAULT 'anos',
  admission_date DATE,
  bed TEXT NOT NULL DEFAULT '',
  history TEXT NOT NULL DEFAULT '',
  devices TEXT NOT NULL DEFAULT '',
  diagnosis TEXT NOT NULL DEFAULT '',
  antibiotics TEXT NOT NULL DEFAULT '',
  vasoactive_drugs TEXT NOT NULL DEFAULT '',
  exams TEXT NOT NULL DEFAULT '',
  pending TEXT NOT NULL DEFAULT '',
  observations TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own patients"
  ON public.patients FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_patients_user ON public.patients(user_id);
CREATE INDEX IF NOT EXISTS idx_patients_user_updated ON public.patients(user_id, updated_at);

-- ═══════════════════════════════════════════════════════════
-- 4. Patients Archive (archived — no local copy)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.patients_archive (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  initials TEXT NOT NULL DEFAULT '',
  age DOUBLE PRECISION,
  age_unit TEXT NOT NULL DEFAULT 'anos',
  admission_date DATE,
  bed TEXT NOT NULL DEFAULT '',
  history TEXT NOT NULL DEFAULT '',
  devices TEXT NOT NULL DEFAULT '',
  diagnosis TEXT NOT NULL DEFAULT '',
  antibiotics TEXT NOT NULL DEFAULT '',
  vasoactive_drugs TEXT NOT NULL DEFAULT '',
  exams TEXT NOT NULL DEFAULT '',
  pending TEXT NOT NULL DEFAULT '',
  observations TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.patients_archive ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own archived patients"
  ON public.patients_archive FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_patients_archive_user ON public.patients_archive(user_id);
