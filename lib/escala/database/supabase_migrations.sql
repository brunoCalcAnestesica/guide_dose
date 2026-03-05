-- Migration: Create escala tables for Supabase
-- Run this in the Supabase SQL editor

-- 1. Shifts (non-recurring events)
CREATE TABLE IF NOT EXISTS public.shifts (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  hospital_name TEXT NOT NULL,
  date DATE NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  duration_hours DOUBLE PRECISION NOT NULL DEFAULT 0,
  value DOUBLE PRECISION NOT NULL DEFAULT 0,
  type TEXT NOT NULL,
  informacoes TEXT,
  is_all_day BOOLEAN NOT NULL DEFAULT false,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.shifts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own shifts"
  ON public.shifts FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON public.shifts(user_id, date);

-- 2. Recurrence Rules
CREATE TABLE IF NOT EXISTS public.recurrence_rules (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  hospital_name TEXT NOT NULL,
  start_date DATE NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  duration_hours DOUBLE PRECISION NOT NULL DEFAULT 0,
  value DOUBLE PRECISION NOT NULL DEFAULT 0,
  type TEXT NOT NULL,
  informations TEXT,
  is_all_day BOOLEAN NOT NULL DEFAULT false,
  recurrence_rule JSONB,
  end_date DATE,
  excluded_dates JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.recurrence_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own recurrence rules"
  ON public.recurrence_rules FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_recurrence_rules_user ON public.recurrence_rules(user_id);

-- 3. Shift Reports
CREATE TABLE IF NOT EXISTS public.shift_reports (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  total_hours DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  shifts_count INTEGER NOT NULL DEFAULT 0,
  paid_count INTEGER NOT NULL DEFAULT 0,
  paid_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  pending_count INTEGER NOT NULL DEFAULT 0,
  pending_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  by_hospital JSONB DEFAULT '{}',
  by_type JSONB DEFAULT '{}',
  details JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, year, month)
);

ALTER TABLE public.shift_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own shift reports"
  ON public.shift_reports FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_shift_reports_user_year_month ON public.shift_reports(user_id, year, month);

-- Migration v2: Add excluded_dates to recurrence_rules
-- Run this if the table already exists:
-- ALTER TABLE public.recurrence_rules ADD COLUMN excluded_dates JSONB DEFAULT '[]';

-- Migration v3: Add updated_at to shifts for incremental sync
ALTER TABLE public.shifts ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- If the table already has data, back-fill updated_at from created_at:
-- UPDATE public.shifts SET updated_at = created_at WHERE updated_at = now();

-- Create index for incremental sync queries
CREATE INDEX IF NOT EXISTS idx_shifts_user_updated ON public.shifts(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_recurrence_rules_user_updated ON public.recurrence_rules(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_shift_reports_user_updated ON public.shift_reports(user_id, updated_at);

-- 4. Blocked Days
CREATE TABLE IF NOT EXISTS public.blocked_days (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  label TEXT NOT NULL DEFAULT 'Feriado',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.blocked_days ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own blocked days"
  ON public.blocked_days FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_blocked_days_user_date ON public.blocked_days(user_id, date);
CREATE INDEX IF NOT EXISTS idx_blocked_days_user_updated ON public.blocked_days(user_id, updated_at);

-- Migration v5: Add paid_dates to recurrence_rules
ALTER TABLE public.recurrence_rules ADD COLUMN paid_dates JSONB DEFAULT '[]';
