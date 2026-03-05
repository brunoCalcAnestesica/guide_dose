-- ============================================================================
-- MIGRATION COMPLETA – GuideDose
-- Cole tudo no SQL Editor do Supabase e clique Run.
-- Seguro: todos os comandos usam IF NOT EXISTS / IF EXISTS.
-- ============================================================================


-- ############################################################################
-- BLOCO 1: PROFILES (necessário para auth, admin e dados cadastrais)
-- ############################################################################

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  crm TEXT,
  crm_nao_formado BOOLEAN DEFAULT false,
  address TEXT,
  phone TEXT,
  specialty TEXT,
  rqe TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can manage their own profile'
  ) THEN
    CREATE POLICY "Users can manage their own profile"
      ON public.profiles FOR ALL
      USING (auth.uid() = id)
      WITH CHECK (auth.uid() = id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);


-- ############################################################################
-- BLOCO 2: APP_CONFIG (broadcast, billing, versão)
-- ############################################################################

CREATE TABLE IF NOT EXISTS public.app_config (
  key TEXT PRIMARY KEY,
  value TEXT
);

ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'app_config' AND policyname = 'Anyone can read app_config'
  ) THEN
    CREATE POLICY "Anyone can read app_config"
      ON public.app_config FOR SELECT
      USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'app_config' AND policyname = 'Admins can manage app_config'
  ) THEN
    CREATE POLICY "Admins can manage app_config"
      ON public.app_config FOR ALL
      USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
      );
  END IF;
END $$;


-- ############################################################################
-- BLOCO 3: ESCALA – shifts, recurrence_rules, shift_reports, blocked_days
-- ############################################################################

-- 3.1 Shifts
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
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.shifts ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'shifts' AND policyname = 'Users can manage their own shifts'
  ) THEN
    CREATE POLICY "Users can manage their own shifts"
      ON public.shifts FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON public.shifts(user_id, date);
CREATE INDEX IF NOT EXISTS idx_shifts_user_updated ON public.shifts(user_id, updated_at);

-- 3.2 Recurrence Rules
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
  paid_dates JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.recurrence_rules ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'recurrence_rules' AND policyname = 'Users can manage their own recurrence rules'
  ) THEN
    CREATE POLICY "Users can manage their own recurrence rules"
      ON public.recurrence_rules FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_recurrence_rules_user ON public.recurrence_rules(user_id);
CREATE INDEX IF NOT EXISTS idx_recurrence_rules_user_updated ON public.recurrence_rules(user_id, updated_at);

-- 3.3 Shift Reports
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

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'shift_reports' AND policyname = 'Users can manage their own shift reports'
  ) THEN
    CREATE POLICY "Users can manage their own shift reports"
      ON public.shift_reports FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_shift_reports_user_year_month ON public.shift_reports(user_id, year, month);
CREATE INDEX IF NOT EXISTS idx_shift_reports_user_updated ON public.shift_reports(user_id, updated_at);

-- 3.4 Blocked Days
CREATE TABLE IF NOT EXISTS public.blocked_days (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  label TEXT NOT NULL DEFAULT 'Feriado',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.blocked_days ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'blocked_days' AND policyname = 'Users can manage their own blocked days'
  ) THEN
    CREATE POLICY "Users can manage their own blocked days"
      ON public.blocked_days FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_blocked_days_user_date ON public.blocked_days(user_id, date);
CREATE INDEX IF NOT EXISTS idx_blocked_days_user_updated ON public.blocked_days(user_id, updated_at);


-- ############################################################################
-- BLOCO 4: NOTES e PATIENTS (anotações e pacientes)
-- ############################################################################

-- 4.1 Notes
CREATE TABLE IF NOT EXISTS public.notes (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'Sem título',
  content TEXT DEFAULT '',
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notes' AND policyname = 'Users can manage their own notes'
  ) THEN
    CREATE POLICY "Users can manage their own notes"
      ON public.notes FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_notes_user_updated ON public.notes(user_id, updated_at);

-- 4.2 Patients
CREATE TABLE IF NOT EXISTS public.patients (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  initials TEXT DEFAULT '',
  age DOUBLE PRECISION,
  age_unit TEXT DEFAULT 'anos',
  admission_date DATE,
  bed TEXT DEFAULT '',
  history TEXT DEFAULT '',
  devices TEXT DEFAULT '',
  diagnosis TEXT DEFAULT '',
  antibiotics TEXT DEFAULT '',
  vasoactive_drugs TEXT DEFAULT '',
  exams TEXT DEFAULT '',
  pending TEXT DEFAULT '',
  observations TEXT DEFAULT '',
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'patients' AND policyname = 'Users can manage their own patients'
  ) THEN
    CREATE POLICY "Users can manage their own patients"
      ON public.patients FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_patients_user_updated ON public.patients(user_id, updated_at);


-- ############################################################################
-- BLOCO 5: MED_LISTS (listas de medicamentos customizadas)
-- ############################################################################

CREATE TABLE IF NOT EXISTS public.med_lists (
  id TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL DEFAULT '',
  medicamento_ids JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id, user_id)
);

ALTER TABLE public.med_lists ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'med_lists' AND policyname = 'Users can manage their own med_lists'
  ) THEN
    CREATE POLICY "Users can manage their own med_lists"
      ON public.med_lists FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_med_lists_user_updated ON public.med_lists(user_id, updated_at);


-- ############################################################################
-- BLOCO 6: PUSH NOTIFICATIONS (FCM tokens, log, agendamentos, preferências)
-- ############################################################################

-- 6.1 FCM Tokens
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'fcm_tokens' AND policyname = 'Users manage own fcm_tokens'
  ) THEN
    CREATE POLICY "Users manage own fcm_tokens"
      ON public.fcm_tokens FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user ON public.fcm_tokens(user_id);

-- 6.2 Push Notifications log
CREATE TABLE IF NOT EXISTS public.push_notifications (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'user', 'users', 'segment')),
  target_value TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  link TEXT,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  tokens_count INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'manual'
);

ALTER TABLE public.push_notifications ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'push_notifications' AND policyname = 'Admins manage push_notifications'
  ) THEN
    CREATE POLICY "Admins manage push_notifications"
      ON public.push_notifications FOR ALL
      USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
      );
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_push_notifications_sent ON public.push_notifications(sent_at DESC);

-- 6.3 Push Schedules
CREATE TABLE IF NOT EXISTS public.push_schedules (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'user', 'users', 'segment')),
  target_value TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  link TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  recurrence TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.push_schedules ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'push_schedules' AND policyname = 'Admins manage push_schedules'
  ) THEN
    CREATE POLICY "Admins manage push_schedules"
      ON public.push_schedules FOR ALL
      USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
      );
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_push_schedules_next ON public.push_schedules(scheduled_at)
  WHERE is_active = true;

-- 6.4 Notification Preferences
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN NOT NULL DEFAULT true,
  eve_shift_enabled BOOLEAN NOT NULL DEFAULT true,
  blocked_day_enabled BOOLEAN NOT NULL DEFAULT true,
  broadcast_enabled BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notification_preferences' AND policyname = 'Users manage own notification_preferences'
  ) THEN
    CREATE POLICY "Users manage own notification_preferences"
      ON public.notification_preferences FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;


-- ############################################################################
-- BLOCO 7: FUNÇÕES AUXILIARES
-- ############################################################################

-- Função para verificar se o usuário é admin (usada pelas Edge Functions)
CREATE OR REPLACE FUNCTION public.is_admin(uid UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = uid AND role = 'admin'
  );
$$;


-- ############################################################################
-- BLOCO 8: MARCAR ADMIN
-- ############################################################################

-- Garante que o profile do admin existe
INSERT INTO public.profiles (id, email, role)
SELECT id, email, 'admin'
FROM auth.users
WHERE email = 'bhdaroz@gmail.com'
ON CONFLICT (id) DO UPDATE SET role = 'admin';


-- ============================================================================
-- FIM. Todas as tabelas criadas com RLS habilitado.
-- ============================================================================
