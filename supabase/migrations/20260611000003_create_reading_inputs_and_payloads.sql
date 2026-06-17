-- Store user-supplied inputs and computed payloads so input-based divinations
-- can reuse the existing readings table without overloading reading_items.

create table public.reading_inputs (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null references public.readings(id) on delete cascade,
  field_key text not null,
  field_value text,
  field_value_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.reading_payloads (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null references public.readings(id) on delete cascade,
  payload_type text not null,
  payload_json jsonb not null,
  created_at timestamptz not null default now(),
  unique (reading_id, payload_type)
);

create index reading_inputs_reading_idx
  on public.reading_inputs (reading_id, field_key);

create index reading_payloads_reading_idx
  on public.reading_payloads (reading_id, payload_type);

alter table public.reading_inputs enable row level security;
alter table public.reading_payloads enable row level security;

create policy "Users can read their own reading inputs"
  on public.reading_inputs for select
  using (
    exists (
      select 1
      from public.readings r
      where r.id = reading_inputs.reading_id
        and r.user_id = auth.uid()
    )
  );

create policy "Users can create inputs for their free readings"
  on public.reading_inputs for insert
  with check (
    exists (
      select 1
      from public.readings r
      where r.id = reading_inputs.reading_id
        and r.user_id = auth.uid()
        and r.result_type = 'free'
    )
  );

create policy "Users can read their own reading payloads"
  on public.reading_payloads for select
  using (
    exists (
      select 1
      from public.readings r
      where r.id = reading_payloads.reading_id
        and r.user_id = auth.uid()
    )
  );

