-- Major Arcana tarot seed for spread verification.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
      ('fool', 'The Fool', '바보', '새로운 시작과 가능성', array['시작', '자유', '가능성'], 0),
      ('magician', 'The Magician', '마법사', '의지와 실행력', array['실행', '능력', '창조'], 1),
      ('high_priestess', 'The High Priestess', '여사제', '직관과 숨은 지혜', array['직관', '비밀', '내면'], 2),
      ('empress', 'The Empress', '여제', '풍요와 돌봄', array['풍요', '성장', '돌봄'], 3),
      ('emperor', 'The Emperor', '황제', '질서와 책임', array['질서', '권위', '책임'], 4),
      ('hierophant', 'The Hierophant', '교황', '전통과 배움', array['전통', '조언', '배움'], 5),
      ('lovers', 'The Lovers', '연인', '선택과 결합', array['선택', '관계', '조화'], 6),
      ('chariot', 'The Chariot', '전차', '의지와 전진', array['전진', '통제', '승리'], 7),
      ('strength', 'Strength', '힘', '부드러운 용기와 인내', array['용기', '인내', '절제'], 8),
      ('hermit', 'The Hermit', '은둔자', '성찰과 탐구', array['성찰', '탐구', '고독'], 9),
      ('wheel_of_fortune', 'Wheel of Fortune', '운명의 수레바퀴', '전환과 흐름', array['전환', '흐름', '기회'], 10),
      ('justice', 'Justice', '정의', '균형과 판단', array['균형', '판단', '공정'], 11),
      ('hanged_man', 'The Hanged Man', '매달린 사람', '관점 전환과 멈춤', array['멈춤', '전환', '수용'], 12),
      ('death', 'Death', '죽음', '끝맺음과 변화', array['종료', '변화', '재생'], 13),
      ('temperance', 'Temperance', '절제', '조율과 균형', array['조율', '균형', '회복'], 14),
      ('devil', 'The Devil', '악마', '집착과 유혹', array['집착', '유혹', '속박'], 15),
      ('tower', 'The Tower', '탑', '갑작스러운 변화와 해체', array['충격', '해체', '각성'], 16),
      ('star', 'The Star', '별', '희망과 회복', array['희망', '회복', '영감'], 17),
      ('moon', 'The Moon', '달', '불확실성과 무의식', array['불안', '무의식', '환상'], 18),
      ('sun', 'The Sun', '태양', '명료함과 활력', array['성공', '활력', '명료함'], 19),
      ('judgement', 'Judgement', '심판', '부름과 재평가', array['각성', '평가', '결단'], 20),
      ('world', 'The World', '세계', '완성과 통합', array['완성', '통합', '성취'], 21)
  ) as card(code, name, display_name, theme, keywords, order_no)
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
  seed_cards.theme || '을 상징하는 메이저 아르카나 카드',
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
      ('fool', '바보', '새로운 시작과 가능성'),
      ('magician', '마법사', '의지와 실행력'),
      ('high_priestess', '여사제', '직관과 숨은 지혜'),
      ('empress', '여제', '풍요와 돌봄'),
      ('emperor', '황제', '질서와 책임'),
      ('hierophant', '교황', '전통과 배움'),
      ('lovers', '연인', '선택과 결합'),
      ('chariot', '전차', '의지와 전진'),
      ('strength', '힘', '부드러운 용기와 인내'),
      ('hermit', '은둔자', '성찰과 탐구'),
      ('wheel_of_fortune', '운명의 수레바퀴', '전환과 흐름'),
      ('justice', '정의', '균형과 판단'),
      ('hanged_man', '매달린 사람', '관점 전환과 멈춤'),
      ('death', '죽음', '끝맺음과 변화'),
      ('temperance', '절제', '조율과 균형'),
      ('devil', '악마', '집착과 유혹'),
      ('tower', '탑', '갑작스러운 변화와 해체'),
      ('star', '별', '희망과 회복'),
      ('moon', '달', '불확실성과 무의식'),
      ('sun', '태양', '명료함과 활력'),
      ('judgement', '심판', '부름과 재평가'),
      ('world', '세계', '완성과 통합')
  ) as card(code, display_name, theme)
),
orientations as (
  select *
  from (
    values
      ('upright', '정방향', '이 카드의 에너지가 비교적 자연스럽게 드러납니다.', '지금 보이는 가능성을 현실적인 행동으로 옮겨 보세요.', '확신이 지나쳐 주변 신호를 놓치지 않도록 주의하세요.'),
      ('reversed', '역방향', '이 카드의 에너지가 지연되거나 내면에서 흔들릴 수 있습니다.', '잠시 멈추고 같은 주제를 다른 각도에서 살펴보세요.', '불안이나 조급함 때문에 성급히 결론 내리지 마세요.')
  ) as orientation(code, label, flow, advice, warning)
),
categories as (
  select *
  from (
    values
      ('general', '일반', '상황 전체의 흐름을 넓게 바라볼 필요가 있습니다.'),
      ('love', '연애', '감정의 속도와 서로의 기대를 함께 살피는 것이 좋습니다.'),
      ('career', '직업', '기회와 책임, 준비 상태를 현실적으로 점검해야 합니다.'),
      ('money', '금전', '수익보다 리스크와 지출 흐름을 먼저 확인하세요.'),
      ('health', '건강', '결과는 참고용이며 생활 리듬과 휴식을 우선하세요.'),
      ('relationship', '관계', '말보다 신뢰, 경계, 거리감을 함께 살피세요.')
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
  seed_cards.theme || '. ' || orientations.flow || ' ' || categories.detail,
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
