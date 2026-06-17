-- Generalized interpretation table for both item-based and rule-based
-- divinations. Existing tarot data can be backfilled into this table while
-- saju and zodiac can use interpretation_key-based rows.

create table public.divination_interpretations (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  item_id uuid references public.divination_items(id) on delete cascade,
  interpretation_key text,
  category text not null default 'general',
  variant text not null default 'default',
  summary text not null,
  detail text,
  advice text,
  warning text,
  tags text[] not null default '{}',
  language_code text not null default 'ko',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint divination_interpretations_category_check
    check (category in ('general', 'love', 'career', 'money', 'health', 'relationship')),
  constraint divination_interpretations_item_or_key_check
    check (item_id is not null or interpretation_key is not null)
);

create unique index divination_interpretations_item_lookup_uidx
  on public.divination_interpretations (
    item_id,
    category,
    variant,
    language_code
  )
  where item_id is not null;

create unique index divination_interpretations_key_lookup_uidx
  on public.divination_interpretations (
    divination_type_id,
    interpretation_key,
    category,
    variant,
    language_code
  )
  where interpretation_key is not null;

create index divination_interpretations_type_lookup_idx
  on public.divination_interpretations (
    divination_type_id,
    category,
    variant,
    language_code
  )
  where is_active = true;

create trigger divination_interpretations_set_updated_at
  before update on public.divination_interpretations
  for each row execute function public.set_updated_at();

alter table public.divination_interpretations enable row level security;

create policy "Authenticated users can read active divination interpretations"
  on public.divination_interpretations for select
  to authenticated
  using (is_active = true);

insert into public.divination_interpretations (
  divination_type_id,
  item_id,
  interpretation_key,
  category,
  variant,
  summary,
  detail,
  advice,
  warning,
  tags,
  language_code,
  is_active
)
select
  items.divination_type_id,
  legacy.item_id,
  null,
  legacy.category,
  legacy.orientation,
  legacy.summary,
  legacy.detail,
  legacy.advice,
  legacy.warning,
  legacy.keywords,
  legacy.language_code,
  legacy.is_active
from public.interpretations legacy
join public.divination_items items on items.id = legacy.item_id
where not exists (
  select 1
  from public.divination_interpretations existing
  where existing.item_id = legacy.item_id
    and existing.category = legacy.category
    and existing.variant = legacy.orientation
    and existing.language_code = legacy.language_code
);
