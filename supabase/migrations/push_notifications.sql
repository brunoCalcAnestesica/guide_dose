-- Migration: Push Notifications System
-- Run this in the Supabase SQL editor

-- ============================================================
-- 1. Add role column to profiles (admin vs user)
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';

CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- ============================================================
-- 2. FCM Tokens – one per device/platform
-- ============================================================
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can manage only their own tokens
CREATE POLICY "Users manage own fcm_tokens"
  ON public.fcm_tokens FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user ON public.fcm_tokens(user_id);

-- ============================================================
-- 3. Push Notifications log
-- ============================================================
CREATE TABLE IF NOT EXISTS public.push_notifications (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'user', 'users', 'segment')),
  target_value TEXT,                       -- user_id, comma-separated ids, or segment key
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  link TEXT,                               -- deep link or URL to open on tap
  sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  tokens_count INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'manual'    -- manual | broadcast | schedule | auto_blocked | auto_eve
);

ALTER TABLE public.push_notifications ENABLE ROW LEVEL SECURITY;

-- Only admins can read/write
CREATE POLICY "Admins manage push_notifications"
  ON public.push_notifications FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE INDEX IF NOT EXISTS idx_push_notifications_sent ON public.push_notifications(sent_at DESC);

-- ============================================================
-- 4. Push Schedules (agendadas / recorrentes)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.push_schedules (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'user', 'users', 'segment')),
  target_value TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  link TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  recurrence TEXT,                         -- null = one-time; 'daily' | 'weekly' | 'monthly' | cron
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.push_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage push_schedules"
  ON public.push_schedules FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE INDEX IF NOT EXISTS idx_push_schedules_next ON public.push_schedules(scheduled_at)
  WHERE is_active = true;

-- ============================================================
-- 5. Notification preferences per user
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN NOT NULL DEFAULT true,
  eve_shift_enabled BOOLEAN NOT NULL DEFAULT true,
  blocked_day_enabled BOOLEAN NOT NULL DEFAULT true,
  broadcast_enabled BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own notification_preferences"
  ON public.notification_preferences FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 6. Helper: check if user is admin (for Edge Functions)
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_admin(uid UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = uid AND role = 'admin'
  );
$$;
