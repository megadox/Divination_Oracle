-- Expand divination metadata so the app can render a multi-divination catalog.
-- This keeps the current tarot flow working while adding enough metadata for
-- input-based systems like saju and zodiac.

alter table public.divination_types
  add column short_description text,
  add column icon_key text,
  add column banner_image_url text,
  add column input_mode text not null default 'draw_based',
  add column resolver_type text not null default 'random_draw',
  add column interpretation_mode text not null default 'prewritten_lookup';

alter table public.divination_types
  add constraint divination_types_input_mode_check
    check (input_mode in ('draw_based', 'birth_data_based', 'hybrid')),
  add constraint divination_types_resolver_type_check
    check (resolver_type in ('random_draw', 'saju_chart', 'zodiac_sign', 'rule_engine')),
  add constraint divination_types_interpretation_mode_check
    check (
      interpretation_mode in (
        'prewritten_lookup',
        'rule_based',
        'lookup_plus_ai',
        'rule_plus_ai'
      )
    );

update public.divination_types
set
  short_description = case code
    when 'tarot' then '카드로 현재 흐름과 조언을 살펴봅니다.'
    when 'rune' then '룬 상징으로 현재 에너지와 방향을 읽습니다.'
    when 'omikuji' then '제비를 뽑아 오늘의 길흉과 메시지를 확인합니다.'
    else short_description
  end,
  icon_key = case code
    when 'tarot' then 'cards'
    when 'rune' then 'rune_stone'
    when 'omikuji' then 'fortune_slip'
    else icon_key
  end,
  input_mode = case code
    when 'tarot' then 'draw_based'
    when 'rune' then 'draw_based'
    when 'omikuji' then 'draw_based'
    else input_mode
  end,
  resolver_type = case code
    when 'tarot' then 'random_draw'
    when 'rune' then 'random_draw'
    when 'omikuji' then 'random_draw'
    else resolver_type
  end,
  interpretation_mode = case code
    when 'tarot' then 'lookup_plus_ai'
    when 'rune' then 'lookup_plus_ai'
    when 'omikuji' then 'lookup_plus_ai'
    else interpretation_mode
  end,
  updated_at = now()
where code in ('tarot', 'rune', 'omikuji');

insert into public.divination_types (
  code,
  name,
  display_name,
  description,
  short_description,
  origin_region,
  icon_key,
  input_mode,
  resolver_type,
  interpretation_mode,
  is_plus_only,
  is_active,
  sort_order
)
values
  (
    'saju',
    'Saju',
    '사주',
    '생년월일시를 바탕으로 기질과 인생 흐름을 해석하는 동아시아 명리 기반 점술',
    '생년월일시를 기반으로 기질과 흐름을 봅니다.',
    'Korea / East Asia',
    'saju_chart',
    'birth_data_based',
    'saju_chart',
    'rule_plus_ai',
    false,
    true,
    40
  ),
  (
    'zodiac',
    'Zodiac',
    '별자리',
    '생년월일을 기반으로 태양궁 성향과 흐름을 해석하는 점성술 입문형 점술',
    '생년월일을 기반으로 별자리 성향과 흐름을 봅니다.',
    'Global',
    'zodiac',
    'birth_data_based',
    'zodiac_sign',
    'rule_plus_ai',
    false,
    true,
    50
  )
on conflict (code) do update
set
  name = excluded.name,
  display_name = excluded.display_name,
  description = excluded.description,
  short_description = excluded.short_description,
  origin_region = excluded.origin_region,
  icon_key = excluded.icon_key,
  input_mode = excluded.input_mode,
  resolver_type = excluded.resolver_type,
  interpretation_mode = excluded.interpretation_mode,
  is_plus_only = excluded.is_plus_only,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

