-- Minor Arcana tarot seed (56 cards). Full deck: 22 major + 56 minor = 78 cards.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
      ('wands_ace', 'Ace of Wands', '지팡이 에이스', '새로운 시작과 영감', array['시작', '영감', '열정'], 22, 'wands', 'ace'),
      ('wands_two', 'Two of Wands', '지팡이 2', '계획과 미래 설계', array['계획', '미래', '설계'], 23, 'wands', 'two'),
      ('wands_three', 'Three of Wands', '지팡이 3', '확장과 기회', array['확장', '기회', '성장'], 24, 'wands', 'three'),
      ('wands_four', 'Four of Wands', '지팡이 4', '안정과 축하', array['안정', '축하', '기반'], 25, 'wands', 'four'),
      ('wands_five', 'Five of Wands', '지팡이 5', '경쟁과 긴장', array['경쟁', '긴장', '도전'], 26, 'wands', 'five'),
      ('wands_six', 'Six of Wands', '지팡이 6', '승리와 인정', array['승리', '인정', '자신감'], 27, 'wands', 'six'),
      ('wands_seven', 'Seven of Wands', '지팡이 7', '방어와 인내', array['방어', '인내', '끈기'], 28, 'wands', 'seven'),
      ('wands_eight', 'Eight of Wands', '지팡이 8', '빠른 전개와 움직임', array['속도', '전개', '움직임'], 29, 'wands', 'eight'),
      ('wands_nine', 'Nine of Wands', '지팡이 9', '끈기와 경계', array['경계', '끈기', '준비'], 30, 'wands', 'nine'),
      ('wands_ten', 'Ten of Wands', '지팡이 10', '부담과 책임', array['부담', '책임', '압박'], 31, 'wands', 'ten'),
      ('wands_page', 'Page of Wands', '지팡이 시종', '호기심과 탐색', array['호기심', '탐색', '메시지'], 32, 'wands', 'page'),
      ('wands_knight', 'Knight of Wands', '지팡이 기사', '열정과 돌진', array['열정', '돌진', '행동'], 33, 'wands', 'knight'),
      ('wands_queen', 'Queen of Wands', '지팡이 여왕', '따뜻한 카리스마', array['카리스마', '따뜻함', '매력'], 34, 'wands', 'queen'),
      ('wands_king', 'King of Wands', '지팡이 왕', '비전과 리더십', array['리더십', '비전', '통솔'], 35, 'wands', 'king'),
      ('cups_ace', 'Ace of Cups', '컵 에이스', '감정의 시작과 사랑', array['사랑', '감정', '시작'], 36, 'cups', 'ace'),
      ('cups_two', 'Two of Cups', '컵 2', '연결과 파트너십', array['연결', '파트너십', '조화'], 37, 'cups', 'two'),
      ('cups_three', 'Three of Cups', '컵 3', '기쁨과 교류', array['기쁨', '교류', '친교'], 38, 'cups', 'three'),
      ('cups_four', 'Four of Cups', '컵 4', '정서적 공허', array['공허', '정서', '멈춤'], 39, 'cups', 'four'),
      ('cups_five', 'Five of Cups', '컵 5', '상실과 아픔', array['상실', '아픔', '후회'], 40, 'cups', 'five'),
      ('cups_six', 'Six of Cups', '컵 6', '추억과 순수함', array['추억', '순수', '그리움'], 41, 'cups', 'six'),
      ('cups_seven', 'Seven of Cups', '컵 7', '선택과 환상', array['선택', '환상', '가능성'], 42, 'cups', 'seven'),
      ('cups_eight', 'Eight of Cups', '컵 8', '떠남과 새로운 가능성', array['떠남', '전환', '새출발'], 43, 'cups', 'eight'),
      ('cups_nine', 'Nine of Cups', '컵 9', '만족과 소망 성취', array['만족', '소망', '성취'], 44, 'cups', 'nine'),
      ('cups_ten', 'Ten of Cups', '컵 10', '가족과 감정적 완성', array['가족', '완성', '행복'], 45, 'cups', 'ten'),
      ('cups_page', 'Page of Cups', '컵 시종', '직관과 감수성', array['직관', '감수성', '메시지'], 46, 'cups', 'page'),
      ('cups_knight', 'Knight of Cups', '컵 기사', '로맨스와 이상', array['로맨스', '이상', '제안'], 47, 'cups', 'knight'),
      ('cups_queen', 'Queen of Cups', '컵 여왕', '공감과 돌봄', array['공감', '돌봄', '치유'], 48, 'cups', 'queen'),
      ('cups_king', 'King of Cups', '컵 왕', '감정적 균형과 성숙', array['균형', '성숙', '지혜'], 49, 'cups', 'king'),
      ('swords_ace', 'Ace of Swords', '검 에이스', '명확한 통찰과 진실', array['통찰', '진실', '명료'], 50, 'swords', 'ace'),
      ('swords_two', 'Two of Swords', '검 2', '딜레마와 균형', array['딜레마', '균형', '선택'], 51, 'swords', 'two'),
      ('swords_three', 'Three of Swords', '검 3', '슬픔과 분리', array['슬픔', '분리', '상처'], 52, 'swords', 'three'),
      ('swords_four', 'Four of Swords', '검 4', '휴식과 회복', array['휴식', '회복', '재충전'], 53, 'swords', 'four'),
      ('swords_five', 'Five of Swords', '검 5', '갈등과 패배감', array['갈등', '패배', '긴장'], 54, 'swords', 'five'),
      ('swords_six', 'Six of Swords', '검 6', '전환과 이동', array['전환', '이동', '변화'], 55, 'swords', 'six'),
      ('swords_seven', 'Seven of Swords', '검 7', '전략과 교묘함', array['전략', '교묘', '계획'], 56, 'swords', 'seven'),
      ('swords_eight', 'Eight of Swords', '검 8', '제약과 불안', array['제약', '불안', '속박'], 57, 'swords', 'eight'),
      ('swords_nine', 'Nine of Swords', '검 9', '걱정과 악몽', array['걱정', '압박', '두려움'], 58, 'swords', 'nine'),
      ('swords_ten', 'Ten of Swords', '검 10', '종료와 새로운 시작', array['종료', '새시작', '해방'], 59, 'swords', 'ten'),
      ('swords_page', 'Page of Swords', '검 시종', '호기심과 아이디어', array['아이디어', '호기심', '학습'], 60, 'swords', 'page'),
      ('swords_knight', 'Knight of Swords', '검 기사', '결단과 직설', array['결단', '직설', '행동'], 61, 'swords', 'knight'),
      ('swords_queen', 'Queen of Swords', '검 여왕', '명료함과 독립', array['독립', '명료', '경계'], 62, 'swords', 'queen'),
      ('swords_king', 'King of Swords', '검 왕', '이성과 공정한 판단', array['이성', '공정', '판단'], 63, 'swords', 'king'),
      ('pentacles_ace', 'Ace of Pentacles', '펜타클 에이스', '새로운 기회와 번영', array['기회', '번영', '시작'], 64, 'pentacles', 'ace'),
      ('pentacles_two', 'Two of Pentacles', '펜타클 2', '균형과 다재다능', array['균형', '다재다능', '조율'], 65, 'pentacles', 'two'),
      ('pentacles_three', 'Three of Pentacles', '펜타클 3', '숙련과 협업', array['숙련', '협업', '성장'], 66, 'pentacles', 'three'),
      ('pentacles_four', 'Four of Pentacles', '펜타클 4', '안정과 보수', array['안정', '보수', '저축'], 67, 'pentacles', 'four'),
      ('pentacles_five', 'Five of Pentacles', '펜타클 5', '어려움과 불안정', array['어려움', '불안정', '시련'], 68, 'pentacles', 'five'),
      ('pentacles_six', 'Six of Pentacles', '펜타클 6', '나눔과 지원', array['나눔', '지원', '베풂'], 69, 'pentacles', 'six'),
      ('pentacles_seven', 'Seven of Pentacles', '펜타클 7', '인내와 장기 투자', array['인내', '투자', '기다림'], 70, 'pentacles', 'seven'),
      ('pentacles_eight', 'Eight of Pentacles', '펜타클 8', '기술과 성실', array['기술', '성실', '노력'], 71, 'pentacles', 'eight'),
      ('pentacles_nine', 'Nine of Pentacles', '펜타클 9', '성취와 자급자족', array['성취', '자급자족', '풍요'], 72, 'pentacles', 'nine'),
      ('pentacles_ten', 'Ten of Pentacles', '펜타클 10', '부와 유산', array['부', '유산', '완성'], 73, 'pentacles', 'ten'),
      ('pentacles_page', 'Page of Pentacles', '펜타클 시종', '학습과 실용성', array['학습', '실용', '탐구'], 74, 'pentacles', 'page'),
      ('pentacles_knight', 'Knight of Pentacles', '펜타클 기사', '근면과 신중한 전진', array['근면', '신중', '전진'], 75, 'pentacles', 'knight'),
      ('pentacles_queen', 'Queen of Pentacles', '펜타클 여왕', '실용과 풍요', array['실용', '풍요', '돌봄'], 76, 'pentacles', 'queen'),
      ('pentacles_king', 'King of Pentacles', '펜타클 왕', '성공과 안정된 경영', array['성공', '경영', '안정'], 77, 'pentacles', 'king')
  ) as card(code, name, display_name, theme, keywords, order_no, suit, rank)
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
  seed_cards.theme || '을 상징하는 마이너 아르카나 카드',
  seed_cards.keywords,
  jsonb_build_object(
    'arcana', 'minor',
    'suit', seed_cards.suit,
    'rank', seed_cards.rank,
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
      ('wands_ace', '지팡이 에이스', '새로운 시작과 영감'),
      ('wands_two', '지팡이 2', '계획과 미래 설계'),
      ('wands_three', '지팡이 3', '확장과 기회'),
      ('wands_four', '지팡이 4', '안정과 축하'),
      ('wands_five', '지팡이 5', '경쟁과 긴장'),
      ('wands_six', '지팡이 6', '승리와 인정'),
      ('wands_seven', '지팡이 7', '방어와 인내'),
      ('wands_eight', '지팡이 8', '빠른 전개와 움직임'),
      ('wands_nine', '지팡이 9', '끈기와 경계'),
      ('wands_ten', '지팡이 10', '부담과 책임'),
      ('wands_page', '지팡이 시종', '호기심과 탐색'),
      ('wands_knight', '지팡이 기사', '열정과 돌진'),
      ('wands_queen', '지팡이 여왕', '따뜻한 카리스마'),
      ('wands_king', '지팡이 왕', '비전과 리더십'),
      ('cups_ace', '컵 에이스', '감정의 시작과 사랑'),
      ('cups_two', '컵 2', '연결과 파트너십'),
      ('cups_three', '컵 3', '기쁨과 교류'),
      ('cups_four', '컵 4', '정서적 공허'),
      ('cups_five', '컵 5', '상실과 아픔'),
      ('cups_six', '컵 6', '추억과 순수함'),
      ('cups_seven', '컵 7', '선택과 환상'),
      ('cups_eight', '컵 8', '떠남과 새로운 가능성'),
      ('cups_nine', '컵 9', '만족과 소망 성취'),
      ('cups_ten', '컵 10', '가족과 감정적 완성'),
      ('cups_page', '컵 시종', '직관과 감수성'),
      ('cups_knight', '컵 기사', '로맨스와 이상'),
      ('cups_queen', '컵 여왕', '공감과 돌봄'),
      ('cups_king', '컵 왕', '감정적 균형과 성숙'),
      ('swords_ace', '검 에이스', '명확한 통찰과 진실'),
      ('swords_two', '검 2', '딜레마와 균형'),
      ('swords_three', '검 3', '슬픔과 분리'),
      ('swords_four', '검 4', '휴식과 회복'),
      ('swords_five', '검 5', '갈등과 패배감'),
      ('swords_six', '검 6', '전환과 이동'),
      ('swords_seven', '검 7', '전략과 교묘함'),
      ('swords_eight', '검 8', '제약과 불안'),
      ('swords_nine', '검 9', '걱정과 악몽'),
      ('swords_ten', '검 10', '종료와 새로운 시작'),
      ('swords_page', '검 시종', '호기심과 아이디어'),
      ('swords_knight', '검 기사', '결단과 직설'),
      ('swords_queen', '검 여왕', '명료함과 독립'),
      ('swords_king', '검 왕', '이성과 공정한 판단'),
      ('pentacles_ace', '펜타클 에이스', '새로운 기회와 번영'),
      ('pentacles_two', '펜타클 2', '균형과 다재다능'),
      ('pentacles_three', '펜타클 3', '숙련과 협업'),
      ('pentacles_four', '펜타클 4', '안정과 보수'),
      ('pentacles_five', '펜타클 5', '어려움과 불안정'),
      ('pentacles_six', '펜타클 6', '나눔과 지원'),
      ('pentacles_seven', '펜타클 7', '인내와 장기 투자'),
      ('pentacles_eight', '펜타클 8', '기술과 성실'),
      ('pentacles_nine', '펜타클 9', '성취와 자급자족'),
      ('pentacles_ten', '펜타클 10', '부와 유산'),
      ('pentacles_page', '펜타클 시종', '학습과 실용성'),
      ('pentacles_knight', '펜타클 기사', '근면과 신중한 전진'),
      ('pentacles_queen', '펜타클 여왕', '실용과 풍요'),
      ('pentacles_king', '펜타클 왕', '성공과 안정된 경영')
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
  where item.metadata->>'arcana' = 'minor'
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
