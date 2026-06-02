-- Initial Supabase schema for the divination app MVP.
-- Free readings use fixed DB interpretations. Plus AI readings are created
-- through Edge Functions after subscription and usage checks.

create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  provider text,
  is_anonymous boolean not null default true,
  language_code text not null default 'ko',
  timezone text not null default 'Asia/Seoul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.divination_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  display_name text,
  description text,
  origin_region text,
  is_plus_only boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.divination_items (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  code text not null,
  name text not null,
  display_name text,
  description text,
  image_url text,
  keywords text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb,
  order_no integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (divination_type_id, code)
);

create table public.interpretations (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.divination_items(id) on delete cascade,
  orientation text not null default 'none',
  category text not null default 'general',
  summary text not null,
  detail text,
  advice text,
  warning text,
  keywords text[] not null default '{}',
  language_code text not null default 'ko',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint interpretations_orientation_check
    check (orientation in ('upright', 'reversed', 'none')),
  constraint interpretations_category_check
    check (category in ('general', 'love', 'career', 'money', 'health', 'relationship')),
  unique (item_id, orientation, category, language_code)
);

create table public.readings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  divination_type_id uuid not null references public.divination_types(id),
  spread_code text not null default 'single',
  question text,
  category text not null default 'general',
  result_type text not null default 'free',
  result_text text,
  result_json jsonb not null default '{}'::jsonb,
  is_ai_generated boolean not null default false,
  language_code text not null default 'ko',
  created_at timestamptz not null default now(),
  constraint readings_category_check
    check (category in ('general', 'love', 'career', 'money', 'health', 'relationship')),
  constraint readings_result_type_check
    check (result_type in ('free', 'plus_ai')),
  constraint readings_ai_consistency_check
    check (
      (result_type = 'free' and is_ai_generated = false)
      or (result_type = 'plus_ai' and is_ai_generated = true)
    )
);

create table public.reading_items (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null references public.readings(id) on delete cascade,
  item_id uuid not null references public.divination_items(id),
  orientation text not null default 'none',
  position_name text,
  position_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint reading_items_orientation_check
    check (orientation in ('upright', 'reversed', 'none')),
  unique (reading_id, position_order)
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider text not null default 'revenuecat',
  revenuecat_app_user_id text,
  product_id text,
  entitlement_id text not null default 'plus',
  status text not null default 'expired',
  current_period_start timestamptz,
  current_period_end timestamptz,
  raw_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint subscriptions_provider_check check (provider in ('revenuecat')),
  constraint subscriptions_status_check
    check (status in ('active', 'trial', 'expired', 'cancelled')),
  unique (user_id, provider, entitlement_id)
);

create table public.daily_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  usage_date date not null default current_date,
  free_reading_count integer not null default 0,
  ai_reading_count integer not null default 0,
  integrated_ai_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, usage_date),
  constraint daily_usage_nonnegative_check
    check (
      free_reading_count >= 0
      and ai_reading_count >= 0
      and integrated_ai_count >= 0
    )
);

create table public.prompt_templates (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  system_prompt text not null,
  user_prompt_template text not null,
  language_code text not null default 'ko',
  version integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (code, language_code, version)
);

create table public.ai_results (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null unique references public.readings(id) on delete cascade,
  prompt_template_id uuid references public.prompt_templates(id),
  model_name text not null,
  prompt_tokens integer not null default 0,
  completion_tokens integer not null default 0,
  total_tokens integer not null default 0,
  estimated_cost_usd numeric(12, 6),
  prompt_text text,
  result_json jsonb not null default '{}'::jsonb,
  status text not null default 'succeeded',
  error_message text,
  created_at timestamptz not null default now(),
  constraint ai_results_status_check
    check (status in ('succeeded', 'failed')),
  constraint ai_results_tokens_nonnegative_check
    check (prompt_tokens >= 0 and completion_tokens >= 0 and total_tokens >= 0)
);

create index divination_items_type_order_idx
  on public.divination_items (divination_type_id, order_no);

create index interpretations_lookup_idx
  on public.interpretations (item_id, orientation, category, language_code)
  where is_active = true;

create index readings_user_created_idx
  on public.readings (user_id, created_at desc);

create index daily_usage_user_date_idx
  on public.daily_usage (user_id, usage_date desc);

create index subscriptions_user_status_idx
  on public.subscriptions (user_id, status, current_period_end);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger divination_types_set_updated_at
  before update on public.divination_types
  for each row execute function public.set_updated_at();

create trigger divination_items_set_updated_at
  before update on public.divination_items
  for each row execute function public.set_updated_at();

create trigger interpretations_set_updated_at
  before update on public.interpretations
  for each row execute function public.set_updated_at();

create trigger subscriptions_set_updated_at
  before update on public.subscriptions
  for each row execute function public.set_updated_at();

create trigger daily_usage_set_updated_at
  before update on public.daily_usage
  for each row execute function public.set_updated_at();

create trigger prompt_templates_set_updated_at
  before update on public.prompt_templates
  for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.divination_types enable row level security;
alter table public.divination_items enable row level security;
alter table public.interpretations enable row level security;
alter table public.readings enable row level security;
alter table public.reading_items enable row level security;
alter table public.subscriptions enable row level security;
alter table public.daily_usage enable row level security;
alter table public.prompt_templates enable row level security;
alter table public.ai_results enable row level security;

create policy "Users can read their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Authenticated users can read active divination types"
  on public.divination_types for select
  to authenticated
  using (is_active = true);

create policy "Authenticated users can read active divination items"
  on public.divination_items for select
  to authenticated
  using (is_active = true);

create policy "Authenticated users can read active interpretations"
  on public.interpretations for select
  to authenticated
  using (is_active = true);

create policy "Users can read their own readings"
  on public.readings for select
  using (auth.uid() = user_id);

create policy "Users can create free readings"
  on public.readings for insert
  with check (
    auth.uid() = user_id
    and result_type = 'free'
    and is_ai_generated = false
  );

create policy "Users can read items from their readings"
  on public.reading_items for select
  using (
    exists (
      select 1
      from public.readings r
      where r.id = reading_items.reading_id
        and r.user_id = auth.uid()
    )
  );

create policy "Users can create items for their free readings"
  on public.reading_items for insert
  with check (
    exists (
      select 1
      from public.readings r
      where r.id = reading_items.reading_id
        and r.user_id = auth.uid()
        and r.result_type = 'free'
    )
  );

create policy "Users can read their own subscriptions"
  on public.subscriptions for select
  using (auth.uid() = user_id);

create policy "Users can read their own daily usage"
  on public.daily_usage for select
  using (auth.uid() = user_id);

create policy "Authenticated users can read active prompt templates"
  on public.prompt_templates for select
  to authenticated
  using (is_active = true);

create policy "Users can read AI results for their readings"
  on public.ai_results for select
  using (
    exists (
      select 1
      from public.readings r
      where r.id = ai_results.reading_id
        and r.user_id = auth.uid()
    )
  );

insert into public.divination_types
  (code, name, display_name, description, origin_region, sort_order)
values
  ('tarot', 'Tarot', '타로', '22장 또는 78장 카드 기반 점술', 'Western Europe', 10),
  ('rune', 'Rune', '룬', '북유럽 룬 상징 기반 점술', 'Northern Europe', 20),
  ('omikuji', 'Omikuji', '오미쿠지', '일본식 길흉 제비 점술', 'Japan', 30)
on conflict (code) do nothing;

insert into public.prompt_templates
  (code, name, system_prompt, user_prompt_template, language_code, version)
values
  (
    'plus_tarot_reading',
    'Plus Tarot Reading',
    'You are a careful divination guide. Provide reflective entertainment-only guidance. Never claim certainty or replace professional medical, legal, financial, or mental health advice.',
    'Language: {{language_code}}\nQuestion: {{question}}\nCategory: {{category}}\nSpread: {{spread_code}}\nSelected items: {{selected_items}}\nBase interpretations: {{base_interpretations}}\n\nReturn JSON with summary, detailed_reading, advice, and caution.',
    'ko',
    1
  )
on conflict (code, language_code, version) do nothing;
