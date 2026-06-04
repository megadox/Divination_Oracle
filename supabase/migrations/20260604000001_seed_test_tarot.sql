-- Test tarot seed data for MVP verification.
-- This seed keeps the content intentionally small: three Major Arcana cards,
-- both tarot orientations, and all app categories used by the Flutter UI.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
      (
        'fool',
        'The Fool',
        '바보',
        '새로운 시작, 자유, 가능성을 상징하는 카드',
        array['시작', '자유', '모험'],
        0,
        '시작'
      ),
      (
        'magician',
        'The Magician',
        '마법사',
        '의지, 실행력, 자원 활용을 상징하는 카드',
        array['실행', '능력', '창조'],
        1,
        '실행'
      ),
      (
        'star',
        'The Star',
        '별',
        '희망, 회복, 장기적인 가능성을 상징하는 카드',
        array['희망', '회복', '영감'],
        17,
        '희망'
      )
  ) as card(code, name, display_name, description, keywords, order_no, theme)
)
insert into public.divination_items (
  divination_type_id,
  code,
  name,
  display_name,
  description,
  keywords,
  metadata,
  order_no,
  is_active
)
select
  tarot_type.id,
  seed_cards.code,
  seed_cards.name,
  seed_cards.display_name,
  seed_cards.description,
  seed_cards.keywords,
  jsonb_build_object(
    'arcana', 'major',
    'test_seed', true,
    'theme', seed_cards.theme
  ),
  seed_cards.order_no,
  true
from tarot_type
cross join seed_cards
on conflict (divination_type_id, code) do update
set
  name = excluded.name,
  display_name = excluded.display_name,
  description = excluded.description,
  keywords = excluded.keywords,
  metadata = excluded.metadata,
  order_no = excluded.order_no,
  is_active = excluded.is_active,
  updated_at = now();

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
      ('fool', '바보', '새로운 시작', '가볍게 첫발을 내딛는 흐름'),
      ('magician', '마법사', '실행력', '가진 자원을 현실로 바꾸는 흐름'),
      ('star', '별', '희망', '회복과 장기적 가능성을 바라보는 흐름')
  ) as card(code, display_name, theme, upright_detail)
),
orientations as (
  select *
  from (
    values
      ('upright', '정방향', '흐름이 비교적 자연스럽게 열려 있습니다.', '작게라도 행동을 시작해 보세요.', '가능성만 믿고 준비를 생략하지는 마세요.'),
      ('reversed', '역방향', '흐름이 지연되거나 마음이 흔들릴 수 있습니다.', '속도를 늦추고 기준을 다시 확인하세요.', '불안 때문에 충동적으로 결정하지 않도록 주의하세요.')
  ) as orientation(code, label, flow, advice, warning)
),
categories as (
  select *
  from (
    values
      ('general', '일반', '현재 상황을 넓게 바라볼 필요가 있습니다.'),
      ('love', '연애', '감정의 속도와 상대와의 균형을 함께 살피는 것이 좋습니다.'),
      ('career', '직업', '기회와 준비 상태를 현실적으로 점검해야 합니다.'),
      ('money', '금전', '기대 수익보다 지출과 리스크 관리가 먼저입니다.'),
      ('health', '건강', '무리한 해석보다 생활 리듬과 휴식을 우선하세요.'),
      ('relationship', '관계', '말의 방향보다 관계 안의 신뢰와 거리감을 살피세요.')
  ) as category(code, label, detail)
),
card_items as (
  select item.id, item.code
  from public.divination_items item
  join tarot_type on tarot_type.id = item.divination_type_id
)
insert into public.interpretations (
  item_id,
  orientation,
  category,
  summary,
  detail,
  advice,
  warning,
  keywords,
  language_code,
  is_active
)
select
  card_items.id,
  orientations.code,
  categories.code,
  seed_cards.display_name || ' 카드는 ' || categories.label || ' 영역에서 ' ||
    seed_cards.theme || '의 메시지를 보여줍니다.',
  seed_cards.upright_detail || '. ' || orientations.flow || ' ' || categories.detail,
  orientations.advice,
  orientations.warning,
  array[seed_cards.theme, categories.label, orientations.label],
  'ko',
  true
from card_items
join seed_cards on seed_cards.code = card_items.code
cross join orientations
cross join categories
on conflict (item_id, orientation, category, language_code) do update
set
  summary = excluded.summary,
  detail = excluded.detail,
  advice = excluded.advice,
  warning = excluded.warning,
  keywords = excluded.keywords,
  is_active = excluded.is_active,
  updated_at = now();
