-- Define point-in-time input schemas per divination type so the app can
-- render different forms for tarot, saju, rune, omikuji, and zodiac.

create table public.divination_input_definitions (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  field_key text not null,
  field_label text not null,
  field_type text not null,
  is_required boolean not null default true,
  options_json jsonb not null default '[]'::jsonb,
  placeholder text,
  help_text text,
  validation_json jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (divination_type_id, field_key),
  constraint divination_input_definitions_field_type_check
    check (
      field_type in (
        'text',
        'textarea',
        'date',
        'time',
        'datetime',
        'select',
        'boolean',
        'number'
      )
    )
);

create index divination_input_definitions_type_order_idx
  on public.divination_input_definitions (divination_type_id, sort_order)
  where is_active = true;

create trigger divination_input_definitions_set_updated_at
  before update on public.divination_input_definitions
  for each row execute function public.set_updated_at();

alter table public.divination_input_definitions enable row level security;

create policy "Authenticated users can read active divination input definitions"
  on public.divination_input_definitions for select
  to authenticated
  using (is_active = true);

with type_ids as (
  select id, code
  from public.divination_types
  where code in ('tarot', 'saju', 'zodiac')
),
seed_inputs as (
  select *
  from (
    values
      ('tarot', 'spread_code', '스프레드', 'select', true, '[{"label":"오늘의 카드","value":"daily_one_card"},{"label":"질문 1장","value":"single_question"},{"label":"과거-현재-미래","value":"three_card_timeline"},{"label":"상황-장애물-조언","value":"situation_advice"},{"label":"선택 A/B 비교","value":"choice_ab"},{"label":"관계 리딩","value":"relationship"},{"label":"켈틱 크로스","value":"celtic_cross"}]', null, '질문에 맞는 타로 전개 방식을 선택합니다.', '{"default":"single_question"}', 10),
      ('saju', 'birth_date', '생년월일', 'date', true, '[]', null, '양력 또는 음력 생년월일을 입력합니다.', '{"min":"1900-01-01"}', 10),
      ('saju', 'birth_time', '출생시간', 'time', false, '[]', null, '출생시간을 모르면 비워둘 수 있습니다.', '{}', 20),
      ('saju', 'calendar_type', '달력 종류', 'select', true, '[{"label":"양력","value":"solar"},{"label":"음력","value":"lunar"}]', null, '사주 계산에 사용할 달력 기준입니다.', '{"default":"solar"}', 30),
      ('saju', 'gender', '성별', 'select', true, '[{"label":"여성","value":"female"},{"label":"남성","value":"male"}]', null, '전통 사주 해석 흐름에 사용하는 기본 정보입니다.', '{}', 40),
      ('zodiac', 'birth_date', '생년월일', 'date', true, '[]', null, '태양궁 계산에 사용합니다.', '{"min":"1900-01-01"}', 10)
  ) as t(
    divination_code,
    field_key,
    field_label,
    field_type,
    is_required,
    options_json,
    placeholder,
    help_text,
    validation_json,
    sort_order
  )
)
insert into public.divination_input_definitions (
  divination_type_id,
  field_key,
  field_label,
  field_type,
  is_required,
  options_json,
  placeholder,
  help_text,
  validation_json,
  sort_order,
  is_active
)
select
  type_ids.id,
  seed_inputs.field_key,
  seed_inputs.field_label,
  seed_inputs.field_type,
  seed_inputs.is_required,
  seed_inputs.options_json::jsonb,
  seed_inputs.placeholder,
  seed_inputs.help_text,
  seed_inputs.validation_json::jsonb,
  seed_inputs.sort_order,
  true
from seed_inputs
join type_ids on type_ids.code = seed_inputs.divination_code
on conflict (divination_type_id, field_key) do update
set
  field_label = excluded.field_label,
  field_type = excluded.field_type,
  is_required = excluded.is_required,
  options_json = excluded.options_json,
  placeholder = excluded.placeholder,
  help_text = excluded.help_text,
  validation_json = excluded.validation_json,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  updated_at = now();

