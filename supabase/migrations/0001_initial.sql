-- 0001_initial.sql — Phase 2 initial schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users profile (auth.users와 연동)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL CHECK (char_length(nickname) BETWEEN 2 AND 12),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Pets
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  species TEXT NOT NULL CHECK (species IN ('bird', 'dragon', 'dolphin')),
  name TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 10),
  level INT NOT NULL DEFAULT 1,
  xp INT NOT NULL DEFAULT 0,
  hp INT NOT NULL DEFAULT 100,
  is_alive BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  died_at TIMESTAMPTZ,
  death_cause TEXT
);

-- Schedules (시간 구간 일정)
CREATE TABLE IF NOT EXISTS public.schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('work', 'study', 'hobby', 'health', 'etc')),
  tags TEXT[] DEFAULT '{}',
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  is_todo BOOLEAN NOT NULL DEFAULT false,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Daily scores
CREATE TABLE IF NOT EXISTS public.daily_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score_date DATE NOT NULL,
  focus_ratio REAL,
  grade TEXT CHECK (grade IN ('S', 'A', 'B', 'C', 'D')),
  xp_earned INT NOT NULL DEFAULT 0,
  hp_change INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, score_date)
);

-- Outbox (sync queue)
CREATE TABLE IF NOT EXISTS public.outbox (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  aggregate_type TEXT NOT NULL,
  aggregate_id TEXT NOT NULL,
  op TEXT NOT NULL CHECK (op IN ('create', 'update', 'delete')),
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  attempts INT NOT NULL DEFAULT 0,
  sent_at TIMESTAMPTZ
);

-- RLS 정책 (rules.md §8.3: RLS 없는 테이블 금지)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outbox ENABLE ROW LEVEL SECURITY;

-- Profiles: 본인만 CRUD
CREATE POLICY "profiles_select_own" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Pets: 본인만 CRUD
CREATE POLICY "pets_select_own" ON public.pets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "pets_insert_own" ON public.pets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "pets_update_own" ON public.pets FOR UPDATE USING (auth.uid() = user_id);

-- Schedules: 본인만 CRUD
CREATE POLICY "schedules_select_own" ON public.schedules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "schedules_insert_own" ON public.schedules FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "schedules_update_own" ON public.schedules FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "schedules_delete_own" ON public.schedules FOR DELETE USING (auth.uid() = user_id);

-- Daily scores: 본인만 읽기/쓰기
CREATE POLICY "daily_scores_select_own" ON public.daily_scores FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "daily_scores_insert_own" ON public.daily_scores FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Outbox: 본인만 쓰기 (sync 엔진이 읽기)
CREATE POLICY "outbox_insert_own" ON public.outbox FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "outbox_select_own" ON public.outbox FOR SELECT USING (auth.uid() = user_id);
