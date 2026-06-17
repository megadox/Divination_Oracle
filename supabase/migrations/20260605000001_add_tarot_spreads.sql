-- Tarot spread definitions and positions.
-- All spreads are available in the UI for now. OpenAI-backed interpretation
-- still remains gated in Edge Functions.

create table public.spreads (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  card_count integer not null,
  is_plus_only boolean not null default false,
  allow_reversed boolean not null default true,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (divination_type_id, code),
  constraint spreads_card_count_check check (card_count > 0)
);

create table public.spread_positions (
  id uuid primary key default gen_random_uuid(),
  spread_id uuid not null references public.spreads(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  position_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (spread_id, code),
  unique (spread_id, position_order)
);

alter table public.readings
  add column spread_id uuid references public.spreads(id);

alter table public.reading_items
  add column spread_position_id uuid references public.spread_positions(id);

create index spreads_type_order_idx
  on public.spreads (divination_type_id, sort_order)
  where is_active = true;

create index spread_positions_spread_order_idx
  on public.spread_positions (spread_id, position_order)
  where is_active = true;

create trigger spreads_set_updated_at
  before update on public.spreads
  for each row execute function public.set_updated_at();

create trigger spread_positions_set_updated_at
  before update on public.spread_positions
  for each row execute function public.set_updated_at();

alter table public.spreads enable row level security;
alter table public.spread_positions enable row level security;

create policy "Authenticated users can read active spreads"
  on public.spreads for select
  to authenticated
  using (is_active = true);

create policy "Authenticated users can read active spread positions"
  on public.spread_positions for select
  to authenticated
  using (is_active = true);

with tarot_type as (
  select id from public.divination_types where code = 'tarot'
),
seed_spreads as (
  select *
  from (
    values
      ('daily_one_card', '오늘의 카드', '오늘 하루를 위한 핵심 메시지를 한 장으로 확인합니다.', 1, false, true, 10),
      ('single_question', '질문 1장', '구체적인 질문에 대한 핵심 답변을 한 장으로 확인합니다.', 1, false, true, 20),
      ('three_card_timeline', '과거-현재-미래', '상황의 흐름을 과거, 현재, 미래 세 장으로 살펴봅니다.', 3, false, true, 30),
      ('situation_advice', '상황-장애물-조언', '현재 상황, 넘어야 할 지점, 실천 조언을 세 장으로 확인합니다.', 3, false, true, 40),
      ('choice_ab', '선택 A/B 비교', '두 선택지의 흐름과 결과를 비교합니다.', 5, false, true, 50),
      ('relationship', '관계 리딩', '나, 상대, 관계의 흐름과 조언을 살펴봅니다.', 5, false, true, 60),
      ('celtic_cross', '켈틱 크로스', '상황을 깊고 종합적으로 분석하는 10장 스프레드입니다.', 10, false, true, 70)
  ) as spread(code, name, description, card_count, is_plus_only, allow_reversed, sort_order)
)
insert into public.spreads (
  divination_type_id,
  code,
  name,
  description,
  card_count,
  is_plus_only,
  allow_reversed,
  sort_order,
  is_active
)
select
  tarot_type.id,
  seed_spreads.code,
  seed_spreads.name,
  seed_spreads.description,
  seed_spreads.card_count,
  seed_spreads.is_plus_only,
  seed_spreads.allow_reversed,
  seed_spreads.sort_order,
  true
from tarot_type
cross join seed_spreads
on conflict (divination_type_id, code) do update
set
  name = excluded.name,
  description = excluded.description,
  card_count = excluded.card_count,
  is_plus_only = excluded.is_plus_only,
  allow_reversed = excluded.allow_reversed,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  updated_at = now();

with tarot_type as (
  select id from public.divination_types where code = 'tarot'
),
tarot_spreads as (
  select spreads.id, spreads.code
  from public.spreads
  join tarot_type on tarot_type.id = spreads.divination_type_id
),
seed_positions as (
  select *
  from (
    values
      ('daily_one_card', 'message', '오늘의 메시지', '오늘 하루에 가장 중요한 흐름과 조언입니다.', 0),
      ('single_question', 'answer', '핵심 답변', '질문에 대한 핵심 메시지입니다.', 0),
      ('three_card_timeline', 'past', '과거', '현재 상황에 영향을 준 과거의 흐름입니다.', 0),
      ('three_card_timeline', 'present', '현재', '지금 가장 강하게 드러나는 상황입니다.', 1),
      ('three_card_timeline', 'future', '미래', '현재 흐름이 이어질 때 나타날 가능성입니다.', 2),
      ('situation_advice', 'situation', '상황', '현재 상황의 핵심 모습입니다.', 0),
      ('situation_advice', 'challenge', '장애물', '주의하거나 넘어야 할 지점입니다.', 1),
      ('situation_advice', 'advice', '조언', '지금 실천하면 좋은 방향입니다.', 2),
      ('choice_ab', 'current', '현재', '선택 앞에 선 현재 상태입니다.', 0),
      ('choice_ab', 'option_a', '선택 A', '선택 A가 가진 성격과 흐름입니다.', 1),
      ('choice_ab', 'option_a_outcome', 'A 결과', '선택 A가 만들 수 있는 가능성입니다.', 2),
      ('choice_ab', 'option_b', '선택 B', '선택 B가 가진 성격과 흐름입니다.', 3),
      ('choice_ab', 'option_b_outcome', 'B 결과', '선택 B가 만들 수 있는 가능성입니다.', 4),
      ('relationship', 'me', '나', '관계 안에서 나의 상태입니다.', 0),
      ('relationship', 'other', '상대', '관계 안에서 상대의 상태입니다.', 1),
      ('relationship', 'connection', '연결', '두 사람 사이의 연결 흐름입니다.', 2),
      ('relationship', 'challenge', '장애물', '관계에서 주의해야 할 지점입니다.', 3),
      ('relationship', 'advice', '조언', '관계를 위해 실천할 수 있는 방향입니다.', 4),
      ('celtic_cross', 'present', '현재', '현재 상황의 중심입니다.', 0),
      ('celtic_cross', 'challenge', '도전', '현재 상황을 가로막거나 시험하는 요소입니다.', 1),
      ('celtic_cross', 'past', '과거', '상황의 뿌리가 되는 과거 흐름입니다.', 2),
      ('celtic_cross', 'future', '가까운 미래', '가까운 시기에 나타날 가능성입니다.', 3),
      ('celtic_cross', 'above', '의식', '분명히 인식하고 있는 목표와 생각입니다.', 4),
      ('celtic_cross', 'below', '무의식', '깊은 감정과 숨은 동기입니다.', 5),
      ('celtic_cross', 'advice', '조언', '상황을 다루는 실천 방향입니다.', 6),
      ('celtic_cross', 'external', '외부 영향', '주변 사람이나 환경의 영향입니다.', 7),
      ('celtic_cross', 'hopes_fears', '기대와 두려움', '바라는 것과 걱정하는 것이 함께 드러납니다.', 8),
      ('celtic_cross', 'outcome', '결과', '현재 흐름이 이어질 때의 종합 가능성입니다.', 9)
  ) as position(spread_code, code, name, description, position_order)
)
insert into public.spread_positions (
  spread_id,
  code,
  name,
  description,
  position_order,
  is_active
)
select
  tarot_spreads.id,
  seed_positions.code,
  seed_positions.name,
  seed_positions.description,
  seed_positions.position_order,
  true
from seed_positions
join tarot_spreads on tarot_spreads.code = seed_positions.spread_code
on conflict (spread_id, code) do update
set
  name = excluded.name,
  description = excluded.description,
  position_order = excluded.position_order,
  is_active = excluded.is_active,
  updated_at = now();
